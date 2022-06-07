local config = require("config")
local key = require("_shared.key")

-- User settings
local settings_file = vim.fn.stdpath("config") .. "/settings.lua"
local settings = vim.fn.filereadable(settings_file) == 1 and dofile(settings_file) or nil

-- INITIALISATION
config:init(settings)

-- KEYMAPS
local modules = config:list_modules()

-- Editor
key.nmap(
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
	{ "<leader><space>", modules.editor.buffer.comment_line }
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
	{ "<C-Tab>", "<C-t>" },
	{ "<C-S-Tab>", "<C-d>" }
)

key.vmap(
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
	{ "<leader><space>", modules.editor.buffer.comment_selection }
)

-- Exiting term mode using esc
key.tmap({ "<Esc>", "<C-\\><C-n>" })

-- Windows and buffers

key.nmap(
	{ "<C-t>", "<Cmd>tabnew<Cr>" },
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
	{ "<leader>Q", "<Cmd>:q!<Cr>" }
)

key.cmap({ "<A-h>", "<Left>" }, { "<A-l>", "<Right>" }, { "<A-k>", "<Up>" }, { "<A-j>", "<Down>" })

key.tmap(
	-- Moving the cursor when in insert
	{ "<A-h>", "<Left>" },
	{ "<A-l>", "<Right>" },
	{ "<A-k>", "<Up>" },
	{ "<A-j>", "<Down>" }
)

-- Search

key.nmap(
	-- Clearing search highlighting
	{ "<Esc>", ":noh<CR><Esc>" },
	-- { "<BS>", ":noh<CR>" },
	-- Keep search results centred
	{ "n", "nzzzv" },
	{ "N", "Nzzzv" },
	-- finder
	{ "<C-p>", modules.finder.find_files },
	{ "<C-S-p>", modules.finder.find_commands },
	{ "<C-S-e>", modules.finder.find_projects },
	{ "<leader>f", modules.finder.find_in_buffer },
	{ "<leader>F", modules.finder.find_in_directory },
	-- { "<C-y>", modules.finder.find_yanks },
	{ "<F1>", modules.finder.find_in_documentation },
	{ "<C-z>", modules.finder.find_spelling },
	{ "<C-b>", modules.finder.find_buffers }
	-- { "<C-t>", modules.finder.find_todos }
)

-- File Explorer

key.nmap({ "<leader>e", modules.interface.project_explorer.toggle })

-- Git

key.nmap(
	{ "gb", modules.git.blame },
	{ "gl", modules.git.log },
	{ "gd", modules.git.diff },
	{ "gm", modules.git.mergetool },
	{ "gh", modules.git.show_hunk_preview },
	{ "]c", modules.git.next_hunk_preview("]c") },
	{ "[c", modules.git.prev_hunk_preview("[c") }
)

-- Lists

key.nmap(
	{ "<C-c>", modules.finder.list.toggle },
	{ "<leader>c", modules.finder.list.jump },
	{ "<C-]>", modules.finder.list.next },
	{ "<C-[>", modules.finder.list.prev }
)

-- Terminal

key.nmap({
	"<C-g>",
	modules.terminal.job({ "lazygit" }),
})
