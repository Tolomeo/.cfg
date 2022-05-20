-- see https://github.com/NvChad/NvChad/blob/main/lua/core/options.lua
local Options = {}

local globals = {
	-- asking for confirmation instead of just failing certain commands
	confirm = true,
	--Incremental live completion (note: this is now a default on master)
	inccommand = "nosplit",
	-- Set highlight on search
	hlsearch = true,
	-- Highlighting the cursor line
	cul = true,
	-- Avoid rerendering during macros, registers etc
	lazyredraw = true,
	-- Command line height
	cmdheight = 1,
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
	-- Single global statusline
	laststatus = 3,
	-- Preferred split direction
	splitright = true,
	splitbelow = true,
	-- Mapping movements able to wrap on the next/previous line
	whichwrap = {
		b = true, -- backspace
		s = true, -- space
		[">"] = true, -- right in normal and visual
		["<"] = true, --  left in normal and visual
		["]"] = true, -- right in insert and replace
		["["] = true, -- left in insert and replace
		["h"] = true, -- h
		["l"] = true, -- l
	},
	--
	completeopt = { "menu", "menuone", "noselect" }
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

--- Sets global options and disables some builtin vim plugins
function Options.set()
	for option_name, option_value in pairs(globals) do
		vim.opt[option_name] = option_value
	end

	for plugin_name, plugin_enabled in pairs(plugins) do
		if not plugin_enabled then
			vim.g["loaded_" .. plugin_name] = 1
		end
	end
end

--- Returns global vim variables set by the configuration
---@return table
function Options.get()
	return globals
end

return Options
