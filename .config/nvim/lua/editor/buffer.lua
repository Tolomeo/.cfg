local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local register = require("_shared.register")

local default_settings = {}

local Buffer = {}

local default_keymaps = {
	-- Buffers navigation
	["next"] = "<A-Tab>",
	["prev"] = "<A-S-Tab>",
	-- write only if changed
	["save"] = "<leader>w",
	-- write all and quit
	["save.all"] = "<leader>W",
	-- quit (or close window)
	["close"] = "<leader>q",
	-- Delete buffer
	["close.delete"] = "<leader>Q",
	-- Left
	["cursor.prev"] = "<S-h>",
	["cursor.prev.big"] = "<A-S-h>",
	-- Right
	["cursor.next"] = "<S-l>",
	["cursor.next.big"] = "<A-S-l>",
	-- Up
	["cursor.above"] = "<S-k>",
	["cursor.above.big"] = "<A-S-k>",
	-- Down
	["cursor.below"] = "<S-j>",
	["cursor.below.big"] = "<A-S-j>",
	-- Controlling indentation
	["line.indent"] = "<Tab>",
	["line.outdent"] = "<S-Tab>",
	-- Join lines and restore cursor location
	["line.join"] = "<leader>j",
	-- Line bubbling
	["line.bubble.up"] = "<A-j>",
	["line.bubble.down"] = "<A-k>",
	-- Duplicating lines up and down
	["line.duplicate.up"] = "<leader>P",
	["line.duplicate.down"] = "<leader>p",
	-- Adding blank lines with cr
	["line.new.up"] = "<leader>O",
	["line.new.down"] = "<leader>o",
	-- Cleaning a line
	["line.clear"] = "<leader>d",
	-- Commenting lines
	["line.comment"] = "<leader><space>",
	-- Replace word under cursor in buffer
	["word.substitute"] = "<leader>S",
	-- Replace word under cursor in line
	["word.substitute.line"] = "<leader>s",
	-- Because we are mapping S-Tab to indent, now C-i indents too so we need to recover it
	["jump.out"] = "<C-S-o>",
	["jump.in"] = "<C-o>",
	-- Repeating last macro with Q
	["macro.repeat.last"] = "Q",
	-- Easy select all of file
	["select.all"] = "<leader>%",
}

Buffer.plugins = {
	-- Indentation guides
	"lukas-reineke/indent-blankline.nvim",
	-- Comments
	"b3nj5m1n/kommentary",
	"JoosepAlviste/nvim-ts-context-commentstring",
	-- Auto closing tags
	"windwp/nvim-ts-autotag",
	-- Autoclosing pair of chars
	"windwp/nvim-autopairs",
	-- Parentheses, brackets, quotes, XML tags
	"tpope/vim-surround",
	-- Change case and handles variants of a word
	"tpope/vim-abolish",
	-- additional operator targets
	"wellle/targets.vim",
	-- Highlighting command ranges
	{ "winston0410/range-highlight.nvim", requires = "winston0410/cmd-parser.nvim" },
	-- Highlighting color strings
	"norcalli/nvim-colorizer.lua",
}

Buffer.setup = function(settings)
	settings = vim.tbl_deep_extend("force", default_settings, settings)

	Buffer._setup_keymaps(settings)
	Buffer._setup_plugins()
	Buffer._setup_commands()
end

Buffer._setup_keymaps = function(settings)
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

	-- Editor
	key.nmap(
		{ default_keymaps["next"], ":bnext<Cr>" },
		{ default_keymaps["prev"], ":bprev<Cr>" },
		{ default_keymaps["save"], "<Cmd>up<Cr>", silent = false },
		{ default_keymaps["save.all"], "<Cmd>wa<Cr>", silent = false },
		{ default_keymaps["close"], "<Cmd>q<Cr>" },
		{ default_keymaps["close.delete"], "<Cmd>bdelete<Cr>" },
		{ default_keymaps["cursor.prev"], "b" },
		{ default_keymaps["cursor.prev.big"], "B" },
		{ default_keymaps["cursor.next"], "w" },
		{ default_keymaps["cursor.next.big"], "W" },
		{ default_keymaps["cursor.above"], "9k" },
		{ default_keymaps["cursor.above.big"], "18k" },
		{ default_keymaps["cursor.below"], "9j" },
		{ default_keymaps["cursor.below.big"], "18j" },
		{ default_keymaps["line.indent"], ">>" },
		{ default_keymaps["line.outdent"], "<<" },
		{ default_keymaps["line.join"], "mjJ`j" },
		{ default_keymaps["line.bubble.up"], ":m .+1<CR>==" },
		{ default_keymaps["line.bubble.down"], ":m .-2<CR>==" },
		{ default_keymaps["line.duplicate.up"], "mayyP`a" },
		{ default_keymaps["line.duplicate.down"], "mayyp`a" },
		{ default_keymaps["line.new.up"], "mm:put! _<CR>`m" },
		{ default_keymaps["line.new.down"], "mm:put _<CR>`m" },
		{ default_keymaps["line.clear"], ":.s/\v^.*$/<Cr>:noh<Cr>" },
		{ default_keymaps["line.comment"], Buffer.comment_line },
		{ default_keymaps["word.substitute"], ":%s/<C-r><C-w>//gI<left><left><left>", silent = false },
		{ default_keymaps["word.substitute.line"], ":s/<C-r><C-w>//gI<left><left><left>", silent = false },
		{ default_keymaps["jump.in"], "<C-i>" },
		{ default_keymaps["jump.out"], "<C-o>" },
		{ default_keymaps["macro.repeat.last"], "@@" },
		{ default_keymaps["select.all"], "ggVG<c-$>" }
	)

	key.vmap(
		-- Make visual yanks remain in visual mode
		{ "y", "ygv" },
		-- Arrows are disabled
		{ "<Left>", "<nop>" },
		{ "<Right>", "<nop>" },
		{ "<Up>", "<nop>" },
		{ "<Down>", "<nop>" },
		{ default_keymaps["cursor.prev"], "b" },
		{ default_keymaps["cursor.prev.big"], "B" },
		{ default_keymaps["cursor.next"], "w" },
		{ default_keymaps["cursor.next.big"], "W" },
		{ default_keymaps["cursor.above"], "9k" },
		{ default_keymaps["cursor.above.big"], "18k" },
		{ default_keymaps["cursor.below"], "9j" },
		{ default_keymaps["line.indent"], ">gv" },
		{ default_keymaps["cursor.below.big"], "18j" },
		{ default_keymaps["line.outdent"], "<gv" },
		{
			default_keymaps["line.new.down"],
			"mm<Esc>:'>put _<CR>`mgv",
		},
		{
			default_keymaps["line.new.up"],
			"mm<Esc>:'<put! _<CR>`mgv",
		},
		{ default_keymaps["line.bubble.up"], ":m '>+1<CR>gv=gv" },
		{ default_keymaps["line.bubble.down"], ":m '<-2<CR>gv=gv" },
		{
			default_keymaps["line.duplicate.up"],
			"mmy'<P`mgv",
		},
		{
			default_keymaps["line.duplicate.down"],
			"mmy'>p`mgv",
		},
		{ default_keymaps["line.clear"], "mm<Esc>:'<,'>s/\v^.*$/<Cr>:noh<Cr>`mgv" },
		{ default_keymaps["line.comment"], Buffer.comment_selection }
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
		{ default_keymaps["line.indent"], "<C-t>" },
		{ default_keymaps["line.outdent"], "<C-d>" }
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

Buffer._setup_plugins = function()
	-- Autotag
	require("nvim-ts-autotag").setup()

	-- Autopairs
	require("nvim-autopairs").setup({
		disable_filetype = { "TelescopePrompt", "vim" },
	})

	--Map blankline
	require("indent_blankline").setup({
		space_char_blankline = " ",
		show_current_context = true,
		show_current_context_start = true,
		use_treesitter = true,
		strict_tabs = true,
		context_char = "┃",
	})

	-- Kommentary
	vim.g.kommentary_create_default_mappings = false

	-- Colorizer
	require("colorizer").setup()

	-- Range highlight
	require("range-highlight").setup()
end

Buffer._setup_commands = function()
	-- Yanks visual feedback
	au.group({
		"OnTextYanked",
		{
			{
				"TextYankPost",
				"*",
				function()
					vim.highlight.on_yank()
				end,
			},
		},
	})
end

-- vim.api.nvim_set_keymap("n", "<leader>/", "<Plug>kommentary_line_default", {})
function Buffer.comment_line()
	key.input("<Plug>kommentary_line_default", "m")
end

-- vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {}
function Buffer.comment_selection()
	key.input("<Plug>kommentary_visual_default", "m")
end

-- Returns the current word under the cursor
function Buffer.cword()
	return vim.call("expand", "<cword>")
end

return Module:new(Buffer)
