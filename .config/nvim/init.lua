require('defaults')
local plugins = require('plugins')
local modules = require('modules')

modules.setup()

plugins.setup(function(use)
	modules.for_each(function (module)
		use(module.plugins)
	end)
end)

