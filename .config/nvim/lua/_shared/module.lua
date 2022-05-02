local Module = {}

function Module:new(module_options)
	local module = {
		_plugins = module_options.plugins or {},
		_modules = module_options.modules or {},
		_setup = module_options.setup or function() end,
	}

	setmetatable(module, self)
	self.__index = self

	return module
end

function Module:setup(...)
	self:_setup(...)

	local child_modules = self:modules()
	for _, child_module in pairs(child_modules) do
		child_module:setup(...)
	end
end

function Module:plugins()
	local plugins = vim.deepcopy(self._plugins)
	local child_modules = self:modules()

	for _, child_module in pairs(child_modules) do
		local child_module_plugins = child_module:plugins()
		for _, child_module_plugin in ipairs(child_module_plugins) do
			table.insert(plugins, child_module_plugin)
		end
	end

	return plugins
end

function Module:modules()
	return self._modules
end

return Module