require("options")
local config = require("config")
local key = require("utils.key")

-- INITIALISATION

config:setup({
	color_scheme = "rose-pine",
})

-- KEYMAPS
local modules = config.modules

-- Editor

key.nmap(
	-- Multipliers
	-- Left
	{ "<A-h>", "b" },
	{ "<A-S-h>", "B" },
	-- Right
	{ "<A-l>", "w" },
	{ "<A-S-l>", "W" },
	-- Up
	{ "<A-k>", "9k" },
	{ "<A-S-k>", "18k" },
	-- Down
	{ "<A-j>", "9j" },
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
	{ "<C-j>", modules.editor.move_line_down },
	{ "<C-k>", modules.editor.move_line_up },
	-- Duplicating lines up and down
	{ "<C-S-k>", "mayyP`a" },
	{ "<C-S-j>", "mayyp`a" },
	-- Replace word under cursor in buffer
	{ "<leader>s%", modules.editor.replace_current_word_in_buffer },
	-- Replace word under cursor in line
	{ "<leader>ss", modules.editor.replace_current_word_in_line },
	-- Commenting lines
	{ "<leader><space>", modules.editor.comment_line },
	-- Toggling booleans
	{ "<leader>~", modules.editor.toggle_boolean },
	-- Adding blank lines with cr
	{ "<CR>", "mm:put! _<CR>`m" },
	{ "<S-CR>", "mm:put _<CR>`m" }
)

key.imap(
	-- Arrows are disabled in insert mode
	{ "<left>", "<nop>" },
	{ "<right>", "<nop>" },
	{ "<up>", "<nop>" },
	{ "<down>", "<nop>" },
	-- Moving lines up and down
	-- see https://vim.fandom.com/wiki/Moving_lines_up_or_down#Reordering_up_to_nine_lines
	{
		"<A-j>",
		function()
			key.input("<Esc>")
			modules.editor.move_line_down()
			key.input("gi")
		end,
	},
	{
		"<A-k>",
		function()
			key.input("<Esc>")
			modules.editor.move_line_up()
			key.input("gi")
		end,
	},
	-- Indentation
	{ "<C-Tab>", "<C-t>" },
	{ "<C-S-Tab>", "<C-d>" },
	-- Adding blank lines with cr
	{
		"<C-CR>",
		function()
			key.input("<Esc>")
			key.input(":put! _<CR>")
			key.input("gi")
		end,
	},
	{
		"<C-S-CR>",
		function()
			key.input("<Esc>")
			key.input(":put _<CR>")
			key.input("gi")
		end,
	},
	-- Duplicating lines up and down
	{
		"<C-S-k>",
		function()
			key.input("<Esc>")
			key.input("mayyP`a")
			key.input("gi")
		end,
	},
	{
		"<C-S-j>",
		function()
			key.input("<Esc>")
			key.input("mmyyp`m")
			key.input("gi")
		end,
	}
)

key.vmap(
	-- Multipliers
	-- Left
	{ "<A-h>", "b" },
	{ "<A-S-h>", "B" },
	-- Right
	{ "<A-l>", "w" },
	{ "<A-S-l>", "W" },
	-- Up
	{ "<A-k>", "9k" },
	{ "<A-S-k>", "18k" },
	-- Down
	{ "<A-j>", "9j" },
	{ "<A-S-j>", "18j" },
	-- Indentation
	{ "<Tab>", ">gv" },
	{ "<S-Tab>", "<gv" },
	-- Make visual yanks place the cursor back where started
	{ "y", "ygv<Esc>" },
	-- Bubbling
	{ "<C-j>", modules.editor.move_selection_down },
	{ "<C-k>", modules.editor.move_selection_up },
	{ "<leader><space>", modules.editor.comment_selection },
	-- Adding blank lines with cr
	{
		"<CR>",
		function()
			key.input("mm<Esc>")
			key.input(":'<put! _<CR>")
			key.input("`mgv")
		end,
	},
	{
		"<S-CR>",
		function()
			key.input("mm<Esc>")
			key.input(":'>put _<CR>")
			key.input("`mgv")
		end,
	},
	-- Duplicating selection up and down
	{
		"<C-S-k>",
		function()
			key.input("mm")
			key.input("y'<P")
			key.input("`mgv")
		end,
	},
	{
		"<C-S-j>",
		function()
			key.input("mm")
			key.input("y'>p")
			key.input("`mgv")
		end,
	}
)

-- Exiting term mode using esc
key.tmap({ "<Esc>", "<C-\\><C-n>" })

-- Windows

key.nmap(
	-- Navigation
	{ "<C-A-h>", "<C-w>h" },
	{ "<C-A-l>", "<C-w>l" },
	{ "<C-A-k>", "<C-w>k" },
	{ "<C-A-j>", "<C-w>j" }
	-- Split mappings
	-- { "<Leader>;", "<C-W>R" },
	-- { "<Leader>[", "<C-W>_" },
	-- { "<Leader>]", "<C-W>|" },
	-- { "<Leader>=", "<C-W>=" }
)

key.imap(
	-- Navigation
	{ "<C-A-h>", "<Esc><C-w>h" },
	{ "<C-A-l>", "<Esc><C-w>l" },
	{ "<C-A-k>", "<Esc><C-w>k" },
	{ "<C-A-j>", "<Esc><C-w>j" }
)

key.vmap({ "<C-A-h>", "<Esc><C-w>h" }, { "<C-A-l>", "<Esc><C-w>l" }, { "<C-A-k>", "<Esc><C-w>k" }, {
	"<C-A-j>",
	"<Esc><C-w>j",
})

key.tmap(
	{ "<C-A-h>", "<C-\\><C-n><C-w>h" },
	{ "<C-A-l>", "<C-\\><C-n><C-w>l" },
	{ "<C-A-k>", "<C-\\><C-n><C-w>k" },
	{ "<C-A-j>", "<C-\\><C-n><C-w>j" }
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
	{ "<C-f>", modules.finder.find_in_buffer },
	{ "<C-S-f>", modules.finder.find_in_files },
	-- { "<C-y>", modules.finder.find_yanks },
	{ "<F1>", modules.finder.find_in_documentation },
	{ "<C-z>", modules.finder.find_spelling },
	{ "<C-b>", modules.finder.find_buffers },
	{ "<C-t>", modules.finder.find_todos }
)

-- File Explorer

key.nmap({ "<C-e>", modules.interface.toggle_tree }, { "<leader>e", modules.interface.focus_tree })

-- Intellisense

key.nmap(
	{ "<C-Space>", modules.intellisense.open_code_actions },
	{ "<leader>l", modules.intellisense.eslint_fix },
		{ "<leader>gd", modules.intellisense.go_to_definition },
	{ "<leader>gt", modules.intellisense.go_to_type_definition },
	{ "<leader>gi", modules.intellisense.go_to_implementation },
	{ "<leader>K", modules.intellisense.show_references },
	{ "<leader>k", modules.intellisense.show_symbol_doc },
	{ "<leader>r", modules.intellisense.rename_symbol },
	{ "<leader>d", modules.intellisense.show_diagnostics },
	{ "<leader>[d", modules.intellisense.next_diagnostic },
	{ "<leader>]d", modules.intellisense.prev_diagnostic },
	{ "<leader>f", modules.intellisense.format }
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
