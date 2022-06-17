local validator = require("_shared.validator")
local fn = require("_shared.fn")

--- Represents a configuration module
---@class Module
local Module = {
	plugins = {},
	modules = {},
}

Module.plugins = {}

Module.modules = {}

--- Setups module specific configurations, like plugins scaffolding
---@type fun(options: table)
---@diagnostic disable-next-line: unused-local
Module.setup = function(options) end

--- Inspects the value given
---@param value any
Module.debug = function(value)
	print(vim.inspect(value))
end

--- Initializes the module
---@type fun(self: Module, options: table)
Module.init = validator.f.arguments({
	validator.f.instance_of(Module),
	validator.f.optional("table"),
}) .. function(self, options)
	options = options or {}

	self.setup(options)

	for child_module_name, child_module in pairs(self.modules) do
		child_module:init(options[child_module_name])
	end
end

--- Instantiates a new module
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

--- Returns a tree structure of all modules
---@return table
function Module:list_modules()
	return fn.kreduce(
		self.modules,
		function(_modules, module, module_name)
			_modules[module_name] = module:list_modules()
			return _modules
		end,
		setmetatable({}, {
			__index = self,
		})
	)
end

return Module
