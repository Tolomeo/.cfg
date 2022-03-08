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

-- Normal mode
key.nmap(
	-- Clearing search highlighting
	{ "<BS>", ":noh<CR>" },
	-- write only if changed
	{ "<Leader>w", ":up<CR>", silent = false },
	-- quit (or close window)
	{ "<Leader>q", ":q<CR>" },
	-- Discard all changed buffers & quit
	{ "<Leader>Q", ":qall!<CR>" },
	-- write all and quit
	{ "<Leader>W", ":wqall<CR>", silent = false },
	-- Windows navigation
	{ "<C-h>", "<C-w>h" },
	{ "<C-l>", "<C-w>l" },
	{ "<C-k>", "<C-w>k" },
	{ "<C-j>", "<C-w>j" },
	-- Easier split mappings
	{ "<Leader>;", "<C-W>R" },
	{ "<Leader>[", "<C-W>_" },
	{ "<Leader>]", "<C-W>|" },
	{ "<Leader>=", "<C-W>=" },
	-- Movement multipliers
	-- TODO: making this work in visual mode too
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
	-- TODO: making this work in visual mode too
	{ "<C-A-k>", "mayyP`a" },
	{ "<C-A-j>", "mayyp`a" },
	-- Controlling indentation
	{ "<Tab>", ">>" },
	{ "<S-Tab>", "<<" },
	-- Because we are mapping S-Tab to indent, now C-i indents too so we need to recover it
	{ "<C-S-o>", "<C-i>" },
	-- Keep search results centred
	{ "n", "nzzzv" },
	{ "N", "Nzzzv" },
	-- Repeating last macro with Q
	{ "Q", "@@" },
	-- Join lines and restore cursor location
	-- key.map { "n", "J", "mjJ`j" }
	-- Yank until the end of line  (note: this is now a default on master)
	{ "Y", "y$" },
	-- Easy select all of file
	{ "<leader>a", "ggVG<c-$>" },
	{ "<C-e>", modules.theme.toggle_tree },
	{ "<leader>e", modules.theme.focus_tree },
	-- Intellisense
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
	{ "<leader>f", modules.intellisense.format },
	-- Git
	{ "gb", modules.git.blame },
	{ "gl", modules.git.log },
	{ "gd", modules.git.diff },
	{ "gm", modules.git.mergetool },
	{ "gh", modules.git.show_hunk_preview },
	{ "]c", modules.git.next_hunk_preview("]c") },
	{ "[c", modules.git.prev_hunk_preview("[c") },
	-- Finder
	{ "<C-p>", modules.finder.find_files },
	{ "<C-S-p>", modules.finder.find_commands },
	{ "<C-S-e>", modules.finder.find_projects },
	{ "<C-f>", modules.finder.find_in_buffer },
	{ "<C-S-f>", modules.finder.find_in_files },
	-- { "<C-y>", modules.finder.find_yanks },
	{ "<F1>", modules.finder.find_in_documentation },
	{ "<C-z>", modules.finder.find_spelling },
	{ "<C-b>", modules.finder.find_buffers },
	{ "<C-t>", modules.finder.find_todos },

	-- Quickfix and location lists keybindings
	{ "<C-c>", modules.quickfix.toggle },
	{ "<leader>c", modules.quickfix.jump },
	-- TODO: C-n is synonim for ESC, so if used it clashes with ESC mappings
	{ "<C-]>", modules.quickfix.next },
	{ "<C-[>", modules.quickfix.prev },
	-- Line bubbling
	-- { "<C-j>", modules.editor.move_line_down },
	-- { "<C-k>", modules.editor.move_line_up }
	-- Replace word under cursor in buffer
	{ "<leader>s%", modules.editor.replace_current_word_in_buffer },
	-- Replace word under cursor in line
	{ "<leader>ss", modules.editor.replace_current_word_in_line },
	-- Commenting lines
	{ "<leader><space>", modules.editor.comment_line },
	-- Toggling booleans
	{ "<leader>~", modules.editor.toggle_boolean },
	-- Yank all buffer
	{ "<leader>y%", modules.editor.yank_all }
)

-- Insert mode

key.imap(
	-- Arrows are disabled in insert mode
	{ "<left>", "<nop>" },
	{ "<right>", "<nop>" },
	{ "<up>", "<nop>" },
	{ "<down>", "<nop>" },
	-- Window movements
	{ "<C-h>", "<Esc><C-w>h" },
	{ "<C-l>", "<Esc><C-w>l" },
	{ "<C-k>", "<Esc><C-w>k" },
	{ "<C-j>", "<Esc><C-w>j" },
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
	{ "<A-S-Tab>", "<C-d>" },
	-- Intellisense
	{ "<C-Space>", modules.intellisense.open_suggestions },
	{ "<TAB>", modules.intellisense.next_suggestion("<TAB>") },
	{ "<S-TAB>", modules.intellisense.prev_suggestion },
	{ "<CR>", modules.intellisense.confirm_suggestion }
)

-- Visual mode

key.vmap(
	{ "<Tab>", ">gv" },
	{ "<S-Tab>", "<gv" },

	-- Make visual yanks place the cursor back where started
	{ "y", "ygv<Esc>" },

	{ "<C-h>", "<Esc><C-w>h" },
	{ "<C-l>", "<Esc><C-w>l" },
	{ "<C-k>", "<Esc><C-w>k" },
	{ "<C-j>", "<Esc><C-w>j" },

	{ "<A-j>", modules.editor.move_selection_down },
	{ "<A-k>", modules.editor.move_selection_up },
	{ "<leader><space>", modules.editor.comment_selection }
)

-- Term mode

key.tmap(
	{ "<Esc>", "<C-\\><C-n>" },
	{ "<C-h>", "<C-\\><C-n><C-w>h" },
	{ "<C-l>", "<C-\\><C-n><C-w>l" },
	{ "<C-k>", "<C-\\><C-n><C-w>k" },
	{ "<C-j>", "<C-\\><C-n><C-w>j" }
)
