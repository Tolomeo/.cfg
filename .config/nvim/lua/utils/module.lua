local Module = {
	plugins = {},
	modules = {}
}

function Module:new(m)
	m = m or {} -- create object if user does not provide one
	setmetatable(m, self)
	self.__index = self
	return m
end

function Module:setup() end

return Module
