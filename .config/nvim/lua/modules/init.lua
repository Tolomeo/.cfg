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
	bootstrapping = nil,
}

function Plugins.setup(registerPlugins)
	Plugins.bootstrapping = vim.fn.empty(vim.fn.glob(Plugins.install_path)) > 0

	if Plugins.bootstrapping then
		print("Bootstrapping plugins manager...")
		vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. Plugins.install_path)
		vim.cmd("packadd packer.nvim")
	end

	require("packer").startup(function(use)
		-- Package manager maninging itself
		use("wbthomason/packer.nvim")

		registerPlugins(use)

		-- Automatically set up configuration after cloning packer.nvim
		-- see https://github.com/wbthomason/packer.nvim#bootstrapping
		if Plugins.bootstrapping then
			require("packer").sync()
		end
	end)
end

function Plugins.compile()
	key.input(":PackerCompile<CR>")
end

local M = {
	plugins = Plugins,
}

function M.setup(options)
	M.plugins.setup(function(register)
		for _, module in pairs(modules) do
			register(module.plugins)
		end
	end)

	if not M.plugins.bootstrapping then
		for _, module in pairs(modules) do
			module.setup()
		end

		modules.theme.color_scheme(options.color_scheme)
	end
end

setmetatable(M, { __index = modules })

return M
