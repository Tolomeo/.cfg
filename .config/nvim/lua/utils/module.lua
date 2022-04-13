local Module = {}

local decorate = function(module_definition)
	local module_setup = module_definition.setup

	function module_definition:setup(...)
		module_setup(module_definition, ...)

		for _, child_module in pairs(module_definition.modules) do
			child_module.setup(child_module, ...)
		end
	end

	return module_definition
end

function Module:new(m)
	m = m or {} -- create object if user does not provide one
	setmetatable(m, self)
	self.__index = self

	return decorate(m)
end

Module.setup = function() end

Module.plugins = {}

Module.modules = {}

return Module
