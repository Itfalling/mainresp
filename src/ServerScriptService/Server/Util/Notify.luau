--[[
	SCRIPT NAME:  Notify
	SCRIPT TYPE:  ModuleScript (server helper)
	WHERE:        ServerScriptService/Server/Util/Notify
	DEPENDENCIES: Shared.Net

	Consistent "Did that work?" feedback (spec §151). Every server action that
	succeeds or fails tells the player through one of these.

	Kinds understood by the client UI:
		Toast   small message under the top bar
		Success green toast
		Error   red toast + error sound
		Banner  big centred title (level up, area unlocked, build complete)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

local Notify = {}

function Notify.Toast(player: Player, text: string, icon: string?)
	Net.FireClient("Notify", player, { Kind = "Toast", Text = text, Icon = icon })
end

function Notify.Success(player: Player, text: string, icon: string?)
	Net.FireClient("Notify", player, { Kind = "Success", Text = text, Icon = icon })
end

function Notify.Error(player: Player, text: string)
	Net.FireClient("Notify", player, { Kind = "Error", Text = text, Icon = "⚠️" })
end

function Notify.Banner(player: Player, title: string, subtitle: string?, style: string?)
	Net.FireClient("Notify", player, { Kind = "Banner", Text = title, Subtitle = subtitle, Style = style })
end

return Notify
