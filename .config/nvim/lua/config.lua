local Module = require("_shared.module")
local key = require("_shared.key")
local au = require("_shared.au")
local settings = require("settings")
local fn = require("_shared.fn")
local logger = require("_shared.logger")

local installed = nil
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local config_files = vim.fn.expand("~", false) .. "/.config/nvim/**/*"

local Config = {}

Config.plugins = {
	"wbthomason/packer.nvim",
	"kyazdani42/nvim-web-devicons",
}

Config.modules = {
	"interface",
	"project",
	"editor",
	"finder",
	"terminal",
}

function Config:init()
	-- Checking packer install location
	installed = vim.fn.empty(vim.fn.glob(install_path)) == 0

	-- Cloning packer in place if it is not found
	if not installed then
		print("Installing plugins...")
		vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
		vim.cmd([[packadd packer.nvim]])
	end

	-- Registering plugins to use
	require("packer").startup(function(use)
		use(self:list_plugins())
	end)

	-- Downloading plugins
	-- returning to avoid plugin require errors
	if not installed then
		au.group({
			"OnPackerSyncComplete",
			{ {
				"User",
				"PackerComplete",
				fn.bind(self.init, self),
				once = true,
			} },
		})

		return require("packer").sync()
	end

	self:setup()

	for _, child_module_name in ipairs(self.modules) do
		local child_module = self:require(child_module_name)

		if not child_module then
			logger.error(
				string.format(
					"Cannot initialize module '%s' with the error: the module was not loaded",
					child_module_name
				)
			)
			goto continue
		end

		child_module:init()

		::continue::
	end
end

function Config:setup()
	-- setting leader key
	key.map_leader(settings.keymaps().leader)

	au.group({
		"OnConfigChange",
		{
			{
				"BufWritePost",
				config_files,
				fn.bind(self.compile, self),
			},
		},
	})

	vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])
end

function Config:compile()
	vim.api.nvim_command("PackerCompile")
end

return Module:new(Config)
