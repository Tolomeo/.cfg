local validator = require("_shared.validator")

--- Represents a configuration module
---@class Module
local Module = {
	plugins = {},
	modules = {},
}

Module.plugins = {}

Module.modules = {}

--- Setups module specific configurations, like plugins scaffolding
---@type fun(self: Module, options: table)
Module.setup = function(self, options) end

--- Initializes the module
---@type fun(self: Module, options: table)
Module.init = validator.f.arguments({
	validator.f.instance_of(Module),
	"table",
}) .. function(self, options)
	self.setup(self, options)

	for _, child_module in pairs(self.modules) do
		child_module:init(options)
	end
end

--- Instantiate a new module
---@type fun(self: Module, module: table): Module
Module.new = validator.f.arguments({
	validator.f.equal(Module),
	validator.f.optional(validator.f.shape({
		plugins = validator.f.optional("table"),
		modules = validator.f.optional("table"),
		setup = validator.f.optional("function"),
	})),
}) .. function(self, module)
	module = module or {}

	setmetatable(module, self)
	self.__index = self

	return module
end

--- Returns a list of all the plugins used by the module and by its children
---@return table
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
