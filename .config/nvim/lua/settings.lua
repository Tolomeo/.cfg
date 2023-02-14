local fs = require("_shared.fs")
local fn = require("_shared.fn")

local defaults = {
	opt = {
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
		numberwidth = 5,
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
		clipboard = "",
		-- Invisible chars render
		list = true,
		listchars = { eol = "↲", tab = "▸ ", trail = "·", space = "·", extends = "…", precedes = "…" },
		-- 	Characters to fill the statuslines, vertical separators and special lines in the window
		fillchars = "foldopen:▼,foldclose:►,eob:·",
		-- The minimal number of screen columns to keep to the left and to the right of the cursor
		-- set to 1 to allow seeing EOL listchar without truncating the text
		sidescrolloff = 1,
		-- Cursor shape and blinking behaviours
		guicursor = { "a:block-blinkon0", "v-ve-sm-o-r:block-blinkon1", "i-c-ci-cr:ver1-blinkon1" },
		-- Folds
		foldenable = true,
		foldmethod = "manual",
		foldcolumn = "1",
		foldlevel = 99,
		foldlevelstart = 99,
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
		-- Completion window behaviours
		completeopt = { "menu", "menuone", "noselect" },
		-- Winbar displaying current file path
		winbar = "%=%f",
	},
	g = {
		loaded_2html_plugin = 1,
		loaded_getscript = 1,
		loaded_getscriptPlugin = 1,
		loaded_gzip = 1,
		loaded_logipat = 1,
		loaded_netrw = 1,
		loaded_netrwPlugin = 1,
		loaded_netrwSettings = 1,
		loaded_netrwFileHandlers = 1,
		loaded_matchit = 1,
		loaded_tar = 1,
		loaded_tarPlugin = 1,
		loaded_rrhelper = 1,
		loaded_spellfile_plugin = 1,
		loaded_vimball = 1,
		loaded_vimballPlugin = 1,
		loaded_zip = 1,
		loaded_zipPlugin = 1,
	},
	keymap = {
		leader = " ",
		-- Buffers navigation
		["buffer.next"] = "]<Tab>",
		["buffer.prev"] = "[<Tab>",
		-- write only if changed
		["buffer.save"] = "<leader>w",
		-- write all and quit
		["buffer.save.all"] = "<leader>W",
		-- quit (or close window)
		["buffer.close"] = "<leader>q",
		-- Delete buffer
		["buffer.close.delete"] = "<leader>Q",
		-- Left
		["buffer.cursor.prev"] = "<S-h>",
		["buffer.cursor.prev.big"] = "<A-S-h>",
		-- Right
		["buffer.cursor.next"] = "<S-l>",
		["buffer.cursor.next.big"] = "<A-S-l>",
		-- Up
		["buffer.cursor.above"] = "<S-k>",
		["buffer.cursor.above.big"] = "<A-S-k>",
		-- Down
		["buffer.cursor.below"] = "<S-j>",
		["buffer.cursor.below.big"] = "<A-S-j>",
		-- Controlling indentation
		["buffer.line.indent"] = "<Tab>",
		["buffer.line.outdent"] = "<S-Tab>",
		-- Join lines and restore cursor location
		["buffer.line.join"] = "<leader>j",
		-- Line bubbling
		["buffer.line.bubble.up"] = "<A-j>",
		["buffer.line.bubble.down"] = "<A-k>",
		-- Duplicating lines up and down
		["buffer.line.duplicate.up"] = "<leader>P",
		["buffer.line.duplicate.down"] = "<leader>p",
		-- Adding blank lines with cr
		["buffer.line.new.up"] = "<leader>O",
		["buffer.line.new.down"] = "<leader>o",
		-- Commenting lines
		["buffer.line.comment"] = "<leader><space>",
		-- Replace word under cursor in buffer
		["buffer.word.substitute"] = "<leader>S",
		-- Replace word under cursor in line
		["buffer.word.substitute.line"] = "<leader>s",
		-- Because we are mapping S-Tab to indent, now C-i indents too so we need to recover it
		["buffer.jump.out"] = "<C-S-o>",
		["buffer.jump.in"] = "<C-o>",
		-- Repeating last macro with Q
		["buffer.macro.repeat.last"] = "Q",
		-- Easy select all of file
		["buffer.select.all"] = "<leader>%",
		-- Dropdowns and context menus
		["dropdown.open"] = "<C-Space>",
		["dropdown.item.next"] = "<Tab>",
		["dropdown.item.prev"] = "<S-Tab>",
		["dropdown.item.confirm"] = "<CR>",
		["dropdown.scroll.up"] = "<C-u>",
		["dropdown.scroll.down"] = "<C-f>",
		-- Language
		["language.lsp.hover"] = "<leader>k",
		["language.lsp.signature_help"] = "<C-k>",
		["language.lsp.references"] = "<leader>gr",
		["language.lsp.definition"] = "<leader>gd",
		["language.lsp.declaration"] = "<leader>gD",
		["language.lsp.type_definition"] = "<leader>gt",
		["language.lsp.implementation"] = "<leader>gi",
		["language.lsp.rename"] = "<leader>r",
		["language.lsp.code_action"] = "<C-Space>",
		["language.diagnostic.next"] = "]d",
		["language.diagnostic.prev"] = "[d",
		["language.diagnostic.open"] = "<leader>d",
		["language.diagnostic.list"] = "<leader>D",
		["language.format"] = "<leader>b",
		-- finder
		["find.files"] = "<leader>E",
		["find.projects"] = "<C-S-e>",
		["find.search.buffer"] = "<leader>f",
		["find.search.directory"] = "<leader>F",
		["find.help"] = "<leader>?",
		["find.spelling"] = "<C-z>",
		["find.buffers"] = "<C-b>",
		["find.todos"] = "<leader>/",
		-- lists
		["list.open"] = "<leader>c",
		["list.close"] = "<leader>C",
		["list.next"] = "]c",
		["list.prev"] = "[c",
		["list.item.open.vertical"] = "<C-x>",
		["list.item.open.horizontal"] = "<C-S-x>",
		["list.item.open.tab"] = "<C-t>",
		["list.item.open.preview"] = "<leader>c",
		["list.item.prev.open.preview"] = "[c",
		["list.item.next.open.preview"] = "]c",
		["list.navigate.first"] = "[C",
		["list.navigate.last"] = "]C",
		["list.item.remove"] = "<leader>d",
		["list.item.keep"] = "<leader>D",
		["list.search"] = "<leader>f",
		-- Git
		["git.blame"] = "<leader>hb",
		["git.diff"] = "<leader>hd",
		["git.hunk.preview"] = "<leader>h",
		["git.hunk.next"] = "]h",
		["git.hunk.prev"] = "[h",
		["git.hunk.select"] = "<leader>hv",
		["git.menu"] = "<leader>H",
		-- Github
		["github.actions"] = "<leader>G",

		["github.react.tada"] = "<space>rp",
		["github.react.heart"] = "<space>rh",
		["github.react.eyes"] = "<space>re",
		["github.react.thumbs_up"] = "<space>r+",
		["github.react.thumbs_down"] = "<space>r-",
		["github.react.rocket"] = "<space>rr",
		["github.react.laugh"] = "<space>rl",
		["github.react.confused"] = "<space>rc",

		["github.comment.add"] = "<space>ca",
		["github.comment.delete"] = "<space>cd",
		["github.comment.next"] = "]c",
		["github.comment.previous"] = "[c",
		["github.suggestion.add"] = "<space>sa",

		["github.review.files.focus"] = "<space>e",
		["github.review.thread.next"] = "]C",
		["github.review.thread.previous"] = "[C",
		["github.review.files.next"] = "j",
		["github.review.files.previous"] = "k",
		["github.review.files.next.select"] = "]q",
		["github.review.files.previous.select"] = "[q",
		["github.review.files.select"] = "<Cr>",
		["github.review.files.viewed.toggle"] = "<leader>b",
		["github.review.files.toggle"] = "<space>b",
		["github.review.files.refresh"] = "R",
		["github.review.submit.approve"] = "<C-a>",
		["github.review.submit.comment"] = "<C-m>",
		["github.review.submit.request_changes"] = "<C-r>",
		["github.review.close"] = "<C-c>",

		["github.pull.checkout"] = "<space>po",
		["github.pull.changes.list"] = "<space>pf",
		["github.pull.diff"] = "<space>pd",
		["github.pull.commits.diff"] = "<space>pc",
		["github.pull.reviewer.add"] = "<space>va",
		["github.pull.reviewer.remove"] = "<space>vd",
		["github.pull.close"] = "<space>ic",
		["github.pull.reopen"] = "<space>io",
		["github.pull.refresh"] = "<C-r>",
		["github.pull.open.browser"] = "<C-b>",
		["github.pull.copy.url"] = "<C-y>",
		["github.pull.open.file"] = "gf",
		["github.pull.assignee.add"] = "<space>aa",
		["github.pull.assignee.remove"] = "<space>ad",
		["github.pull.label.create"] = "<space>lc",
		["github.pull.label.add"] = "<space>la",
		["github.pull.label.remove"] = "<space>ld",
		-- goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },

		-- Project tree
		["project.tree.node.info"] = "<leader>k",
		["project.tree.node.open.vertical"] = "<C-x>",
		["project.tree.node.open.horizontal"] = "<C-S-x>",
		["project.tree.node.open.tab"] = "<C-t>",
		["project.tree.node.collapse"] = "h",
		["project.tree.node.open"] = "l",
		["project.tree.node.open.system"] = "O",
		["project.tree.navigate.parent"] = "H",
		["project.tree.navigate.sibling.first"] = "[",
		["project.tree.navigate.sibling.last"] = "]",
		["project.tree.fs.enter"] = "o",
		["project.tree.fs.create"] = "a",
		["project.tree.fs.remove"] = "d",
		["project.tree.fs.trash"] = "D",
		["project.tree.fs.rename"] = "r",
		["project.tree.fs.rename.full"] = "R",
		["project.tree.fs.copy.node"] = "c",
		["project.tree.fs.cut"] = "C",
		["project.tree.fs.paste"] = "p",
		["project.tree.fs.copy.filename"] = "y",
		["project.tree.fs.copy.path.relative"] = "Y",
		["project.tree.fs.copy.path.absolute"] = "gy",
		["project.tree.refresh"] = "<C-r>",
		["project.tree.collapse.all"] = "gh",
		["project.tree.root.parent"] = "gk",
		["project.tree.help"] = "g?",
		["project.tree.toggle.filter.custom"] = "u",
		["project.tree.toggle.filter.gitignore"] = "i",
		["project.tree.toggle.filter.dotfiles"] = ".",
		["project.tree.actions"] = "<C-Space>",
		["project.tree.search.node.content"] = "<leader>f",
		["project.tree.search.node"] = "/",
		["project.tree.close"] = "q",
		["project.tree.toggle"] = "<leader>e",
		-- Windows
		["window.cursor.left"] = "<C-h>",
		["window.cursor.down"] = "<C-j>",
		["window.cursor.up"] = "<C-k>",
		["window.cursor.right"] = "<C-l>",
		["window.cursor.next"] = "<C-n>",
		["window.cursor.prev"] = "<C-S-n>",
		["window.swap.next"] = "<C-;>",
		["window.shrink.horizontal"] = "<C-A-j>",
		["window.shrink.vertical"] = "<C-A-h>",
		["window.expand.vertical"] = "<C-A-l>",
		["window.expand.horizontal"] = "<C-A-k>",
		["window.fullwidth.bottom"] = "<C-S-j>",
		["window.fullheight.left"] = "<C-S-h>",
		["window.fullheight.right"] = "<C-S-l>",
		["window.fullwidth.top"] = "<C-S-k>",
		["window.equalize"] = "<C-=>",
		["window.maximize"] = "<C-+>",
		["window.split.horizontal"] = "<C-S-x>",
		["window.split.vertical"] = "<C-x>",
		-- Terminal
		["terminal.next"] = "]t",
		["terminal.prev"] = "[t",
		["terminal.open"] = "<leader>t",
		["terminal.menu"] = "<leader>T",
	},
	config = {
		["language.parsers"] = {},
		["language.servers"] = {},
		["language.diagnostics.update_in_insert"] = false,
		["language.diagnostics.severity_sort"] = true,
		["theme.colorscheme"] = "edge",
		["icon.section.right"] = " ▟",
		["icon.section.left"] = "▙ ",
		["icon.component.right"] = " ",
		["icon.component.left"] = " ",
		["terminal.jobs"] = {},
	},
}
---@class Cfg.Settings
local Settings = {}

Settings._directory = vim.fn.stdpath("config") .. "/.cfg"

Settings._file = Settings._directory .. "/settings.json"

Settings.opt = setmetatable({}, {
	__index = function(_, key)
		return vim.opt[key]:get()
	end,
	__newindex = function(_, key, value)
		vim.opt[key] = value
	end,
})

Settings.g = setmetatable({}, {
	__index = function(_, key)
		return vim.g[key]
	end,
	__newindex = function(_, key, value)
		vim.g[key] = value
	end,
})

Settings.keymap = setmetatable({}, {
	__newindex = function() end,
})

Settings.config = setmetatable({}, {
	__newindex = function() end,
})

function Settings:get_user_settings()
	local settings_dir_exists, settings_dir_error

	settings_dir_exists = fs.existsSync(self._directory)

	if not settings_dir_exists then
		settings_dir_exists, settings_dir_error = fs.mkdirSync(self._directory)
	end

	if settings_dir_error then
		error(settings_dir_error)
	end

	local user_settings_exists, user_settings_error, user_settings

	user_settings_exists = fs.existsSync(self._file)

	if not user_settings_exists then
		user_settings_exists, user_settings_error = fs.writeFileSync(self._file, "{}")
	end

	if user_settings_error then
		error(user_settings_error)
	end

	user_settings, user_settings_error = fs.readFileSync(self._file)

	if user_settings_error then
		error(user_settings_error)
	end

	return vim.fn.json_decode(user_settings)
end

function Settings:init()
	local settings = fn.merge_deep(defaults, self:get_user_settings())

	for opt_name, opt_value in pairs(settings.opt) do
		self.opt[opt_name] = opt_value
	end

	for g_name, g_value in pairs(settings.g) do
		self.g[g_name] = g_value
	end

	for keymap_name, keymap_value in pairs(settings.keymap) do
		rawset(self.keymap, keymap_name, keymap_value)
	end

	for config_name, config_value in pairs(settings.config) do
		rawset(self.config, config_name, config_value)
	end
end

return Settings
