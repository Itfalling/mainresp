--[[
	SCRIPT NAME:  AnimationPlayer
	SCRIPT TYPE:  ModuleScript (shared animation core)
	WHERE:        ReplicatedStorage/Shared/Animation/AnimationPlayer
	DEPENDENCIES: Shared.Config.AnimationConfig, Shared.Util.Signal, Shared.Util.AssetId,
	              Shared.Animation.ProceduralFallback

	One AnimationPlayer per rig (R15 character, NPC or animal). Used by the
	client AnimationController (local character) and the server
	AnimationService (NPCs / animals) so there is exactly ONE implementation of
	loading, caching, priorities, markers and cleanup.

	  local player = AnimationPlayer.new(character, { EnableFallback = true })
	  local handle = player:Play("HammerSwing", {
	      Markers = { HammerHit = function() applyBuildProgress() end },
	  })
	  handle.Ended:Connect(function() end)

	Handles behave the same for real and placeholder animations:
	  * real Id        -> AnimationTrack + GetMarkerReachedSignal
	                      (+ watchdog if the uploaded animation forgot a marker)
	  * placeholder Id -> "virtual" track: markers fire at AnimationConfig times,
	                      Ended fires after Length / Speed.
	So gameplay code NEVER uses arbitrary task.wait() for animation timing.
]]

local RunService = game:GetService("RunService")

local Shared = script.Parent.Parent
local AnimationConfig = require(Shared.Config.AnimationConfig)
local AssetId = require(Shared.Util.AssetId)
local Signal = require(Shared.Util.Signal)
local ProceduralFallback = require(script.Parent.ProceduralFallback)

export type PlayOptions = {
	Speed: number?,
	FadeTime: number?,
	Weight: number?,
	Force: boolean?, -- play even if a non-interruptible animation is running
	Markers: { [string]: (handle: any) -> () }?,
}

local animationCache: { [string]: Animation } = {}
local warnedOnce: { [string]: boolean } = {}

local function warnOnce(key: string, message: string)
	if not warnedOnce[key] then
		warnedOnce[key] = true
		warn(message)
	end
end

local function getAnimationObject(id: string): Animation
	local animation = animationCache[id]
	if not animation then
		animation = Instance.new("Animation")
		animation.AnimationId = id
		animationCache[id] = animation
	end
	return animation
end

---------------------------------------------------------------------------
-- Handle
---------------------------------------------------------------------------

local Handle = {}
Handle.__index = Handle

function Handle.new(owner: any, name: string, def: any, speed: number)
	local self = setmetatable({
		Name = name,
		Def = def,
		Owner = owner,
		Speed = speed,
		Playing = true,
		Track = nil :: AnimationTrack?,
		Ended = Signal.new(),
		_callbacks = {} :: { [string]: { (any) -> () } },
		_connections = {} :: { RBXScriptConnection },
		_connectedMarkers = {} :: { [string]: boolean },
		_reached = {} :: { [string]: boolean },
		_threads = {} :: { thread },
		_stopFallback = nil :: (() -> ())?,
		_cycle = 0,
	}, Handle)
	return self
end

function Handle:IsPlaying(): boolean
	return self.Playing
end

function Handle:_reach(markerName: string, cycle: number?)
	if not self.Playing then
		return
	end
	if cycle and cycle ~= self._cycle then
		return
	end
	self._reached[markerName] = true
	local callbacks = self._callbacks[markerName]
	if callbacks then
		for _, callback in callbacks do
			task.spawn(callback, self)
		end
	end
	self.Owner.MarkerReached:Fire(self.Name, markerName, self)
end

function Handle:_connectRealMarker(markerName: string)
	local track = self.Track
	if not track or self._connectedMarkers[markerName] then
		return
	end
	self._connectedMarkers[markerName] = true
	table.insert(self._connections, track:GetMarkerReachedSignal(markerName):Connect(function()
		self:_reach(markerName)
	end))
end

function Handle:OnMarker(markerName: string, callback: (any) -> ())
	local list = self._callbacks[markerName]
	if not list then
		list = {}
		self._callbacks[markerName] = list
	end
	table.insert(list, callback)
	self:_connectRealMarker(markerName)
end

-- Schedules one virtual cycle: configured markers + end/loop.
function Handle:_scheduleVirtualCycle()
	self._cycle += 1
	local cycle = self._cycle
	local speed = math.max(self.Speed, 0.01)
	for markerName, time in self.Def.Markers do
		table.insert(self._threads, task.delay(time / speed, function()
			self:_reach(markerName, cycle)
		end))
	end
	table.insert(self._threads, task.delay(self.Def.Length / speed, function()
		if not self.Playing or cycle ~= self._cycle then
			return
		end
		if self.Def.Looped then
			self:_scheduleVirtualCycle()
		else
			self:_finish()
		end
	end))
end

-- Real tracks: fire any configured marker the uploaded animation never sent.
function Handle:_scheduleWatchdogs()
	if self.Def.Looped then
		return
	end
	local speed = math.max(self.Speed, 0.01)
	for markerName, time in self.Def.Markers do
		self:_connectRealMarker(markerName)
		table.insert(self._threads, task.delay(time / speed + AnimationConfig.MarkerWatchdogGrace, function()
			if self.Playing and not self._reached[markerName] then
				warnOnce(
					self.Name .. ":" .. markerName,
					("[Animation] '%s' never fired marker '%s' — add it in the Animation Editor. Firing from config timing."):format(self.Name, markerName)
				)
				self:_reach(markerName)
			end
		end))
	end
end

function Handle:_finish()
	if not self.Playing then
		return
	end
	self.Playing = false
	for _, connection in self._connections do
		connection:Disconnect()
	end
	table.clear(self._connections)
	for _, thread in self._threads do
		if coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
		end
	end
	table.clear(self._threads)
	if self._stopFallback then
		self._stopFallback()
		self._stopFallback = nil
	end
	if self.Owner._handles[self.Name] == self then
		self.Owner._handles[self.Name] = nil
	end
	self.Ended:Fire(self)
	self.Ended:DisconnectAll()
end

function Handle:Stop(fadeTime: number?)
	if not self.Playing then
		return
	end
	local track = self.Track
	if track then
		track:Stop(fadeTime or self.Def.FadeOut)
	end
	self:_finish()
end

function Handle:SetSpeed(speed: number)
	self.Speed = math.max(speed, 0.01)
	local track = self.Track
	if track then
		track:AdjustSpeed(self.Speed)
	end
end

---------------------------------------------------------------------------
-- AnimationPlayer
---------------------------------------------------------------------------

local AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer

function AnimationPlayer.new(rig: Model, options: { EnableFallback: boolean? }?)
	local self = setmetatable({
		Rig = rig,
		MarkerReached = Signal.new(), -- (animationName, markerName, handle)
		_tracks = {} :: { [string]: AnimationTrack },
		_handles = {} :: { [string]: any },
		_enableFallback = options ~= nil and options.EnableFallback == true and AnimationConfig.UseProceduralFallback,
		_destroyed = false,
	}, AnimationPlayer)
	return self
end

function AnimationPlayer:_getAnimator(): Animator?
	local controller: Instance? = self.Rig:FindFirstChildOfClass("Humanoid") or self.Rig:FindFirstChildOfClass("AnimationController")
	if not controller then
		return nil
	end
	local animator = controller:FindFirstChildOfClass("Animator")
	if not animator and RunService:IsServer() then
		animator = Instance.new("Animator")
		animator.Parent = controller
	end
	return animator
end

-- Returns (and caches) the AnimationTrack, or nil for placeholder ids.
function AnimationPlayer:LoadTrack(name: string): AnimationTrack?
	local cached = self._tracks[name]
	if cached then
		return cached
	end
	local def = AnimationConfig.Get(name)
	if not def or AssetId.IsPlaceholder(def.Id) then
		return nil
	end
	local animator = self:_getAnimator()
	if not animator then
		warnOnce("NoAnimator:" .. self.Rig:GetFullName(), "[Animation] No Animator found on " .. self.Rig:GetFullName())
		return nil
	end
	local ok, track = pcall(animator.LoadAnimation, animator, getAnimationObject(def.Id))
	if not ok or not track then
		warnOnce("LoadFail:" .. name, ("[Animation] Failed to load '%s' (%s): %s"):format(name, def.Id, tostring(track)))
		return nil
	end
	local priority = (Enum.AnimationPriority :: any)[def.Priority]
	if priority then
		track.Priority = priority
	end
	track.Looped = def.Looped
	self._tracks[name] = track
	return track
end

-- Preload tracks so the first swing has no hitch.
function AnimationPlayer:Preload(names: { string })
	for _, name in names do
		self:LoadTrack(name)
	end
end

function AnimationPlayer:_blockedByNonInterruptible(): boolean
	for _, handle in self._handles do
		if handle.Playing and handle.Def.Interruptible == false and not handle.Def.Looped then
			return true
		end
	end
	return false
end

function AnimationPlayer:Play(name: string, options: PlayOptions?): any
	if self._destroyed then
		return nil
	end
	local opts: PlayOptions = options or {}
	local def = AnimationConfig.Get(name)
	if not def then
		warnOnce("Unknown:" .. name, "[Animation] Unknown animation '" .. name .. "' (add it to AnimationConfig)")
		return nil
	end
	if not opts.Force and self:_blockedByNonInterruptible() then
		return nil
	end

	local existing = self._handles[name]
	if existing then
		existing:Stop(0.05)
	end

	local speed = opts.Speed or 1
	local handle = Handle.new(self, name, def, speed)
	self._handles[name] = handle

	if opts.Markers then
		for markerName, callback in opts.Markers do
			handle:OnMarker(markerName, callback)
		end
	end

	local track = self:LoadTrack(name)
	if track then
		handle.Track = track
		-- Mark the handle before connecting so OnMarker callbacks registered above hook the track.
		for markerName in handle._callbacks do
			handle:_connectRealMarker(markerName)
		end
		table.insert(handle._connections, track.Stopped:Connect(function()
			-- With deferred signals a Stop()+Play() on the same cached track can
			-- deliver the old Stopped after the new Play; ignore it in that case.
			if track.IsPlaying then
				return
			end
			handle:_finish()
		end))
		track:Play(opts.FadeTime or def.FadeIn, opts.Weight or 1, speed)
		handle:_scheduleWatchdogs()
	else
		handle:_scheduleVirtualCycle()
		if self._enableFallback and ProceduralFallback.HasStyle(def.Fallback) then
			handle._stopFallback = ProceduralFallback.Play(self.Rig, def.Fallback, def.Length / math.max(speed, 0.01), def.Looped)
		end
	end

	return handle
end

function AnimationPlayer:Stop(name: string, fadeTime: number?)
	local handle = self._handles[name]
	if handle then
		handle:Stop(fadeTime)
	end
end

function AnimationPlayer:StopAll(fadeTime: number?)
	for _, handle in table.clone(self._handles) do
		handle:Stop(fadeTime)
	end
end

function AnimationPlayer:IsPlaying(name: string): boolean
	local handle = self._handles[name]
	return handle ~= nil and handle.Playing
end

function AnimationPlayer:GetHandle(name: string): any
	return self._handles[name]
end

function AnimationPlayer:SetSpeed(name: string, speed: number)
	local handle = self._handles[name]
	if handle then
		handle:SetSpeed(speed)
	end
end

function AnimationPlayer:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:StopAll(0)
	for _, track in self._tracks do
		track:Destroy()
	end
	table.clear(self._tracks)
	self.MarkerReached:DisconnectAll()
end

return AnimationPlayer
