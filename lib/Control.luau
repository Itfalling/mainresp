--!nocheck
-- Control: drive a guardian's animation from your game scripts (server or client).
-- Animation runs on every client; these calls just set replicated attributes.
--
--   local Control = require(guardian.Animation.Control)
--   Control.setState(guardian, "Chase")   -- looping: "Idle", "Chase", "Return"
--   Control.play(guardian, "Alert")       -- one-shot: "Alert", "Attack", "GiveUp", "Catch";
--                                         -- afterwards it falls back to the looping state
--   task.wait(Control.length(guardian, "Alert"))   -- seconds the one-shot lasts
--   Control.speed(guardian, "Chase")      -- studs/s the run cycle is made for (at scale 1)
--
-- Typical guardian loop:
--   plant stolen  -> Control.setState(g, "Chase"); Control.play(g, "Alert")
--   close enough  -> Control.play(g, "Attack")    caught -> Control.play(g, "Catch")
--   crossed line  -> Control.setState(g, "Return"); Control.play(g, "GiveUp")
--   back home     -> Control.setState(g, "Idle")
-- Move the guardian yourself (PivotTo / TweenService / a Humanoid); the run
-- cycle automatically speeds up or slows down to match how fast it moves.

local Control = {}

function Control.setState(model, name)
	model:SetAttribute("AnimState", name)
end

function Control.play(model, name)
	local n = (model:GetAttribute("AnimActionCount") or 0) + 1
	model:SetAttribute("AnimActionCount", n)
	model:SetAttribute("AnimAction", name .. "#" .. n)
end

function Control.length(model, name)
	return model:GetAttribute("Length_" .. name) or 0
end

function Control.speed(model, name)
	return (model:GetAttribute("Speed_" .. name) or 0) * model:GetScale()
end

function Control.states(model)
	local list = {}
	for k in model:GetAttributes() do
		local s = string.match(k, "^Length_(.+)$")
		if s then
			table.insert(list, s)
		end
	end
	table.sort(list)
	return list
end

return Control
