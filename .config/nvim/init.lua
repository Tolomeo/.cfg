require("options")
local config = require("config")
local key = require("utils.key")

-- INITIALISATION
config:setup({
	color_scheme = "edge",
})

-- KEYMAPS
local modules = config.modules

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
	{ "<leader>S", ":%s/<C-r><C-w>//gI<left><left><left>" },
	-- Replace word under cursor in line
	{ "<leader>s", ":s/<C-r><C-w>//gI<left><left><left>" },
	-- Adding blank lines with cr
	{ "<leader>O", "mm:put! _<CR>`m" },
	{ "<leader>o", "mm:put _<CR>`m" },
	-- Cleaning a line
	{ "<leader>d", ":.s/\v^.*$/<Cr>:noh<Cr>" },
	-- Commenting lines
	{ "<leader><space>", modules.editor.comment_line }
)

key.imap(
	-- Arrows are disabled
	{ "<left>", "<nop>" },
	{ "<right>", "<nop>" },
	{ "<up>", "<nop>" },
	{ "<down>", "<nop>" },
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
	-- Make visual yanks place the cursor back where started
	{ "y", "ygv<Esc>" },
	-- Adding blank lines
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
	{ "<leader><space>", modules.editor.comment_selection }
)

-- Exiting term mode using esc
key.tmap({ "<Esc>", "<C-\\><C-n>" })

-- Windows and buffers

key.nmap(
	-- Windows navigation
	{ "<C-n>", "<C-w>w" },
	{ "<C-p>", "<C-w>W" },
	-- Exchange current window with the next one
	{ "<C-;>", "<C-w>x" },
	-- Resizing the current window
	{ "<C-j>", ":resize -3<Cr>" },
	{ "<C-h>", ":vertical :resize -3<Cr>" },
	{ "<C-l>", ":vertical :resize +3<Cr>" },
	{ "<C-k>", ":resize +3<Cr>" },
	-- Moving windows
	{ "<C-A-j>", "<C-w>J" },
	{ "<C-A-h>", "<C-w>H" },
	{ "<C-A-l>", "<C-w>L" },
	{ "<C-A-k>", "<C-w>K" },
	-- Resetting windows size
	{ "<C-=>", "<C-w>=" },
	-- Maximising current window size
	{ "<C-f>", "<C-w>_<C-w>|" },
	-- Buffers navigation
	{ "<A-Tab>", ":bnext<Cr>" },
	{ "<A-S-Tab>", ":bprev<Cr>" }
)

key.imap(
	-- Navigation
	{ "<C-n>", "<Esc><C-w>w" },
	{ "<C-p>", "<Esc><C-w>W" },
	-- Exchange with next window
	{ "<C-;>", "<Esc><C-w>x" },
	-- Resizing
	{ "<C-j>", "<Esc>:resize -3<Cr>gi" },
	{ "<C-h>", "<Esc>:vertical :resize -3<Cr>gi" },
	{ "<C-l>", "<Esc>:vertical :resize +3<Cr>gi" },
	{ "<C-k>", "<Esc>:resize +3<Cr>gi" },
	-- Moving windows
	{ "<C-A-j>", "<Esc><C-w>Jgi" },
	{ "<C-A-h>", "<Esc><C-w>Hgi" },
	{ "<C-A-l>", "<Esc><C-w>Lgi" },
	{ "<C-A-k>", "<Esc><C-w>Kgi" },
	-- Resetting windows size
	{ "<C-=>", "<Esc><C-w>=gi" },
	-- Maximising current window size
	{ "<C-f>", "<Esc><C-w>_<C-w>|gi" },
	-- Buffers navigation
	{ "<A-Tab>", "<Esc>:bnext<Cr>" },
	{ "<A-S-Tab>", "<Esc>:bprev<Cr>" }
)

key.vmap(
	-- Navigation
	{ "<C-n>", "<Esc><C-w>w" },
	{ "<C-p>", "<Esc><C-w>W" },
	-- Exchange with next window
	{ "<C-;>", "<Esc><C-w>x" },
	-- Resizing
	{ "<C-j>", "<Esc>:resize -3<Cr>gv" },
	{ "<C-h>", "<Esc>:vertical :resize -3<Cr>gv" },
	{ "<C-l>", "<Esc>:vertical :resize +3<Cr>gv" },
	{ "<C-k>", "<Esc>:resize +3<Cr>gv" },
	-- Moving windows
	{ "<C-A-j>", "<Esc><C-w>Jgv" },
	{ "<C-A-h>", "<Esc><C-w>Hgv" },
	{ "<C-A-l>", "<Esc><C-w>Lgv" },
	{ "<C-A-k>", "<Esc><C-w>Kgv" },
	-- Resetting windows size
	{ "<C-f>", "<Esc><C-w>=gv" },
	-- Maximising current window size
	{ "<C-+>", "<Esc><C-w>_<C-w>|gv" },
	-- Buffers navigation
	{ "<A-Tab>", "<Esc>:bnext<Cr>" },
	{ "<A-S-Tab>", "<Esc>:bprev<Cr>" }
)

key.tmap(
	-- Navigation
	{ "<C-n>", "<C-\\><C-n><C-w>w" },
	{ "<C-p>", "<C-\\><C-n><C-w>W" },
	-- Exchange with next window
	{ "<C-;>", "<C-\\><C-n><C-w>x" },
	-- Resizing
	{ "<C-j>", "<C-\\><C-n>:resize -3<Cr>i" },
	{ "<C-h>", "<C-\\><C-n>:vertical :resize -3<Cr>i" },
	{ "<C-l>", "<C-\\><C-n>:vertical :resize +3<Cr>i" },
	{ "<C-k>", "<C-\\><C-n>:resize +3<Cr>i" },
	-- Moving windows
	{ "<C-A-j>", "<C-\\><C-n><C-w>Ji" },
	{ "<C-A-h>", "<C-\\><C-n><C-w>Hi" },
	{ "<C-A-l>", "<C-\\><C-n><C-w>Li" },
	{ "<C-A-k>", "<C-\\><C-n><C-w>Ki" },
	-- Resetting windows size
	{ "<C-f>", "<C-\\><C-n><C-w>=i" },
	-- Maximising current window size
	{ "<C-+>", "<C-\\><C-n><C-w>_<C-w>|i" },
	-- Buffers navigation
	{ "<A-Tab>", "<C-\\><C-n>:bnext<Cr>" },
	{ "<A-S-Tab>", "<C-\\><C-n>:bprev<Cr>" }
)

-- Buffers

key.nmap(
	-- write only if changed
	{ "<Leader>w", ":up<CR>", silent = false },
	-- quit (or close window)
	{ "<Leader>q", ":q<CR>" },
	-- Discard all changed buffers & quit
	{ "<Leader>Q", ":qall!<CR>" },
	-- write all and quit
	{ "<Leader>W", ":wqall<CR>", silent = false }
)

-- Search

key.nmap(
	-- Clearing search highlighting
	{ "<BS>", ":noh<CR>" },
	-- Keep search results centred
	{ "n", "nzzzv" },
	{ "N", "Nzzzv" },
	-- finder
	{ "<C-p>", modules.finder.find_files },
	{ "<C-S-p>", modules.finder.find_commands },
	{ "<C-S-e>", modules.finder.find_projects },
	{ "<leader>f", modules.finder.find_in_buffer },
	{ "<leader>F", modules.finder.find_in_files },
	-- { "<C-y>", modules.finder.find_yanks },
	{ "<F1>", modules.finder.find_in_documentation },
	{ "<C-z>", modules.finder.find_spelling },
	{ "<C-b>", modules.finder.find_buffers },
	{ "<C-t>", modules.finder.find_todos }
)

-- File Explorer

key.nmap({ "<leader>E", modules.interface.toggle_tree }, { "<leader>e", modules.interface.focus_tree })

-- Intellisense

key.nmap(
	{ "<C-Space>", modules.intellisense.open_code_actions },
	{ "<leader>B", modules.intellisense.eslint_fix },
	{ "<leader>gd", modules.intellisense.go_to_definition },
	{ "<leader>gt", modules.intellisense.go_to_type_definition },
	{ "<leader>gi", modules.intellisense.go_to_implementation },
	{ "<leader>K", modules.intellisense.show_references },
	{ "<leader>k", modules.intellisense.show_symbol_doc },
	{ "<leader>r", modules.intellisense.rename_symbol },
	{ "<leader>dl", modules.intellisense.show_diagnostics },
	{ "<leader>[d", modules.intellisense.next_diagnostic },
	{ "<leader>]d", modules.intellisense.prev_diagnostic },
	{ "<leader>b", modules.intellisense.format }
)

key.imap(
	{ "<C-Space>", modules.intellisense.open_suggestions },
	{ "<TAB>", modules.intellisense.next_suggestion("<TAB>") },
	{ "<S-TAB>", modules.intellisense.prev_suggestion },
	{ "<CR>", modules.intellisense.confirm_suggestion }
)

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
	{ "<C-c>", modules.quickfix.toggle },
	{ "<leader>c", modules.quickfix.jump },
	-- TODO: C-n is synonim for ESC, so if used it clashes with ESC mappings
	{ "<C-]>", modules.quickfix.next },
	{ "<C-[>", modules.quickfix.prev }
)
