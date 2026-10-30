--!nocheck
-- UnionBaker: merges the parts tagged with a "Union" attribute into real
-- UnionOperations (parts also tagged "Negate" are subtracted). The offline
-- builder can't run Roblox CSG, so the model ships as tagged parts.
--
-- Bake once in Studio (recommended), then save:
--   require(workspace.<ModelName>.UnionBaker)(workspace.<ModelName>)
-- (The AutoBake script does the same on the server if you skip this.)
return function(model)
	local groups, order = {}, {}
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and not p:IsA("UnionOperation") and p:GetAttribute("Union") then
			local n = p:GetAttribute("Union")
			if not groups[n] then
				groups[n] = { pos = {}, neg = {} }
				table.insert(order, n)
			end
			table.insert(p:GetAttribute("Negate") and groups[n].neg or groups[n].pos, p)
		end
	end
	local baked = 0
	for _, n in order do
		local g = groups[n]
		local first = g.pos[1]
		if first then
			local w = first:FindFirstChild("W")
			local bone = w and w.Part0
			local others = table.move(g.pos, 2, #g.pos, 1, {})
			local ok, u = pcall(function()
				local r = first
				if #others > 0 then
					r = first:UnionAsync(others)
				end
				if #g.neg > 0 then
					r = r:SubtractAsync(g.neg)
				end
				return r
			end)
			if ok and u then
				u.Name = n
				u.UsePartColor = false
				u.Anchored = false
				u.CanCollide = false
				u.CanTouch = false
				u.CanQuery = false
				u.Massless = true
				pcall(function()
					u.RenderFidelity = Enum.RenderFidelity.Precise
					u.CollisionFidelity = Enum.CollisionFidelity.Box
				end)
				u.Parent = first.Parent
				if bone then
					local nw = Instance.new("Weld")
					nw.Name = "W"
					nw.Part0 = bone
					nw.Part1 = u
					nw.C0 = bone.CFrame:Inverse() * u.CFrame
					nw.Parent = u
				end
				for _, p in g.pos do
					p:Destroy()
				end
				for _, p in g.neg do
					p:Destroy()
				end
				baked += 1
			else
				warn("[UnionBaker] " .. model.Name .. "/" .. n .. ": " .. tostring(u))
			end
		end
	end
	return baked
end
