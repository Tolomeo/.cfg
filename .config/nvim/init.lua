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
	-- key.map { "n", "J", "mjJ`j" }
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
	{ "<leader><space>", modules.editor.text.comment_line }
)

key.imap(
	-- Arrows are disabled
	{ "<Left>", "<nop>" },
	{ "<Right>", "<nop>" },
	{ "<Up>", "<nop>" },
	{ "<Down>", "<nop>" },
	-- Move cursor within insert mode
	-- { "<C-h>", "<Left>" },
	-- { "<C-l>", "<Right>" },
	-- { "<C-k>", "<Up>" },
	-- { "<C-j>", "<Down>" },
	-- Indentation
	{ "<C-Tab>", "<C-t>" },
	{ "<C-S-Tab>", "<C-d>" }
)

key.vmap(
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
	{ "<leader><space>", modules.editor.text.comment_selection }
)

-- Exiting term mode using esc
key.tmap({ "<Esc>", "<C-\\><C-n>" })

-- Windows and buffers

key.nmap(
	-- Windows navigation
	{ "<C-h>", "<C-w>h" },
	{ "<C-j>", "<C-w>j" },
	{ "<C-k>", "<C-w>k" },
	{ "<C-l>", "<C-w>l" },
	{ "<C-n>", "<C-w>w" },
	{ "<C-p>", "<C-w>W" },
	-- Exchange current window with the next one
	{ "<C-;>", "<C-w>x" },
	-- Resizing the current window
	{ "<C-A-j>", ":resize -3<Cr>" },
	{ "<C-A-h>", ":vertical :resize -3<Cr>" },
	{ "<C-A-l>", ":vertical :resize +3<Cr>" },
	{ "<C-A-k>", ":resize +3<Cr>" },
	-- Moving windows
	{ "<C-S-j>", "<C-w>J" },
	{ "<C-S-h>", "<C-w>H" },
	{ "<C-S-l>", "<C-w>L" },
	{ "<C-S-k>", "<C-w>K" },
	-- Resetting windows size
	{ "<C-=>", "<C-w>=" },
	-- Maximising current window size
	{ "<C-f>", "<C-w>_<C-w>|" },
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
	-- Splits
	{ "<C-q>", "<Cmd>bdelete<Cr>" },
	{ "<C-x>", "<Cmd>split<Cr>" },
	{ "<C-y>", "<Cmd>vsplit<Cr>" },
	{ "<C-t>", "<Cmd>tabnew<Cr>" }
)

key.imap(
	-- Navigation
	{ "<C-h>", "<Esc><C-w>h" },
	{ "<C-j>", "<Esc><C-w>j" },
	{ "<C-k>", "<Esc><C-w>k" },
	{ "<C-l>", "<Esc><C-w>l" },
	{ "<C-n>", "<Esc><C-w>w" },
	{ "<C-p>", "<Esc><C-w>W" },
	-- Exchange with next window
	{ "<C-;>", "<Esc><C-w>x" },
	-- Resizing
	{ "<C-A-j>", "<Esc>:resize -3<Cr>gi" },
	{ "<C-A-h>", "<Esc>:vertical :resize -3<Cr>gi" },
	{ "<C-A-l>", "<Esc>:vertical :resize +3<Cr>gi" },
	{ "<C-A-k>", "<Esc>:resize +3<Cr>gi" },
	-- Moving windows
	{ "<C-S-j>", "<Esc><C-w>Jgi" },
	{ "<C-S-h>", "<Esc><C-w>Hgi" },
	{ "<C-S-l>", "<Esc><C-w>Lgi" },
	{ "<C-S-k>", "<Esc><C-w>Kgi" },
	-- Resetting windows size
	{ "<C-=>", "<Esc><C-w>=gi" },
	-- Maximising current window size
	{ "<C-f>", "<Esc><C-w>_<C-w>|gi" },
	-- Buffers navigation
	{ "<A-Tab>", "<Esc>:bnext<Cr>" },
	{ "<A-S-Tab>", "<Esc>:bprev<Cr>" },
	-- Splits
	{ "<C-q>", "<Esc>:bdelete<Cr>" },
	{ "<C-x>", "<Esc>:split<Cr>" },
	{ "<C-y>", "<Esc>:vsplit<Cr>" },
	{ "<C-t>", "<Esc>:tabnew<Cr>" }
)

key.vmap(
	-- Navigation
	{ "<C-h>", "<Esc><C-w>h" },
	{ "<C-j>", "<Esc><C-w>j" },
	{ "<C-k>", "<Esc><C-w>k" },
	{ "<C-l>", "<Esc><C-w>l" },
	{ "<C-n>", "<Esc><C-w>w" },
	{ "<C-p>", "<Esc><C-w>W" },
	-- Exchange with next window
	{ "<C-;>", "<Esc><C-w>x" },
	-- Resizing
	{ "<C-A-j>", "<Esc>:resize -3<Cr>gv" },
	{ "<C-A-h>", "<Esc>:vertical :resize -3<Cr>gv" },
	{ "<C-A-l>", "<Esc>:vertical :resize +3<Cr>gv" },
	{ "<C-A-k>", "<Esc>:resize +3<Cr>gv" },
	-- Moving windows
	{ "<C-S-j>", "<Esc><C-w>Jgv" },
	{ "<C-S-h>", "<Esc><C-w>Hgv" },
	{ "<C-S-l>", "<Esc><C-w>Lgv" },
	{ "<C-S-k>", "<Esc><C-w>Kgv" },
	-- Resetting windows size
	{ "<C-f>", "<Esc><C-w>=gv" },
	-- Maximising current window size
	{ "<C-+>", "<Esc><C-w>_<C-w>|gv" },
	-- Buffers navigation
	{ "<A-Tab>", "<Esc>:bnext<Cr>" },
	{ "<A-S-Tab>", "<Esc>:bprev<Cr>" },
	-- Splits
	{ "<C-q>", "<Esc>:bdelete<Cr>" },
	{ "<C-x>", "<Esc>:split<Cr>" },
	{ "<C-y>", "<Esc>:vsplit<Cr>" },
	{ "<C-t>", "<Esc>:tabnew<Cr>" }
)

key.tmap(
	-- Navigation
	{ "<C-h>", "<C-\\><C-n><C-w>h" },
	{ "<C-j>", "<C-\\><C-n><C-w>j" },
	{ "<C-k>", "<C-\\><C-n><C-w>k" },
	{ "<C-l>", "<C-\\><C-n><C-w>l" },
	{ "<C-n>", "<C-\\><C-n><C-w>w" },
	{ "<C-p>", "<C-\\><C-n><C-w>W" },
	-- Exchange with next window
	{ "<C-;>", "<C-\\><C-n><C-w>x" },
	-- Resizing
	{ "<C-A-j>", "<C-\\><C-n>:resize -3<Cr>i" },
	{ "<C-A-h>", "<C-\\><C-n>:vertical :resize -3<Cr>i" },
	{ "<C-A-l>", "<C-\\><C-n>:vertical :resize +3<Cr>i" },
	{ "<C-A-k>", "<C-\\><C-n>:resize +3<Cr>i" },
	-- Moving windows
	{ "<C-S-j>", "<C-\\><C-n><C-w>Ji" },
	{ "<C-S-h>", "<C-\\><C-n><C-w>Hi" },
	{ "<C-S-l>", "<C-\\><C-n><C-w>Li" },
	{ "<C-S-k>", "<C-\\><C-n><C-w>Ki" },
	-- Resetting windows size
	{ "<C-f>", "<C-\\><C-n><C-w>=i" },
	-- Maximising current window size
	{ "<C-+>", "<C-\\><C-n><C-w>_<C-w>|i" },
	-- Buffers navigation
	{ "<A-Tab>", "<C-\\><C-n>:bnext<Cr>" },
	{ "<A-S-Tab>", "<C-\\><C-n>:bprev<Cr>" },
	-- Splits
	{ "<C-q>", "<C-c><C-\\><C-n>:bdelete!<Cr>" },
	{ "<C-x>", "<C-\\><C-n>:split<Cr>" },
	{ "<C-y>", "<C-\\><C-n>:vsplit<Cr>" },
	{ "<C-t>", "<C-\\><C-n>:tabnew<Cr>" }
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
