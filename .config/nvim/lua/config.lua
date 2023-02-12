local Module = require("_shared.module")
local fs = require("_shared.fs")
local key = require("_shared.key")
local settings = require("settings")

local installed = nil
local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local Config = Module:extend({
	plugins = {
		{ "folke/lazy.nvim", lazy = false },
		{ "williamboman/mason.nvim" },
	},
	modules = {
		"interface",
		"editor",
		"project",
		"integration",
	},
})

function Config:setup()
	settings:init()

	-- setting leader key
	key.map_leader(settings.keymap.leader)

	-- Checking packer install location
	installed = fs.existsSync(install_path)

	-- Cloning plugin manager in place if it is not found
	if not installed then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			install_path,
		})
	end

	vim.opt.runtimepath:prepend(install_path)

	require("lazy").setup(self:list_plugins())

	require("mason").setup()
end

return Config:new()
