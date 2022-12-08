local validator = require("_shared.validator")
-- see https://github.com/NvChad/NvChad/blob/main/lua/core/options.lua
local Settings = {}

Settings._globals = {
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
	signcolumn = "number",
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
	-- 	Characters to fill the statuslines, vertical separators and special lines in the window
	fillchars = "foldopen:▼,foldclose:►,eob: ",
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
	--
	completeopt = { "menu", "menuone", "noselect" },
}

-- see https://github.com/NvChad/NvChad/blob/main/lua/core/options.lua
Settings._plugins = {
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

function Settings.globals(globals)
	if not globals then
		return Settings._globals
	end

	Settings._globals = vim.tbl_extend("force", Settings._globals, globals)

	for option_name, option_value in pairs(Settings._globals) do
		vim.opt[option_name] = option_value
	end

	for plugin_name, plugin_enabled in pairs(Settings._plugins) do
		if not plugin_enabled then
			vim.g["loaded_" .. plugin_name] = 1
		end
	end

	return Settings._globals
end

Settings._keymaps = {
	leader = " ",
	-- Buffers navigation
	["buffer.next"] = "<A-Tab>",
	["buffer.prev"] = "<A-S-Tab>",
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
	-- Cleaning a line
	["buffer.line.clear"] = "<leader>d",
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
	-- Language
	["language.lsp.hover"] = "<leader>k",
	["language.lsp.document_symbol"] = "<leader>K",
	["language.lsp.references"] = "<leader>gr",
	["language.lsp.definition"] = "<leader>gd",
	["language.lsp.declaration"] = "<leader>gD",
	["language.lsp.type_definition"] = "<leader>gt",
	["language.lsp.implementation"] = "<leader>gi",
	["language.lsp.rename"] = "<leader>r",
	["language.lsp.code_action"] = "<C-Space>",
	["language.diagnostic.next"] = "<leader>dj",
	["language.diagnostic.prev"] = "<leader>dk",
	["language.diagnostic.list"] = "<leader>dl",
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
	["list.item.next"] = "]c",
	["list.item.prev"] = "[c",
	["list.item.open.vertical"] = "<C-x>",
	["list.item.open.horizontal"] = "<C-S-x>",
	["list.item.open.tab"] = "<C-t>",
	["list.item.preview"] = "<leader>c",
	["list.item.preview.prev"] = "[c",
	["list.item.preview.next"] = "]c",
	["list.item.first"] = "{c",
	["list.item.last"] = "}c",
	-- Git
	["git.blame"] = "gb",
	["git.log"] = "gl",
	["git.diff"] = "gd",
	["git.merge"] = "gm",
	["git.hunk"] = "gh",
	["git.hunk.next"] = "]g",
	["git.hunk.prev"] = "[g",
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
	["terminal.create"] = "<leader>t",
	["terminal.jobs"] = "<leader>T",
}

Settings.keymaps = validator.f.arguments({
	validator.f.optional(validator.f.shape({
		leader = validator.f.optional("string"),
	})),
}) .. function(keymaps)
	if not keymaps then
		return Settings._keymaps
	end

	Settings._keymaps = vim.tbl_extend("force", Settings._keymaps, keymaps)

	return Settings._keymaps
end

Settings._options = {
	["language.parsers"] = {},
	["language.servers"] = {},
	["theme.colorscheme"] = "nightfox",
	["theme.component_separator"] = "│",
	["theme.section_separator"] = "█",
	["terminal.jobs"] = {},
}

Settings.options = validator.f.arguments({
	validator.f.optional(validator.f.shape({
		["language.parsers"] = validator.f.optional(validator.f.list({ "string" })),
		["language.servers"] = validator.f.optional(validator.f.list({
			validator.f.shape({
				name = "string",
				settings = validator.f.optional("function"),
			}),
		})),
		["theme.colorscheme"] = validator.f.optional(
			validator.f.one_of({ "edge", "onedark", "nightfox", "ayu", "tokyonight", "rose-pine" })
		),
		["theme.component_separator"] = validator.f.optional("string"),
		["theme.section_separator"] = validator.f.optional("string"),
		["terminal.jobs"] = validator.f.optional(validator.f.list({
			validator.f.shape({
				command = "string",
				--[[ args = validator.f.optional(validator.f.list("string")),
				cwd = validator.f.optional("string"),
				env = validator.f.optional("table"), ]]
			}),
		})),
	})),
})
	.. function(options)
		if not options then
			return Settings._options
		end

		Settings._options = vim.tbl_extend("force", Settings._options, options)

		return Settings._options
	end

return setmetatable(Settings, {
	__call = validator.f.arguments({
		validator.f.equal(Settings),
		validator.f.shape({
			globals = validator.f.optional("table"),
			keymaps = validator.f.optional("table"),
			options = validator.f.optional("table"),
		}),
	}) .. function(self, settings)
		local globals = settings.globals or {}
		local keymaps = settings.keymaps or {}
		local options = settings.options or {}

		self.globals(globals)
		self.keymaps(keymaps)
		self.options(options)

		return self
	end,
})
