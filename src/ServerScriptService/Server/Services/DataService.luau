--[[
	SCRIPT NAME:  DataService
	SCRIPT TYPE:  ModuleScript (server service)
	WHERE:        ServerScriptService/Server/Services/DataService
	DEPENDENCIES: Shared.Net, Shared.Config.GameConfig, Shared.Util.{Signal,TableUtil},
	              Server.Data.DataSchema, Server.Data.MockDataStore
	REQUIRED OBJECTS: Game Settings > Security > "Enable Studio Access to API Services"
	              (optional; without it Studio uses the in-memory mock)

	THE ONLY system that reads/writes the DataStore and the ONLY writer of
	profile data. Other services mutate profiles through Set / Increment /
	Update so that every change is (1) marked dirty for autosave and
	(2) replicated to the owning client in batched StateSync packets.

	Safety guarantees (spec §97, §117, §147, §148):
	  * UpdateAsync only, with retries + exponential backoff.
	  * Session locking: a profile is owned by one server at a time. A save
	    that finds another server's lock is cancelled (never overwrites).
	  * A profile that failed to load is NEVER saved (no blank-overwrite).
	  * DataSchema.IsSaveable() gate before every write.
	  * Dirty-flag autosave, save on leave, BindToClose shutdown save.
]]

local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Net = require(Shared.Net)
local GameConfig = require(Shared.Config.GameConfig)
local Signal = require(Shared.Util.Signal)
local TableUtil = require(Shared.Util.TableUtil)

local ServerRoot = script.Parent.Parent
local DataSchema = require(ServerRoot.Data.DataSchema)
local MockDataStore = require(ServerRoot.Data.MockDataStore)

local DataConfig = GameConfig.Data
local SESSION_ID = HttpService:GenerateGUID(false)
local LOCK_REFRESH_INTERVAL = DataConfig.SessionLockTimeout / 4

type Path = { string }

type Profile = {
	Player: Player,
	Key: string,
	Data: any,
	Loaded: boolean,
	Dirty: boolean,
	Saving: boolean,
	Releasing: boolean,
	LockLost: boolean,
	ClientReady: boolean,
	PendingOps: { any },
	FlushScheduled: boolean,
	LastSave: number,
	LastSaveResult: string,
}

local DataService = {}

DataService.ProfileLoaded = Signal.new() -- (player, data)
DataService.ProfileReleasing = Signal.new() -- (player, data) last chance to write before the final save
DataService.Changed = Signal.new() -- (player, path, value)

local store: any = nil
local usingMock = false
local profiles: { [Player]: Profile } = {}
local readyBeforeProfile: { [Player]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function log(...)
	if GameConfig.Debug then
		print("[DataService]", ...)
	end
end

local function keyFor(player: Player): string
	return DataConfig.KeyPrefix .. tostring(player.UserId)
end

local function newLock()
	return { Id = SESSION_ID, JobId = game.JobId, PlaceId = game.PlaceId, Time = os.time() }
end

local function resolveStore()
	local mode = DataConfig.UseMockDataStore
	if mode == true then
		store, usingMock = MockDataStore.new(), true
		warn("[DataService] UseMockDataStore = true — data will NOT persist")
		return
	end

	local ok, result = pcall(DataStoreService.GetDataStore, DataStoreService, DataConfig.StoreName)
	if ok then
		store = result
	end

	if mode == "Auto" and RunService:IsStudio() then
		local probeOk, probeErr = false, "GetDataStore failed"
		if store then
			probeOk, probeErr = pcall(function()
				return store:GetAsync("__probe")
			end)
		end
		if not probeOk then
			warn("[DataService] DataStore unavailable in Studio (" .. tostring(probeErr) .. ").")
			warn("[DataService] Using an in-memory mock: progress lasts for this play session only.")
			warn("[DataService] Enable Game Settings > Security > Studio Access to API Services to test real saving.")
			store, usingMock = MockDataStore.new(), true
		end
	end

	if not store then
		warn("[DataService] Could not open DataStore:", result)
	end
end

local function waitForBudget(requestType: Enum.DataStoreRequestType)
	if usingMock then
		return
	end
	local waited = 0
	while DataStoreService:GetRequestBudgetForRequestType(requestType) < 1 and waited < 10 do
		task.wait(0.5)
		waited += 0.5
	end
end

local function backoff(attempt: number)
	task.wait(DataConfig.RetryBaseDelay * 2 ^ (attempt - 1))
end

---------------------------------------------------------------------------
-- Replication
---------------------------------------------------------------------------

local function publicCopy(data: any): any
	local copy = {}
	for key, value in data do
		if not DataSchema.PrivateKeys[key] then
			copy[key] = TableUtil.DeepCopy(value)
		end
	end
	return copy
end

local function sendFull(profile: Profile)
	table.clear(profile.PendingOps)
	Net.FireClient("StateSync", profile.Player, { Full = publicCopy(profile.Data) })
end

local function queueOp(profile: Profile, path: Path, value: any)
	if not profile.ClientReady or DataSchema.PrivateKeys[path[1]] then
		return
	end
	table.insert(profile.PendingOps, { Path = table.clone(path), Value = TableUtil.DeepCopy(value) })
	if profile.FlushScheduled then
		return
	end
	profile.FlushScheduled = true
	task.defer(function()
		profile.FlushScheduled = false
		if #profile.PendingOps == 0 then
			return
		end
		local ops = profile.PendingOps
		profile.PendingOps = {}
		Net.FireClient("StateSync", profile.Player, { Ops = ops })
	end)
end

---------------------------------------------------------------------------
-- DataStore IO
---------------------------------------------------------------------------

-- Loads the record and takes the session lock. Returns the record or nil.
local function loadRecord(key: string): any
	local steal = DataConfig.StudioStealLocks and RunService:IsStudio()
	local errors, lockWaits = 0, 0

	while errors < DataConfig.LoadAttempts do
		waitForBudget(Enum.DataStoreRequestType.UpdateAsync)
		local status = "Error"
		local ok, result = pcall(function()
			return store:UpdateAsync(key, function(old)
				local record = if type(old) == "table" then old else {}
				local lock = record.SessionLock
				local lockAlive = type(lock) == "table"
					and lock.Id ~= SESSION_ID
					and type(lock.Time) == "number"
					and os.time() - lock.Time < DataConfig.SessionLockTimeout
				if lockAlive and not steal then
					status = "Locked"
					return nil -- cancel: another server owns this profile
				end
				status = "OK"
				record.SessionLock = newLock()
				return record
			end)
		end)

		if ok and status == "OK" then
			return result
		elseif ok and status == "Locked" then
			lockWaits += 1
			log(("%s is locked by another server (wait %d/%d)"):format(key, lockWaits, DataConfig.LockRetries))
			if lockWaits >= DataConfig.LockRetries then
				warn("[DataService] Taking over stale session lock for " .. key)
				steal = true
			else
				task.wait(DataConfig.LockRetryDelay)
			end
		else
			errors += 1
			warn(("[DataService] Load attempt %d failed for %s: %s"):format(errors, key, tostring(result)))
			if errors < DataConfig.LoadAttempts then
				backoff(errors)
			end
		end
	end
	return nil
end

-- Releases our lock without touching Data (used when a player leaves mid-load).
local function releaseLockOnly(key: string)
	pcall(function()
		store:UpdateAsync(key, function(old)
			if type(old) ~= "table" or type(old.SessionLock) ~= "table" or old.SessionLock.Id ~= SESSION_ID then
				return nil
			end
			old.SessionLock = nil
			return old
		end)
	end)
end

local function saveProfile(profile: Profile, release: boolean): boolean
	if not profile.Loaded or profile.LockLost then
		return false
	end
	while profile.Saving do
		task.wait()
	end
	profile.Saving = true
	profile.Dirty = false -- changes made while we yield will mark it dirty again

	local snapshot = TableUtil.DeepCopy(profile.Data)
	snapshot.Meta.LastSavedAt = os.time()

	local saveable, reason = DataSchema.IsSaveable(snapshot)
	if not saveable then
		warn(("[DataService] Refusing to save %s: %s"):format(profile.Key, tostring(reason)))
		profile.Saving = false
		profile.LastSaveResult = "Refused: " .. tostring(reason)
		return false
	end

	local encodedOk, encoded = pcall(HttpService.JSONEncode, HttpService, snapshot)
	if encodedOk and #encoded > DataConfig.SizeWarningBytes then
		warn(("[DataService] %s is %d bytes — approaching the DataStore limit"):format(profile.Key, #encoded))
	end

	for attempt = 1, DataConfig.SaveAttempts do
		waitForBudget(Enum.DataStoreRequestType.UpdateAsync)
		local lostLock = false
		local ok, err = pcall(function()
			return store:UpdateAsync(profile.Key, function(old)
				local lock = if type(old) == "table" then old.SessionLock else nil
				if type(lock) ~= "table" or lock.Id ~= SESSION_ID then
					lostLock = true
					return nil -- another session owns (or released) this profile: never overwrite
				end
				return {
					Data = snapshot,
					SessionLock = if release then nil else newLock(),
					SavedAt = os.time(),
				}
			end)
		end)

		if ok then
			profile.Saving = false
			if lostLock then
				profile.LockLost = true
				profile.LastSaveResult = "LockLost"
				warn("[DataService] Session lock lost for " .. profile.Key .. " — this server will stop saving it")
				if profile.Player.Parent then
					profile.Player:Kick("Your island was opened in another server. Please rejoin.")
				end
				return false
			end
			profile.LastSave = os.clock()
			profile.LastSaveResult = if release then "Released" else "Saved"
			log(("Saved %s%s"):format(profile.Key, if release then " (released)" else ""))
			return true
		end

		warn(("[DataService] Save attempt %d failed for %s: %s"):format(attempt, profile.Key, tostring(err)))
		if attempt < DataConfig.SaveAttempts then
			backoff(attempt)
		end
	end

	profile.Saving = false
	profile.Dirty = true
	profile.LastSaveResult = "Failed"
	return false
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function DataService.Init()
	Net.OnServerEvent("ClientReady", function(player: Player)
		local profile = profiles[player]
		if not profile then
			readyBeforeProfile[player] = true
			return
		end
		profile.ClientReady = true
		if profile.Loaded then
			sendFull(profile)
		end
	end)
end

function DataService.Start()
	resolveStore()

	task.spawn(function()
		while true do
			task.wait(GameConfig.AutosaveInterval)
			for _, profile in table.clone(profiles) do
				local lockStale = os.clock() - profile.LastSave > LOCK_REFRESH_INTERVAL
				if profile.Loaded and not profile.Releasing and not profile.Saving and (profile.Dirty or lockStale) then
					task.spawn(saveProfile, profile, false)
					task.wait(0.25) -- stagger writes
				end
			end
		end
	end)

	game:BindToClose(function()
		local deadline = os.clock() + DataConfig.ShutdownSaveTimeout
		for player in table.clone(profiles) do
			task.spawn(DataService.ReleaseProfile, player)
		end
		while next(profiles) ~= nil and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

-- Yields. Returns the loaded data table, or nil if loading failed / player left.
function DataService.LoadProfile(player: Player): any
	local existing = profiles[player]
	if existing then
		return if existing.Loaded then existing.Data else nil
	end
	if not store then
		warn("[DataService] No DataStore available; cannot load " .. player.Name)
		if DataConfig.KickOnLoadFailure then
			player:Kick("Island data is unavailable right now. Please try again in a moment.")
		end
		return nil
	end

	local profile: Profile = {
		Player = player,
		Key = keyFor(player),
		Data = nil,
		Loaded = false,
		Dirty = false,
		Saving = false,
		Releasing = false,
		LockLost = false,
		ClientReady = readyBeforeProfile[player] == true,
		PendingOps = {},
		FlushScheduled = false,
		LastSave = os.clock(),
		LastSaveResult = "NotSaved",
	}
	profiles[player] = profile

	local record = loadRecord(profile.Key)

	if player.Parent == nil then
		-- Left while loading: give the lock back without writing anything.
		if record then
			releaseLockOnly(profile.Key)
		end
		profiles[player] = nil
		return nil
	end

	if not record then
		-- NEVER continue with a blank profile: it could be saved over real progress.
		profiles[player] = nil
		warn("[DataService] Failed to load data for " .. player.Name .. " after retries")
		if DataConfig.KickOnLoadFailure then
			player:Kick("We couldn't load your island safely. Your progress is safe — please rejoin in a minute.")
		end
		return nil
	end

	local data = DataSchema.Sanitize(record.Data)
	local now = os.time()
	if data.Meta.CreatedAt == 0 then
		data.Meta.CreatedAt = now
	end
	data.Meta.LastJoinAt = now
	data.Meta.JoinCount += 1

	profile.Data = data
	profile.Loaded = true
	profile.Dirty = true
	log(("Loaded %s (mock=%s)"):format(profile.Key, tostring(usingMock)))

	DataService.ProfileLoaded:Fire(player, data)
	if profile.ClientReady then
		sendFull(profile)
	end
	return data
end

-- Yields. Final save + lock release. Safe to call more than once.
function DataService.ReleaseProfile(player: Player)
	local profile = profiles[player]
	if not profile then
		return
	end
	if profile.Releasing then
		while profiles[player] == profile do
			task.wait(0.1)
		end
		return
	end
	profile.Releasing = true
	if profile.Loaded then
		DataService.ProfileReleasing:Fire(player, profile.Data)
		task.wait() -- let ProfileReleasing handlers write their final values
		saveProfile(profile, true)
	end
	profiles[player] = nil
end

function DataService.IsLoaded(player: Player): boolean
	local profile = profiles[player]
	return profile ~= nil and profile.Loaded
end

-- Read-only access. DO NOT mutate the returned table — use Set/Increment/Update.
function DataService.GetData(player: Player): any
	local profile = profiles[player]
	return if profile and profile.Loaded then profile.Data else nil
end

function DataService.Get(player: Player, path: Path): any
	local node = DataService.GetData(player)
	for _, key in path do
		if type(node) ~= "table" then
			return nil
		end
		node = node[key]
	end
	return node
end

function DataService.Set(player: Player, path: Path, value: any): boolean
	local profile = profiles[player]
	if not profile or not profile.Loaded or #path == 0 then
		return false
	end
	local parent = profile.Data
	for index = 1, #path - 1 do
		local child = parent[path[index]]
		if type(child) ~= "table" then
			error(("[DataService] Invalid path %s at '%s'"):format(table.concat(path, "."), path[index]), 2)
		end
		parent = child
	end
	parent[path[#path]] = value
	profile.Dirty = true
	queueOp(profile, path, value)
	DataService.Changed:Fire(player, path, value)
	return true
end

function DataService.Increment(player: Player, path: Path, delta: number): number?
	local current = DataService.Get(player, path)
	if type(current) ~= "number" then
		current = 0
	end
	local newValue = current + delta
	if DataService.Set(player, path, newValue) then
		return newValue
	end
	return nil
end

-- transform(oldValue) -> newValue. Handy for table edits:
-- DataService.Update(player, {"Island","UnlockedAreas"}, function(t) t.Forest = true return t end)
function DataService.Update(player: Player, path: Path, transform: (any) -> any): boolean
	local current = DataService.Get(player, path)
	return DataService.Set(player, path, transform(current))
end

-- Re-sends the full profile (e.g. after an admin reset).
function DataService.Resync(player: Player)
	local profile = profiles[player]
	if profile and profile.Loaded and profile.ClientReady then
		sendFull(profile)
	end
end

-- Studio/admin only: reset a profile to the template (the save still goes through the lock).
function DataService.ResetProfile(player: Player)
	local profile = profiles[player]
	if not profile or not profile.Loaded then
		return
	end
	profile.Data = DataSchema.Sanitize(nil)
	profile.Data.Meta.CreatedAt = os.time()
	profile.Dirty = true
	DataService.Resync(player)
end

function DataService.SaveNow(player: Player): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	return saveProfile(profile, false)
end

function DataService.GetDebugState(player: Player): { [string]: any }
	local profile = profiles[player]
	if not profile then
		return { Loaded = false }
	end
	return {
		Loaded = profile.Loaded,
		Dirty = profile.Dirty,
		Saving = profile.Saving,
		LockLost = profile.LockLost,
		LastSaveResult = profile.LastSaveResult,
		SecondsSinceSave = math.floor(os.clock() - profile.LastSave),
		Mock = usingMock,
		Session = SESSION_ID,
	}
end

Players.PlayerRemoving:Connect(function(player)
	readyBeforeProfile[player] = nil
end)

return DataService
