local validator = require("_shared.validator")
local Module = {}

local module_setup = function(setup)
	return function(self, ...)
		setup(self, ...)

		local child_modules = self.modules
		for _, child_module in pairs(child_modules) do
			child_module:setup(...)
		end
	end
end

Module.new = validator.f.arguments({
	validator.f.equal(Module),
	validator.f.shape({
		plugins = validator.f.optional("table"),
		modules = validator.f.optional("table"),
		setup = validator.f.optional("function"),
	}),
}) .. function(self, module_options)
	local module = {
		plugins = module_options.plugins or {},
		modules = module_options.modules or {},
		setup = module_setup(module_options.setup or function() end),
	}

	setmetatable(module, self)
	self.__index = self

	return module
end

function Module:list_plugins()
	local plugins = vim.deepcopy(self.plugins)
	local child_modules = self.modules

	for _, child_module in pairs(child_modules) do
		local child_module_plugins = child_module:list_plugins()
		for _, child_module_plugin in ipairs(child_module_plugins) do
			table.insert(plugins, child_module_plugin)
		end
	end

	return plugins
end

return Module
