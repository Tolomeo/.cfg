local Module = require("utils.module")
-- local key = require("utils.key")
local au = require("utils.au")

local installed = nil
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local config_files = vim.fn.expand("~") .. "/.config/nvim/**"

local Config = Module:new({
	plugins = { "wbthomason/packer.nvim" },
	modules = {
		core = require("config.core"),
		quickfix = require("config.quickfix"),
		interface = require("config.interface"),
		git = require("config.git"),
		editor = require("config.editor"),
		finder = require("config.finder"),
		intellisense = require("config.intellisense"),
		terminal = require("config.terminal"),
	},
	setup = function(self)
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
			use(self:plugins())
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
					self.compile,
				},
			},
		})

		vim.cmd([[
			:command! EditConfig :tabedit ~/.config/nvim
		]])

		-- Base modules configurations
		self:modules().interface.color_scheme("edge")
	end,
})

function Config.compile()
	vim.api.nvim_command("PackerCompile")
end

return Config
