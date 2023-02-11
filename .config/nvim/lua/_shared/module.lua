local Object = require("_shared.object")
local logger = require("_shared.logger")

---@class Modules
local Modules = {}

function Modules:require(module_name)
	local loaded = self[module_name]

	if loaded then
		return require(module_name)
	end

	return nil
end

---@param module_name string
function Modules:load(module_name)
	local loaded, load_result = pcall(require, module_name)
	self[module_name] = loaded

	return loaded, load_result
end

---Represents a configuration module
local Module = Object:extend({
	plugins = {},
	modules = {},
	setup = function() end,
})

---@diagnostic disable-next-line
function Module:constructor()
	for _, child_module_name in ipairs(self.modules) do
		local loaded, load_result = Modules:load(child_module_name)

		if not loaded then
			logger.error(
				string.format(
					"Failed to load configuration module '%s' with the error: %s",
					child_module_name,
					load_result
				)
			)
		end
	end
end

--- Initializes the module
function Module:init()
	self:setup()

	for _, child_module_name in ipairs(self.modules) do
		local child_module = Modules:require(child_module_name)

		if not child_module then
			logger.error(
				string.format(
					"Cannot initialize module '%s' with the error: the module was not loaded",
					child_module_name
				)
			)
			goto continue
		end

		---@diagnostic disable-next-line
		child_module:init()

		::continue::
	end
end

function Module:require(module_name)
	return Modules:require(module_name)
end

--- Returns a list of all the plugins used by the module and by its children
---@return table
function Module:list_plugins()
	local plugins = vim.deepcopy(self.plugins)
	local child_modules = self.modules

	for _, child_module_name in ipairs(child_modules) do
		local child_module = Modules:require(child_module_name)

		if not child_module then
			logger.error(
				string.format("Failed to list plugins for '%s' module: the module was not found", child_module_name)
			)
			goto continue
		end

		---@diagnostic disable-next-line
		local child_module_plugins = child_module:list_plugins()

		for _, child_module_plugin in ipairs(child_module_plugins) do
			table.insert(plugins, child_module_plugin)
		end

		::continue::
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
