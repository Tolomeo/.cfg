local validator = require("_shared.validator")
local logger = require("_shared.logger")

---@class Modules
local Modules = {}

---@type fun(self: Modules, module_name: string): Module
function Modules:get(module_name)
	return self[module_name]
end

---@type fun(self: Modules, module_name: string, module: Module): nil
function Modules:set(module_name, module)
	self[module_name] = module
end

--- Represents a configuration module
---@class Module
local Module = {
	plugins = {},
	modules = {},
}

Module.plugins = {}

Module.modules = {}

--- Setups module specific configurations, like plugins scaffolding
---@type fun()
Module.setup = function() end

--- Initializes the module
---@type fun(self: Module)
Module.init = function(self)
	self.setup()

	for _, child_module_name in ipairs(self.modules) do
		Modules:get(child_module_name):init()
	end
end

--- Instantiates a new module
---@type fun(self: Module, module: table): Module
Module.new = validator.f.arguments({
	validator.f.equal(Module),
	validator.f.shape({
		plugins = validator.f.optional("table"),
		modules = validator.f.optional("table"),
		setup = validator.f.optional("function"),
	}),
})
	.. function(self, m)
		m = m or {}

		setmetatable(m, self)
		self.__index = self

		-- Saving submodules in custom register
		for _, child_module_name in ipairs(m.modules) do
			local ok, result = pcall(require, child_module_name)

			if not ok then
				logger.error(
					string.format(
						"Failed to load configuration module '%s' with the error: %s",
						child_module_name,
						result
					)
				)
				goto continue
			end

			Modules:set(child_module_name, result)

			::continue::
		end

		return m
	end

--- Returns a list of all the plugins used by the module and by its children
---@return table
function Module:list_plugins()
	local plugins = vim.deepcopy(self.plugins)
	local child_modules = self.modules

	for _, child_module_name in ipairs(child_modules) do
		local child_module_plugins = Modules:get(child_module_name):list_plugins()
		for _, child_module_plugin in ipairs(child_module_plugins) do
			table.insert(plugins, child_module_plugin)
		end
	end

	return plugins
end

--[[ --- Returns a tree structure of all modules
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
end ]]

return Module
