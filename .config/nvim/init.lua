require("options")
local modules = require("modules")
local au = require("utils.au")
local key = require("utils.key")

-- INITIALISATION

modules.setup({
	color_scheme = "rose-pine",
})

-- AUTOCMDS
-- TODO: move autocmds into modules

-- In the terminal emulator, insert mode becomes the default mode
-- see https://github.com/neovim/neovim/issues/8816
-- NOTE: there are some caveats and related workarounds documented at the link
-- TODO: enter insert mode even when the buffer reloaded from being hidden
-- also, no line numbers in the terminal
au.group("OnTerminalBufferEnter", {
	{
		"TermOpen",
		"term://*",
		"startinsert",
	},
	{
		"TermOpen",
		"term://*",
		"setlocal nonumber norelativenumber",
	},
	{
		"BufEnter",
		"term://*",
		"if &buftype == 'terminal' | :startinsert | endif",
	},
})

--[[ au.group("OnInsertModeToggle", {
	{
		"InsertEnter",
		"*",
		"set relativenumber"
	},
	{
		"InsertLeave",
		"*",
		"set norelativenumber"
	}
}) ]]

-- Forcing every new window created to open vertically
-- see https://vi.stackexchange.com/questions/22779/how-to-open-files-in-vertical-splits-by-default
au.group("OnWindowOpen", {
	{
		"WinNew",
		"*",
		"wincmd L",
	},
})

-- Recompiling config whenever something changes
au.group("OnConfigChange", {
	{
		"BufWritePost",
		"~/.config/nvim/**",
		modules.plugins.compile,
	},
})

-- Spellchecking only some files
au.group("OnMarkdownBufferOpen", {
	{
		{ "BufRead", "BufNewFile" },
		"*.md",
		"setlocal spell",
	},
})

-- vim.cmd [[autocmd CursorHold * silent call CocActionAsync('highlight')]]
--[[ au.group("CursorSymbolHighlight", {
	{
		"CursorHold",
		"*",
		modules.intellisense.highlight_symbol,
	},
}) ]]

-- Yank visual feedback
au.group("OnTextYanked", {
	{
		"TextYankPost",
		"*",
		vim.highlight.on_yank,
	},
})

-- COMMANDS

-- TODO: verify if possible to do this in lua
vim.cmd([[
	:command! EditConfig :tabedit ~/.config/nvim
]])

-- KEYMAPS

-- Editor

key.nmap(
	-- Multipliers
	-- Left
	{ "<A-h>", "b" },
	{ "<A-S-h>", "B" },
	{ "H", "^" },
	-- Right
	{ "<A-l>", "w" },
	{ "<A-S-l>", "W" },
	{ "L", "$" },
	-- Up
	{ "<A-k>", "10k" },
	{ "<A-S-k>", "20k" },
	{ "K", "gg" },
	-- Down
	{ "<A-j>", "10j" },
	{ "<A-S-j>", "20j" },
	{ "J", "G" },
	-- Duplicating lines up and down
	{ "<C-A-k>", "mayyP`a" },
	{ "<C-A-j>", "mayyp`a" },
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
	-- { "<C-S-j>", modules.editor.move_line_down },
	-- { "<C-S-k>", modules.editor.move_line_up },
	-- Replace word under cursor in buffer
	{ "<leader>s%", modules.editor.replace_current_word_in_buffer },
	-- Replace word under cursor in line
	{ "<leader>ss", modules.editor.replace_current_word_in_line },
	-- Commenting lines
	{ "<leader><space>", modules.editor.comment_line },
	-- Toggling booleans
	{ "<leader>~", modules.editor.toggle_boolean }
)

-- TODO: Visual mode movement multipliers
-- TODO: Visual mode duplicating up and down

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
			key.input("<ESC>")
			modules.editor.move_line_down()
			key.input("gi")
		end,
	},
	{
		"<A-k>",
		function()
			key.input("<ESC>")
			modules.editor.move_line_up()
			key.input("gi")
		end,
	},
	-- Indentation
	{ "<A-Tab>", "<C-t>" },
	{ "<A-S-Tab>", "<C-d>" }
)

key.vmap(
	{ "<Tab>", ">gv" },
	{ "<S-Tab>", "<gv" },
	-- Make visual yanks place the cursor back where started
	{ "y", "ygv<Esc>" },
	{ "<A-j>", modules.editor.move_selection_down },
	{ "<A-k>", modules.editor.move_selection_up },
	{ "<leader><space>", modules.editor.comment_selection }
)

-- Windows

key.nmap(
	-- Navigation
	{ "<C-h>", "<C-w>h" },
	{ "<C-l>", "<C-w>l" },
	{ "<C-k>", "<C-w>k" },
	{ "<C-j>", "<C-w>j" },
	-- Split mappings
	{ "<Leader>;", "<C-W>R" },
	{ "<Leader>[", "<C-W>_" },
	{ "<Leader>]", "<C-W>|" },
	{ "<Leader>=", "<C-W>=" }
)

key.imap(
	-- Navigation
	{ "<C-h>", "<Esc><C-w>h" },
	{ "<C-l>", "<Esc><C-w>l" },
	{ "<C-k>", "<Esc><C-w>k" },
	{ "<C-j>", "<Esc><C-w>j" }
)

key.vmap({ "<C-h>", "<Esc><C-w>h" }, { "<C-l>", "<Esc><C-w>l" }, { "<C-k>", "<Esc><C-w>k" }, {
	"<C-j>",
	"<Esc><C-w>j",
})

key.tmap(
	{ "<Esc>", "<C-\\><C-n>" },
	{ "<C-h>", "<C-\\><C-n><C-w>h" },
	{ "<C-l>", "<C-\\><C-n><C-w>l" },
	{ "<C-k>", "<C-\\><C-n><C-w>k" },
	{ "<C-j>", "<C-\\><C-n><C-w>j" }
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

key.nmap({ "<C-e>", modules.theme.toggle_tree }, { "<leader>e", modules.theme.focus_tree })

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

