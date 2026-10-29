--!nocheck
local L = require(script.Parent.AnimLib)
local M = {}
local function noop() end
M.States = {
	Idle = { Loop = true, Length = 12, Update = noop },
	Alert = { Length = 2.4, Update = noop },
	Chase = { Loop = true, Length = 0.8, Speed = 29, Update = noop },
	Attack = { Length = 1.4, Update = noop },
	Catch = { Length = 2.2, Update = noop },
	GiveUp = { Length = 2.8, Update = noop },
	Return = { Loop = true, Length = 1.6, Speed = 6, Update = noop },
}
M.Base = "Idle"
M.Reel = { { "Idle" }, { "Alert" }, { "Chase", 3.6 }, { "Attack" }, { "Catch" }, { "Chase", 1.8 }, { "GiveUp" }, { "Return", 3.6 } }
return L.states(M)
