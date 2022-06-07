local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local register = require("_shared.register")

local default_settings = {
	keymaps = {
		["delete"] = "<C-q>",
	},
}

local Buffer = {}

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
		-- Buffers navigation
		{ "<A-Tab>", ":bnext<Cr>" },
		{ "<A-S-Tab>", ":bprev<Cr>" },
		-- write only if changed
		{ "<leader>w", "<Cmd>up<Cr>", silent = false },
		-- write all and quit
		{ "<leader>W", "<Cmd>w!<Cr>", silent = false },
		-- quit (or close window)
		{ "<leader>q", "<Cmd>:q<Cr>" },
		-- Discard all changed buffers & quit
		{ "<leader>Q", "<Cmd>:q!<Cr>" },
		-- Delete buffer
		{ settings.keymaps["delete"], "<Cmd>bdelete<Cr>" },
		-- Multipliers
		-- Left
		{ "<S-h>", "b" },
		{ "<A-S-h>", "B" },
		-- Right
		{ "<S-l>", "w" },
		{ "<A-S-l>", "W" },
		-- Up
		{ "<S-k>", "9k" },
		{ "<A-S-k>", "18k" },
		-- Down
		{ "<S-j>", "9j" },
		{ "<A-S-j>", "18j" },
		-- Controlling indentation
		{ "<Tab>", ">>" },
		{ "<S-Tab>", "<<" },
		-- Because we are mapping S-Tab to indent, now C-i indents too so we need to recover it
		{ "<C-S-o>", "<C-i>" },
		-- Repeating last macro with Q
		{ "Q", "@@" },
		-- Easy select all of file
		{ "<leader>%", "ggVG<c-$>" },
		-- Join lines and restore cursor location
		{ "<leader>j", "mjJ`j" },
		-- Line bubbling
		{ "<A-j>", ":m .+1<CR>==" },
		{ "<A-k>", ":m .-2<CR>==" },
		-- Duplicating lines up and down
		{ "<leader>P", "mayyP`a" },
		{ "<leader>p", "mayyp`a" },
		-- Replace word under cursor in buffer
		{ "<leader>S", ":%s/<C-r><C-w>//gI<left><left><left>", silent = false },
		-- Replace word under cursor in line
		{ "<leader>s", ":s/<C-r><C-w>//gI<left><left><left>", silent = false },
		-- Adding blank lines with cr
		{ "<leader>O", "mm:put! _<CR>`m" },
		{ "<leader>o", "mm:put _<CR>`m" },
		-- Cleaning a line
		{ "<leader>d", ":.s/\v^.*$/<Cr>:noh<Cr>" },
		-- Commenting lines
		{ "<leader><space>", Buffer.comment_line }
	)

	key.vmap(
		-- delete buffer
		{ settings.keymaps["delete"], "<Cmd>bdelete<Cr>" },
		-- Make visual yanks remain in visual mode
		{ "y", "ygv" },
		-- Arrows are disabled
		{ "<Left>", "<nop>" },
		{ "<Right>", "<nop>" },
		{ "<Up>", "<nop>" },
		{ "<Down>", "<nop>" },
		-- Multipliers
		-- Left
		{ "<S-h>", "b" },
		{ "<A-S-h>", "B" },
		-- Right
		{ "<S-l>", "w" },
		{ "<A-S-l>", "W" },
		-- Up
		{ "<S-k>", "9k" },
		{ "<A-S-k>", "18k" },
		-- Down
		{ "<S-j>", "9j" },
		{ "<A-S-j>", "18j" },
		-- Indentation
		{ "<Tab>", ">gv" },
		{ "<S-Tab>", "<gv" },
		-- adding blank lines
		{
			"<leader>o",
			"mm<Esc>:'>put _<CR>`mgv",
		},
		{
			"<leader>O",
			"mm<Esc>:'<put! _<CR>`mgv",
		},
		-- Bubbling
		{ "<A-j>", ":m '>+1<CR>gv=gv" },
		{ "<A-k>", ":m '<-2<CR>gv=gv" },
		-- Duplicating selection up and down
		{
			"<leader>P",
			"mmy'<P`mgv",
		},
		{
			"<leader>p",
			"mmy'>p`mgv",
		},
		-- Cleaning selected lines
		{ "<leader>d", "mm<Esc>:'<,'>s/\v^.*$/<Cr>:noh<Cr>`mgv" },
		-- Commenting lines
		{ "<leader><space>", Buffer.comment_selection }
	)

	key.imap(
		-- Delete buffer
		{ settings.keymaps["delete"], "<Cmd>bdelete<Cr>" },
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
		{ "<C-Tab>", "<C-t>" },
		{ "<C-S-Tab>", "<C-d>" }
	)

	key.cmap({ "<A-h>", "<Left>" }, { "<A-l>", "<Right>" }, { "<A-k>", "<Up>" }, { "<A-j>", "<Down>" })

	key.tmap(
		-- Delete buffer
		{ settings.keymaps["delete"], "<Cmd>bdelete<Cr>" },
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
