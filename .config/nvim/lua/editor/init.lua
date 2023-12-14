local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local settings = require("settings")

local Editor = Module:extend({
	modules = {
		"editor.syntax",
		"editor.language",
		"editor.format",
	},
	plugins = {
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
		{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	},
})

function Editor:setup()
	self:setup_keymaps()
	self:setup_highlights()
	self:setup_indent_lines()
	self:setup_pairs()
end

function Editor:setup_keymaps()
	-- Yanking and pasting from/to system clipboard by default
	-- https://stackoverflow.com/a/32488853
	--[[ key.nmap({ "y", '"*y' }, { "Y", '"*Y' }, { "p", '"*p' }, { "P", '"*P' })
	key.vmap({ "y", '"*y' }, { "Y", '"*Y' }, { "p", '"*p' }, { "P", '"*P' }) ]]

	local keymap = settings.keymap

	key.nmap(
		-- Emptying lines
		{ "dD", ":.s/\v^.*$/<Cr>:noh<Cr>" },
		-- Keep search results centered
		{ "n", "nzzzv" },
		{ "N", "Nzzzv" },

		{ keymap["buffer.next"], ":bnext<Cr>" },
		{ keymap["buffer.prev"], ":bprev<Cr>" },
		{ keymap["buffer.save"], "<Cmd>up<Cr>", silent = false },
		{ keymap["buffer.save.all"], "<Cmd>wa<Cr>", silent = false },
		{ keymap["buffer.close"], "<Cmd>q<Cr>" },
		{ keymap["buffer.close.delete"], "<Cmd>bdelete<Cr>" },
		{ keymap["buffer.cursor.prev"], "b" },
		{ keymap["buffer.cursor.prev.big"], "B" },
		{ keymap["buffer.cursor.next"], "w" },
		{ keymap["buffer.cursor.next.big"], "W" },
		{ keymap["buffer.cursor.above"], "9k" },
		{ keymap["buffer.cursor.above.big"], "18k" },
		{ keymap["buffer.cursor.below"], "9j" },
		{ keymap["buffer.cursor.below.big"], "18j" },
		{ keymap["buffer.line.indent"], ">>" },
		{ keymap["buffer.line.outdent"], "<<" },
		{ keymap["buffer.line.join"], "mjJ`j" },
		{ keymap["buffer.line.bubble.up"], ":m .+1<CR>==" },
		{ keymap["buffer.line.bubble.down"], ":m .-2<CR>==" },
		-- TODO: avoid saving bubbling lines in registry
		{ keymap["buffer.line.duplicate.up"], "mayyP`a" },
		{ keymap["buffer.line.duplicate.down"], "mayyp`a" },
		{ keymap["buffer.line.new.up"], "mm:put! _<CR>`m" },
		{ keymap["buffer.line.new.down"], "mm:put _<CR>`m" },
		{ keymap["buffer.word.substitute"], ":%s/<C-r><C-w>//gI<left><left><left>", silent = false },
		{ keymap["buffer.word.substitute.line"], ":s/<C-r><C-w>//gI<left><left><left>", silent = false },
		{ keymap["buffer.jump.in"], "<C-i>" },
		{ keymap["buffer.jump.out"], "<C-o>" },
		{ keymap["buffer.macro.repeat.last"], "@@" },
		{ keymap["buffer.select.all"], "ggVG<c-$>" }
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

		{ keymap["buffer.cursor.prev"], "b" },
		{ keymap["buffer.cursor.prev.big"], "B" },
		{ keymap["buffer.cursor.next"], "w" },
		{ keymap["buffer.cursor.next.big"], "W" },
		{ keymap["buffer.cursor.above"], "9k" },
		{ keymap["buffer.cursor.above.big"], "18k" },
		{ keymap["buffer.cursor.below"], "9j" },
		{ keymap["buffer.line.indent"], ">gv" },
		{ keymap["buffer.cursor.below.big"], "18j" },
		{ keymap["buffer.line.outdent"], "<gv" },
		{
			keymap["buffer.line.new.down"],
			"mm<Esc>:'>put _<CR>`mgv",
		},
		{
			keymap["buffer.line.new.up"],
			"mm<Esc>:'<put! _<CR>`mgv",
		},
		{ keymap["buffer.line.bubble.up"], ":m '>+1<CR>gv=gv" },
		{ keymap["buffer.line.bubble.down"], ":m '<-2<CR>gv=gv" },
		{
			keymap["buffer.line.duplicate.up"],
			"mmy'<P`mgv",
		},
		{
			keymap["buffer.line.duplicate.down"],
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
		{ keymap["buffer.line.indent"], "<C-t>" },
		{ keymap["buffer.line.outdent"], "<C-d>" }
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
	require("ibl").setup()
end

function Editor.setup_pairs()
	-- Autopairs
	require("nvim-autopairs").setup({
		disable_filetype = { "TelescopePrompt", "vim" },
	})
end

-- Returns the current word under the cursor
function Editor:cword()
	return vim.fn.expand("<cword>")
end

return Editor:new()
