local Module = require("_shared.module")
local options = require("_shared.options")
local key = require("_shared.key")
local au = require("_shared.au")
local validator = require("_shared.validator")

local installed = nil
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local config_files = vim.fn.expand("~", false) .. "/.config/nvim/**/*"

local default_settings = {
	leader = " ",
}

local Config
Config = Module:new({
	plugins = { "wbthomason/packer.nvim" },
	modules = {
		core = require("core"),
		quickfix = require("list"),
		interface = require("interface"),
		git = require("git"),
		editor = require("editor"),
		finder = require("finder"),
		intellisense = require("lsp"),
		terminal = require("terminal"),
	},
	setup = validator.f.arguments({ validator.f.shape({
		leader = validator.f.optional("string"),
	}) }) .. function(settings)
		-- extending defaults
		settings = vim.tbl_extend("force", default_settings, settings)

		-- setting leader key
		key.map_leader(settings.leader)

		-- Global options
		-- TODO: receive, validate and pass to options customisable global options
		options.set()

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

		-- Base modules configurations
		Config.modules.interface.color_scheme("edge")
	end,
})

function Config.compile()
	vim.api.nvim_command("PackerCompile")
end

return Config
