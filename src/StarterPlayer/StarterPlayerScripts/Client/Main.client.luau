--[[
	SCRIPT NAME:  Main
	SCRIPT TYPE:  LocalScript (client entry point)
	WHERE:        StarterPlayer/StarterPlayerScripts/Client/Main
	DEPENDENCIES: every ModuleScript in Client/Controllers, Client/ClientState

	Boots the client: waits for the game to load, hides the default Roblox
	backpack (we use our own hotbar), then Init()s and Start()s controllers in
	dependency order. No gameplay logic lives here.

	CONTROLLER LAYERS (a controller may only require ones ABOVE it):
		ClientState, InputController, AudioController, VFXController, CameraController
		AnimationController
		UIController
		ToolController
		InteractionController
		InventoryController, BuildController (+ Client/Build/LandEditor)
		IslandController, QuestController, FarmController, FishingController,
		AnimalController, ShopController, TradeController
		PlayersController, SocialController, IslandCreatorController
]]

local StarterGui = game:GetService("StarterGui")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- The custom hotbar replaces Roblox's Backpack UI.
task.spawn(function()
	for _ = 1, 10 do
		local ok = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Backpack, false)
		if ok then
			break
		end
		task.wait(0.5)
	end
end)

local Client = script.Parent
local Controllers = Client.Controllers

local ORDER: { ModuleScript } = {
	Client.ClientState,
	Controllers.InputController,
	Controllers.AudioController,
	Controllers.VFXController,
	Controllers.CameraController,
	Controllers.AnimationController,
	Controllers.UIController,
	Controllers.ToolController,
	Controllers.InteractionController,
	Controllers.InventoryController,
	Controllers.BuildController,
	Controllers.IslandController,
	Controllers.QuestController,
	Controllers.FarmController,
	Controllers.FishingController,
	Controllers.AnimalController,
	Controllers.ShopController,
	Controllers.TradeController,
	Controllers.PlayersController,
	Controllers.SocialController,
	Controllers.IslandCreatorController,
}

-- One broken controller must not take the whole client down with it:
-- each step is protected and reported in the Output window.
local function run(label: string, callback: () -> ()): boolean
	local ok, message = xpcall(callback, debug.traceback)
	if not ok then
		warn(("[Client] %s failed:\n%s"):format(label, tostring(message)))
	end
	return ok
end

local loaded: { { Name: string, Controller: any } } = {}
for _, module in ORDER do
	run("require " .. module.Name, function()
		table.insert(loaded, { Name = module.Name, Controller = require(module) :: any })
	end)
end

for _, entry in loaded do
	if type(entry.Controller.Init) == "function" then
		run(entry.Name .. ".Init", entry.Controller.Init)
	end
end

for _, entry in loaded do
	if type(entry.Controller.Start) == "function" then
		run(entry.Name .. ".Start", entry.Controller.Start)
	end
end
