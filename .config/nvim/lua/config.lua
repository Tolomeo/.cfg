local Module = require("_shared.module")
local key = require("_shared.key")
local au = require("_shared.au")
local settings = require("settings")
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

Config.setup = function()
	-- setting leader key
	key.map_leader(settings.keymaps().leader)

	-- Checking packer install location
	installed = vim.fn.empty(vim.fn.glob(install_path)) == 0

	-- Cloning packer in place if it is not found
	if not installed then
		print("Installing plugins...")
		vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
		vim.cmd("packadd packer.nvim")
	end

	-- Registering plugins to use
	require("packer").startup(function(use)
		use(Config:list_plugins())
	end)

	-- Downloading plugins
	-- returning to avoid plugin require errors
	if not installed then
		require("packer").sync()
		return
	end

	au.group({
		"OnConfigChange",
		{
			{
				"BufWritePost",
				config_files,
				Config.compile,
			},
		},
	})

	vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])
end

function Config.compile()
	vim.api.nvim_command("PackerCompile")
end

return Module:new(Config)
