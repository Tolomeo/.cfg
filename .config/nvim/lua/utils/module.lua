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

function Module:new(module_options)
	local module = {
		plugins = module_options.plugins or {},
		modules = module_options.modules or {},
		setup = module_options.setup or function() end,
	}

	setmetatable(module, self)
	self.__index = self

	return module
end

return Module
