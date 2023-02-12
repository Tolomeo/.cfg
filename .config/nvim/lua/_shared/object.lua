---@class Cfg.Util.Object
---@see https://github.com/airstruck/knife/blob/master/knife/base.lua
local Object = {}

---@generic Super: Cfg.Util.Object
---@generic Sub
---@type fun(self: Super, subtype: Sub): (Sub: Super)
function Object:extend(subtype)
	return setmetatable(subtype, {
		__index = self,
	})
end

function Object:constructor(...) end

---@generic O: Cfg.Util.Object
---@type fun(self: O, ...: unknown): O
function Object:new(...)
	local instance = setmetatable({}, { __index = self })
	return instance, instance:constructor(...)
end

return Object
