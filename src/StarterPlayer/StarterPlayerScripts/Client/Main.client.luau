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
		InteractionController, ToolController
		InventoryController, IslandController
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
	Controllers.InteractionController,
	Controllers.ToolController,
	Controllers.InventoryController,
	Controllers.IslandController,
}

local loaded = {}
for index, module in ORDER do
	loaded[index] = require(module) :: any
end

for _, controller in loaded do
	if type(controller.Init) == "function" then
		controller.Init()
	end
end

for _, controller in loaded do
	if type(controller.Start) == "function" then
		controller.Start()
	end
end
