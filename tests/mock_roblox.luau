--!nonstrict
-- Minimal Roblox mock for running pure-logic modules under the `luau` CLI.
-- Only what configs/utils/DataSchema touch is implemented.

local function class(name)
	local c = {}
	c.__index = c
	c.__type = name
	return c
end

-- Vector2 ------------------------------------------------------------------
local V2 = class("Vector2")
local function v2(x, y)
	local v = setmetatable({ X = x or 0, Y = y or 0 }, V2)
	v.Magnitude = math.sqrt(v.X * v.X + v.Y * v.Y)
	return v
end
V2.__add = function(a, b) return v2(a.X + b.X, a.Y + b.Y) end
V2.__sub = function(a, b) return v2(a.X - b.X, a.Y - b.Y) end
V2.__mul = function(a, b)
	if type(a) == "number" then return v2(b.X * a, b.Y * a) end
	if type(b) == "number" then return v2(a.X * b, a.Y * b) end
	return v2(a.X * b.X, a.Y * b.Y)
end
V2.__unm = function(a) return v2(-a.X, -a.Y) end
V2.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
Vector2 = { new = v2, zero = v2(0, 0) }

-- Vector3 ------------------------------------------------------------------
local V3 = class("Vector3")
local function v3(x, y, z)
	local v = setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V3)
	v.Magnitude = math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
	return v
end
V3.__add = function(a, b) return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V3.__sub = function(a, b) return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
V3.__mul = function(a, b)
	if type(b) == "number" then return v3(a.X * b, a.Y * b, a.Z * b) end
	return v3(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
Vector3 = { new = v3, zero = v3(0, 0, 0), one = v3(1, 1, 1) }

-- CFrame (translation + yaw only; enough for layout math) ------------------
local CF = class("CFrame")
local function cf(x, y, z, yaw)
	local c = setmetatable({ X = x or 0, Y = y or 0, Z = z or 0, Yaw = yaw or 0 }, CF)
	c.Position = v3(c.X, c.Y, c.Z)
	return c
end
CF.__mul = function(a, b)
	local cos, sin = math.cos(a.Yaw), math.sin(a.Yaw)
	return cf(a.X + b.X * cos + b.Z * sin, a.Y + b.Y, a.Z - b.X * sin + b.Z * cos, a.Yaw + b.Yaw)
end
CF.__add = function(a, v) return cf(a.X + v.X, a.Y + v.Y, a.Z + v.Z, a.Yaw) end
function CF:ToEulerAnglesYXZ() return 0, self.Yaw, 0 end
function CF:PointToObjectSpace(p) return v3(p.X - self.X, p.Y - self.Y, p.Z - self.Z) end
function CF:PointToWorldSpace(p) return v3(p.X + self.X, p.Y + self.Y, p.Z + self.Z) end
CFrame = {
	new = function(x, y, z)
		if type(x) == "table" then return cf(x.X, x.Y, x.Z) end
		return cf(x, y, z)
	end,
	Angles = function(_, y, _) return cf(0, 0, 0, y or 0) end,
}

Color3 = {
	fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255 } end,
	new = function(r, g, b) return { R = r, G = g, B = b } end,
}
UDim = { new = function(s, o) return { Scale = s, Offset = o } end }

-- Enum: Enum.Material.Wood -> "Enum.Material.Wood"
Enum = setmetatable({}, {
	__index = function(_, enumName)
		return setmetatable({}, {
			__index = function(_, item)
				return { Name = item, EnumType = enumName, Value = 0 }
			end,
		})
	end,
})

-- task ---------------------------------------------------------------------
local __timers = {}
local __now = 0
task = {
	spawn = function(fn, ...)
		local co = type(fn) == "thread" and fn or coroutine.create(fn)
		local ok, err = coroutine.resume(co, ...)
		if not ok then error(err, 0) end
		return co
	end,
	defer = function(fn, ...) local args = table.pack(...) table.insert(__timers, { At = __now, Fn = fn, Args = args }) end,
	delay = function(t, fn, ...) local args = table.pack(...) local entry = { At = __now + t, Fn = fn, Args = args } table.insert(__timers, entry) return coroutine.create(function() end) end,
	wait = function() return 0 end,
	cancel = function() end,
}
function __advance(seconds)
	__now += seconds
	table.sort(__timers, function(a, b) return a.At < b.At end)
	local due = {}
	for i = #__timers, 1, -1 do
		if __timers[i].At <= __now then
			table.insert(due, 1, table.remove(__timers, i))
		end
	end
	for _, entry in due do
		task.spawn(entry.Fn, table.unpack(entry.Args, 1, entry.Args.n))
	end
end
-- `os` is read-only in the Luau CLI, so modules get a shadowed copy via their env.
local realClock = os.clock
local mockOs = setmetatable({ clock = function() return realClock() + __now end }, { __index = os })

-- Instance tree + require --------------------------------------------------
local Node = class("Instance")
function Node:FindFirstChild(name) return self.__children[name] end
function Node:WaitForChild(name) return assert(self.__children[name], "missing child " .. tostring(name)) end
function Node:IsA(className) return className == "Instance" or className == self.ClassName end
function Node:GetChildren() local out = {} for _, c in self.__children do table.insert(out, c) end return out end
Node.__index = function(self, key)
	local method = rawget(Node, key)
	if method then return method end
	local child = rawget(self, "__children")[key]
	if child then return child end
	error(("%s is not a valid member of %s"):format(tostring(key), rawget(self, "Name")), 2)
end

local function newNode(name, parent, className)
	local node = setmetatable({ Name = name, Parent = parent, ClassName = className or "Folder", __children = {} }, Node)
	if parent then rawget(parent, "__children")[name] = node end
	return node
end

local DataModel = newNode("game", nil, "DataModel")
local services = {}
local function service(name)
	if not services[name] then
		services[name] = newNode(name, DataModel, name)
	end
	return services[name]
end

local RunServiceMock = service("RunService")
rawset(RunServiceMock, "IsServer", function() return true end)
rawset(RunServiceMock, "IsStudio", function() return true end)
rawset(RunServiceMock, "IsClient", function() return false end)

game = setmetatable({}, {
	__index = function(_, key)
		if key == "GetService" then
			return function(_, name) return service(name) end
		end
		return service(key)
	end,
})
workspace = service("Workspace")

function __mountSources(sources)
	for path, src in sources do
		local parts = string.split(path, "/")
		local node = service(parts[1])
		for i = 2, #parts - 1 do
			node = rawget(node, "__children")[parts[i]] or newNode(parts[i], node)
		end
		local leaf = rawget(node, "__children")[parts[#parts]] or newNode(parts[#parts], node, "ModuleScript")
		rawset(leaf, "ClassName", "ModuleScript")
		rawset(leaf, "__source", src)
		rawset(leaf, "__path", path)
	end
end

local cache = {}
local realRequire = require
function require(node)
	if type(node) ~= "table" or rawget(node, "__source") == nil then
		return realRequire(node)
	end
	if cache[node] ~= nil then return cache[node] end
	local fn, err = loadstring(rawget(node, "__source"), "@" .. rawget(node, "__path"))
	assert(fn, err)
	local env = setmetatable({ script = node, os = mockOs }, { __index = getfenv(1) })
	setfenv(fn, env)
	local result = fn()
	cache[node] = result
	return result
end

typeof = function(value)
	if type(value) == "table" then
		local mt = getmetatable(value)
		if mt and rawget(mt, "__type") then return mt.__type end
	end
	return type(value)
end
