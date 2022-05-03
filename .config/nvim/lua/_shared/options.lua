--Remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local M = {}

local globals = {
	--Incremental live completion (note: this is now a default on master)
	inccommand = "nosplit",
	-- Set highlight on search
	hlsearch = true,
	-- Avoid rerendering during macros, registers etc
	lazyredraw = true,
	--Make line numbers default
	number = true,
	--Do not save when switching buffers (note: this is now a default on master)
	hidden = true,
	-- Do not automatically create backup files
	backup = false,
	writebackup = false,
	--Enable mouse mode
	mouse = "a",
	--Enable break indent
	breakindent = true,
	--Save undo history
	undofile = true,
	--Case insensitive searching UNLESS /C or capital in search
	ignorecase = true,
	smartcase = true,
	--Decrease update time
	updatetime = 250,
	-- Always show signcolumn
	signcolumn = "yes",
	--Set colorscheme (order is impotant here)
	termguicolors = true,
	--Indent size
	shiftwidth = 2,
	tabstop = 2,
	autoindent = true,
	smartindent = true,
	-- Avoid word wrap because it's weird
	wrap = false,
	-- Spellcheck targets british english, but disabled by default
	spell = false,
	spelllang = "en_gb",
	-- Using system clipbard as default register
	clipboard = "unnamedplus",
	-- Invisible chars render
	list = true,
	listchars = { eol = "↲", tab = "▸ ", trail = "·", space = "·", extends = "…", precedes = "…" },
	-- The minimal number of screen columns to keep to the left and to the right of the cursor
	-- set to 1 to allow seeing EOL listchar without truncating the text
	sidescrolloff = 1,
	-- Cursor shape and blinking behaviours
	guicursor = { "a:block-blinkon0", "v-ve-sm-o-r:block-blinkon1", "i-c-ci-cr:ver1-blinkon1" },
	-- Folds
	foldenable = false,
	foldmethod = "indent",
	laststatus = 3,
	-- Killing netrw
	-- netrw_banner = 0,
	-- netrw_menu = 0,
	-- loaded_netrw = 1,
	-- loaded_netrwPlugin = 1,
	--
	splitright = true,
	splitbelow = true,
}

-- see https://github.com/NvChad/NvChad/blob/main/lua/core/options.lua
local plugins = {
	["2html_plugin"] = false,
	getscript = false,
	getscriptPlugin = false,
	gzip = false,
	logipat = false,
	netrw = false,
	netrwPlugin = false,
	netrwSettings = false,
	netrwFileHandlers = false,
	matchit = false,
	tar = false,
	tarPlugin = false,
	rrhelper = false,
	spellfile_plugin = false,
	vimball = false,
	vimballPlugin = false,
	zip = false,
	zipPlugin = false,
}

function M.set()
	for option_name, option_value in pairs(globals) do
		vim.opt[option_name] = option_value
	end

	-- see https://github.com/NvChad/NvChad/blob/main/lua/core/options.lua
	for plugin_name, _ in pairs(plugins) do
		vim.g["loaded_" .. plugin_name] = 1
	end
end

function M.get()
	return globals
end

return M
