local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local register = require("_shared.register")
local settings = require("settings")

---@class Cfg.Editor
local Editor = {}

Editor.modules = {
	"editor.syntax",
	"editor.language",
	"editor.format",
}

Editor.plugins = {
	{ "romainl/vim-cool" },
	-- Autoclosing pair of chars
	{ "windwp/nvim-autopairs" },
	-- Parentheses, brackets, quotes, XML tags
	{ "tpope/vim-surround" },
	-- Change case and handles variants of a word
	{ "tpope/vim-abolish" },
	-- additional operator targets
	{ "wellle/targets.vim" },
	-- Highlighting command ranges
	{ "winston0410/range-highlight.nvim", dependencies = "winston0410/cmd-parser.nvim" },
	-- Indentation
	{ "lukas-reineke/indent-blankline.nvim" },
}

function Editor:setup()
	self:setup_keymaps()
	self:setup_highlights()
	self:setup_indent_lines()
	self:setup_pairs()
end

function Editor:setup_keymaps()
	-- Register 0 always contains the last yank.
	-- Unfortunately selecting register 0 all the time can be quite annoying, so it would be nice if p used "0
	-- https://stackoverflow.com/a/32488853
	key.nmap({ "p", '"0p' })
	key.nmap({ "P", '"0P' })
	for _, register_name in ipairs(register.names) do
		local paste = string.format('"%sp', register_name)
		local Paste = string.format('"%sP', register_name)
		key.nmap({ paste, paste, remap = true }, { Paste, Paste, remap = true })
	end

	local keymaps = settings.keymaps()

	key.nmap(
		-- Emptying lines
		{ "dD", ":.s/\v^.*$/<Cr>:noh<Cr>" },
		-- Keep search results centered
		{ "n", "nzzzv" },
		{ "N", "Nzzzv" },

		{ keymaps["buffer.next"], ":bnext<Cr>" },
		{ keymaps["buffer.prev"], ":bprev<Cr>" },
		{ keymaps["buffer.save"], "<Cmd>up<Cr>", silent = false },
		{ keymaps["buffer.save.all"], "<Cmd>wa<Cr>", silent = false },
		{ keymaps["buffer.close"], "<Cmd>q<Cr>" },
		{ keymaps["buffer.close.delete"], "<Cmd>bdelete<Cr>" },
		{ keymaps["buffer.cursor.prev"], "b" },
		{ keymaps["buffer.cursor.prev.big"], "B" },
		{ keymaps["buffer.cursor.next"], "w" },
		{ keymaps["buffer.cursor.next.big"], "W" },
		{ keymaps["buffer.cursor.above"], "9k" },
		{ keymaps["buffer.cursor.above.big"], "18k" },
		{ keymaps["buffer.cursor.below"], "9j" },
		{ keymaps["buffer.cursor.below.big"], "18j" },
		{ keymaps["buffer.line.indent"], ">>" },
		{ keymaps["buffer.line.outdent"], "<<" },
		{ keymaps["buffer.line.join"], "mjJ`j" },
		{ keymaps["buffer.line.bubble.up"], ":m .+1<CR>==" },
		{ keymaps["buffer.line.bubble.down"], ":m .-2<CR>==" },
		{ keymaps["buffer.line.duplicate.up"], "mayyP`a" },
		{ keymaps["buffer.line.duplicate.down"], "mayyp`a" },
		{ keymaps["buffer.line.new.up"], "mm:put! _<CR>`m" },
		{ keymaps["buffer.line.new.down"], "mm:put _<CR>`m" },
		{ keymaps["buffer.word.substitute"], ":%s/<C-r><C-w>//gI<left><left><left>", silent = false },
		{ keymaps["buffer.word.substitute.line"], ":s/<C-r><C-w>//gI<left><left><left>", silent = false },
		{ keymaps["buffer.jump.in"], "<C-i>" },
		{ keymaps["buffer.jump.out"], "<C-o>" },
		{ keymaps["buffer.macro.repeat.last"], "@@" },
		{ keymaps["buffer.select.all"], "ggVG<c-$>" }
	)

	key.vmap(
		-- Arrows are disabled
		{ "<Left>", "<nop>" },
		{ "<Right>", "<nop>" },
		{ "<Up>", "<nop>" },
		{ "<Down>", "<nop>" },
		-- Make visual yanks remain in visual mode
		{ "y", "ygv" },
		-- Emptying lines
		{ "D", "mm<Esc>:'<,'>s/\v^.*$/<Cr>:noh<Cr>`mgv" },

		{ keymaps["buffer.cursor.prev"], "b" },
		{ keymaps["buffer.cursor.prev.big"], "B" },
		{ keymaps["buffer.cursor.next"], "w" },
		{ keymaps["buffer.cursor.next.big"], "W" },
		{ keymaps["buffer.cursor.above"], "9k" },
		{ keymaps["buffer.cursor.above.big"], "18k" },
		{ keymaps["buffer.cursor.below"], "9j" },
		{ keymaps["buffer.line.indent"], ">gv" },
		{ keymaps["buffer.cursor.below.big"], "18j" },
		{ keymaps["buffer.line.outdent"], "<gv" },
		{
			keymaps["buffer.line.new.down"],
			"mm<Esc>:'>put _<CR>`mgv",
		},
		{
			keymaps["buffer.line.new.up"],
			"mm<Esc>:'<put! _<CR>`mgv",
		},
		{ keymaps["buffer.line.bubble.up"], ":m '>+1<CR>gv=gv" },
		{ keymaps["buffer.line.bubble.down"], ":m '<-2<CR>gv=gv" },
		{
			keymaps["buffer.line.duplicate.up"],
			"mmy'<P`mgv",
		},
		{
			keymaps["buffer.line.duplicate.down"],
			"mmy'>p`mgv",
		}
	)

	key.imap(
		-- Arrows are disabled
		{ "<Left>", "<nop>" },
		{ "<Right>", "<nop>" },
		{ "<Up>", "<nop>" },
		{ "<Down>", "<nop>" },
		-- Move cursor within insert mode
		{ "<A-h>", "<Left>" },
		{ "<A-l>", "<Right>" },
		{ "<A-k>", "<Up>" },
		{ "<A-j>", "<Down>" },
		-- Indentation
		{ keymaps["buffer.line.indent"], "<C-t>" },
		{ keymaps["buffer.line.outdent"], "<C-d>" }
	)

	key.cmap({ "<A-h>", "<Left>" }, { "<A-l>", "<Right>" }, { "<A-k>", "<Up>" }, { "<A-j>", "<Down>" })

	key.tmap(
		-- Moving the cursor when in insert
		{ "<A-h>", "<Left>" },
		{ "<A-l>", "<Right>" },
		{ "<A-k>", "<Up>" },
		{ "<A-j>", "<Down>" }
	)
end

function Editor:setup_highlights()
	-- Vim-cool
	vim.g.CoolTotalMatches = 1

	-- Range highlight
	require("range-highlight").setup()

	-- Yanks visual feedback
	au.group({
		"OnTextYanked",
	}, {
		"TextYankPost",
		"*",
		function()
			vim.highlight.on_yank()
		end,
	})
end

function Editor.setup_indent_lines()
	require("indent_blankline").setup({
		space_char_blankline = " ",
		show_current_context = true,
		show_current_context_start = true,
		use_treesitter = true,
		strict_tabs = true,
		context_char = "┃",
	})
end

function Editor.setup_pairs()
	-- Autopairs
	require("nvim-autopairs").setup({
		disable_filetype = { "TelescopePrompt", "vim" },
	})
end

-- Returns the current word under the cursor
function Editor:cword()
	return vim.call("expand", "<cword>")
end

return Module:new(Editor)
