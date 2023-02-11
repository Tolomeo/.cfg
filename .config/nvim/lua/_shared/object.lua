---@class Cfg.Util.Object
---@see https://github.com/airstruck/knife/blob/master/knife/base.lua
local Object = {}

---@generic O: Cfg.Util.Object
---@generic S
---@type fun(self: O, subtype: S): O | S
function Object:extend(subtype)
	subtype = subtype or {}
	return setmetatable(subtype, {
		__index = self,
	})
end

function Object:constructor() end

---@generic O: Cfg.Util.Object
---@type fun(self: O, ...: unknown): O
function Object:new(...)
	self.__index = self
	local instance = setmetatable({}, self)
	---@diagnostic disable-next-line
	instance:constructor(...)
	return instance
end

return Object
