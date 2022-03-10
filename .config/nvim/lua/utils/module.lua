local Module = {
	plugins = {},
}

function Module:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function Module:autocommands() end

function Module:setup() end

local M = {}

function M.create(...)
	return Module:new(...)
end

return M
