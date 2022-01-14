local key = require("utils.key")
local modules = {
	core = require("modules.core"),
	quickfix = require("modules.quickfix"),
	theme = require("modules.theme"),
	editor = require("modules.editor"),
	git = require("modules.git"),
	finder = require("modules.finder"),
	intellisense = require("modules.intellisense"),
}

local Plugins = {
	install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim",
	installing = nil,
}

function Plugins.setup(registerPlugins)
	-- Checking packer install location
	Plugins.installing = vim.fn.empty(vim.fn.glob(Plugins.install_path)) > 0

	-- Cloning packer in place if it is not found
	if Plugins.installing then
		print("Installing plugins...")
		vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. Plugins.install_path)
		vim.cmd("packadd packer.nvim")
	end

	-- Registering plugins to use
	require("packer").startup(function(use)
		-- Package manager maninging itself
		use("wbthomason/packer.nvim")
		-- Consumer defined plugins
		registerPlugins(use)
	end)

	-- Automatically set up configuration after cloning packer.nvim
	if Plugins.installing then
		require("packer").sync()
	end
end

function Plugins.compile()
	key.input(":PackerCompile<CR>")
end

local M = {
	plugins = Plugins,
}
setmetatable(M, { __index = modules })

function M.for_each(fn)
	for _, module in pairs(modules) do
		fn(module)
	end
end

function M.setup(options)
	-- Registering plugins
	M.plugins.setup(function(use)
		M.for_each(function(module)
			use(module.plugins)
		end)
	end)

	-- Returning if plugins still need to install to avoid errors
	if M.plugins.installing then
		return
	end

	-- Setup up modules
	M.for_each(function(module)
		module.setup()
	end)

	-- Base modules configurations
	modules.theme.color_scheme(options.color_scheme)
end

return M
