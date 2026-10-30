--!nocheck
-- AutoBake: if this model's union groups weren't baked in Studio yet, bake them
-- on the server when the game starts (they replicate to every player).
local model = script.Parent
if model:GetAttribute("HasUnions") then
	local baker = model:FindFirstChild("UnionBaker")
	if baker then
		require(baker)(model)
	end
end
