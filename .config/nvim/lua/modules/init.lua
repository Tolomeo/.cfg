local module = require("utils.module")
local key = require("utils.key")
local au = require("utils.au")

local Config = {
	-- plugins = Plugins,
	plugins = { "wbthomason/packer.nvim" },
	modules = {
		core = require("modules.core"),
		quickfix = require("modules.quickfix"),
		interface = require("modules.interface"),
		git = require("modules.git"),
		editor = require("modules.editor"),
		finder = require("modules.finder"),
		intellisense = require("modules.intellisense"),
		terminal = require("modules.terminal"),
	},
	installed = nil,
	install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim",
}

function Config:autocommands(_)
	-- Recompiling config whenever something changes
	au.group("OnConfigChange", {
		{
			"BufWritePost",
			"~/.config/nvim/**",
			self.compile,
		},
	})
end

function Config:setup(options)
	-- Checking packer install location
	self.installed = vim.fn.empty(vim.fn.glob(self.install_path)) == 0

	-- Cloning packer in place if it is not found
	if not self.installed then
		print("Installing plugins...")
		vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. self.install_path)
		vim.cmd("packadd packer.nvim")
	end

	-- Registering plugins to use
	require("packer").startup(function(use)
		-- Package manager maninging itself
		use(self.plugins)
		-- Consumer defined plugins
		for _, m in pairs(self.modules) do
			use(m.plugins)
		end
	end)

	-- Downloading plugins
	-- returning to avoid plugin require errors
	if not self.installed then
		require("packer").sync()
		return
	end

	-- Setup up modules
	self:autocommands(options)
	for _, m in pairs(self.modules) do
		m:setup(options)
		m:autocommands(options)
	end

	vim.cmd([[
		:command! EditConfig :tabedit ~/.config/nvim
	]])

	-- Base modules configurations
	self.modules.interface.color_scheme(options.color_scheme)
end

function Config.compile()
	key.input(":PackerCompile<CR>")
end

return module.create(Config)
