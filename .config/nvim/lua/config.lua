local Module = require("_shared.module")
local key = require("_shared.key")
local settings = require("settings")
local logger = require("_shared.logger")

local installed = nil
local install_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

local Config = {}

Config.plugins = {
	{ "folke/lazy.nvim", lazy = false },
	{ "williamboman/mason.nvim", lazy = false },
	{ "kyazdani42/nvim-web-devicons" },
}

Config.modules = {
	"interface",
	"editor",
	"project",
	"integration",
}

function Config:init()
	-- Checking packer install location
	installed = vim.loop.fs_stat(install_path)

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

	vim.opt.runtimepath:append(install_path)

	require("lazy").setup(self:list_plugins())

	-- Downloading plugins
	if not installed then
		require("lazy").sync({ wait = true })
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

	require("mason").setup()
end

return Module:new(Config)
