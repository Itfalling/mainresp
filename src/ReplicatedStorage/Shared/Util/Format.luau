--!strict
--[[
	SCRIPT NAME:  Format
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/Format
	DEPENDENCIES: none

	Number / time formatting for UI.
]]

local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa" }

function Format.Commas(value: number): string
	local text = tostring(math.floor(value))
	local negative = string.sub(text, 1, 1) == "-"
	if negative then
		text = string.sub(text, 2)
	end
	local formatted = string.reverse((string.gsub(string.reverse(text), "(%d%d%d)", "%1,")))
	if string.sub(formatted, 1, 1) == "," then
		formatted = string.sub(formatted, 2)
	end
	return (negative and "-" or "") .. formatted
end

-- 999 -> "999", 12_345 -> "12.3K", 4_500_000 -> "4.5M"
function Format.Abbreviate(value: number): string
	local absolute = math.abs(value)
	if absolute < 10_000 then
		return Format.Commas(value)
	end
	local tier = math.min(math.floor(math.log10(absolute) / 3), #SUFFIXES - 1)
	local scaled = value / 10 ^ (tier * 3)
	local text = string.format("%.1f", scaled)
	text = string.gsub(text, "%.0$", "")
	return text .. SUFFIXES[tier + 1]
end

function Format.Duration(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local hours = seconds // 3600
	local minutes = (seconds % 3600) // 60
	local secs = seconds % 60
	if hours > 0 then
		return string.format("%dh %dm", hours, minutes)
	elseif minutes > 0 then
		return string.format("%dm %ds", minutes, secs)
	end
	return string.format("%ds", secs)
end

return Format
