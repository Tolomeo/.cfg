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

-- Clearing search highlighting
key.map({ "n", "<BS>", ":noh<CR>" })
-- please iTerm hotkey windows
key.map({ "t", "<Esc>", "<C-\\><C-n>" })

-- write only if changed
key.map({ "n", "<Leader>w", ":up<CR>", silent = false })
-- quit (or close window)
key.map({ "n", "<Leader>q", ":q<CR>" })
-- Discard all changed buffers & quit
key.map({ "n", "<Leader>Q", ":qall!<CR>" })
-- write all and quit
key.map({ "n", "<Leader>W", ":wqall<CR>", silent = false })

-- Arrows are disabled in insert mode
key.map({ "i", "<left>", "<nop>" })
key.map({ "i", "<right>", "<nop>" })
key.map({ "i", "<up>", "<nop>" })
key.map({ "i", "<down>", "<nop>" })

-- Windows navigation
key.map({ "n", "<C-h>", "<C-w>h" })
key.map({ "n", "<C-l>", "<C-w>l" })
key.map({ "n", "<C-k>", "<C-w>k" })
key.map({ "n", "<C-j>", "<C-w>j" })

key.map({ "i", "<C-h>", "<Esc><C-w>h" })
key.map({ "i", "<C-l>", "<Esc><C-w>l" })
key.map({ "i", "<C-k>", "<Esc><C-w>k" })
key.map({ "i", "<C-j>", "<Esc><C-w>j" })

key.map({ "v", "<C-h>", "<Esc><C-w>h" })
key.map({ "v", "<C-l>", "<Esc><C-w>l" })
key.map({ "v", "<C-k>", "<Esc><C-w>k" })
key.map({ "v", "<C-j>", "<Esc><C-w>j" })

key.map({ "t", "<C-h>", "<C-\\><C-n><C-w>h" })
key.map({ "t", "<C-l>", "<C-\\><C-n><C-w>l" })
key.map({ "t", "<C-k>", "<C-\\><C-n><C-w>k" })
key.map({ "t", "<C-j>", "<C-\\><C-n><C-w>j" })

-- Easier split mappings
key.map({ "n", "<Leader>;", "<C-W>R" })
key.map({ "n", "<Leader>[", "<C-W>_" })
key.map({ "n", "<Leader>]", "<C-W>|" })
key.map({ "n", "<Leader>=", "<C-W>=" })
--
-- Movement multipliers
-- TODO: making this work in visual mode too
-- Left
key.map({ "n", "<A-h>", "b" })
key.map({ "n", "<A-S-h>", "B" })
key.map({ "n", "H", "^" })
-- Right
key.map({ "n", "<A-l>", "w" })
key.map({ "n", "<A-S-l>", "W" })
key.map({ "n", "L", "$" })
-- Up
key.map({ "n", "<A-k>", "10k" })
key.map({ "n", "<A-S-k>", "20k" })
key.map({ "n", "K", "gg" })
-- Down
key.map({ "n", "<A-j>", "10j" })
key.map({ "n", "<A-S-j>", "20j" })
key.map({ "n", "J", "G" })

-- Duplicating lines up and down
-- TODO: making this work in visual mode too
key.map({ "n", "<C-A-k>", "mayyP`a" })
key.map({ "n", "<C-A-j>", "mayyp`a" })

-- Controlling indentation
key.map({ "n", "<Tab>", ">>" })
key.map({ "n", "<S-Tab>", "<<" })
key.map({ "i", "<A-Tab>", "<C-t>" })
key.map({ "i", "<A-S-Tab>", "<C-d>" })
key.map({ "v", "<Tab>", ">gv" })
key.map({ "v", "<S-Tab>", "<gv" })

-- Because we are mapping S-Tab to indent, now C-i indents too so we need to recover it
key.map({"n", "<C-S-o>", "<C-i>"})

-- Keep search results centred
key.map({ "n", "n", "nzzzv" })
key.map({ "n", "N", "Nzzzv" })

-- Repeating last macro with Q
key.map({ "n", "Q", "@@" })

-- Join lines and restore cursor location
-- key.map { "n", "J", "mjJ`j" }

-- Yank until the end of line  (note: this is now a default on master)
key.map({ "n", "Y", "y$" })
-- Easy select all of file
key.map({ "n", "<Leader>a", "ggVG<c-$>" })
-- Make visual yanks place the cursor back where started
key.map({ "v", "y", "ygv<Esc>" })

-- Todos
key.map({ "n", "<C-e>", modules.theme.toggle_tree })
key.map({ "n", "<leader>e", modules.theme.focus_tree })

-- Intellisense
key.map({ "n", "<C-Space>", modules.intellisense.open_code_actions })
key.map({ "n", "<leader>l", modules.intellisense.eslint_fix })
key.map({ "n", "<leader>gd", modules.intellisense.go_to_definition })
key.map({ "n", "<leader>gt", modules.intellisense.go_to_type_definition })
key.map({ "n", "<leader>gi", modules.intellisense.go_to_implementation })
key.map({ "n", "<leader>K", modules.intellisense.show_references })
key.map({ "n", "<leader>k", modules.intellisense.show_symbol_doc })
key.map({ "n", "<leader>r", modules.intellisense.rename_symbol })
key.map({ "i", "<C-Space>", modules.intellisense.open_suggestions })
key.map({ "i", "<TAB>", modules.intellisense.next_suggestion("<TAB>") })
key.map({ "i", "<S-TAB>", modules.intellisense.prev_suggestion })
key.map({ "i", "<CR>", modules.intellisense.confirm_suggestion })
key.map({ "n", "<leader>d", modules.intellisense.show_diagnostics })
key.map({ "n", "<leader>[d", modules.intellisense.next_diagnostic })
key.map({ "n", "<leader>]d", modules.intellisense.prev_diagnostic })
key.map({ "n", "<leader>f", modules.intellisense.format })

-- Git
key.map({ "n", "gb", modules.git.blame })
key.map({ "n", "gl", modules.git.log })
key.map({ "n", "gd", modules.git.diff })
key.map({ "n", "gm", modules.git.mergetool })
key.map({ "n", "gh", modules.git.show_hunk_preview })
key.map({ "n", "]c", modules.git.next_hunk_preview("]c") })
key.map({ "n", "[c", modules.git.prev_hunk_preview("[c") })

-- Finder
key.map({ "n", "<C-p>", modules.finder.find_files })
key.map({ "n", "<C-S-p>", modules.finder.find_commands })
key.map({ "n", "<C-S-e>", modules.finder.find_projects })
key.map({ "n", "<C-f>", modules.finder.find_in_buffer })
key.map({ "n", "<C-S-f>", modules.finder.find_in_files })
-- key.map({ "n", "<C-y>", modules.finder.find_yanks })
key.map({ "n", "<F1>", modules.finder.find_in_documentation })
key.map({ "n", "<C-z>", modules.finder.find_spelling })
key.map({ "n", "<C-b>", modules.finder.find_buffers })
key.map({ "n", "<C-t>", modules.finder.find_todos })

-- Quickfix and location lists keybindings
key.map({ "n", "<C-c>", modules.quickfix.toggle })
key.map({ "n", "<leader>c", modules.quickfix.jump })
-- TODO: C-n is synonim for ESC, so if used it clashes with ESC mappings
key.map({ "n", "<C-]>", modules.quickfix.next })
key.map({ "n", "<C-[>", modules.quickfix.prev })

-- Moving lines up and down
-- see https://vim.fandom.com/wiki/Moving_lines_up_or_down#Reordering_up_to_nine_lines
-- key.map({ "n", "<C-j>", modules.editor.move_line_down })
-- key.map({ "n", "<C-k>", modules.editor.move_line_up })
key.map({
	"i",
	"<A-j>",
	function()
		key.input("<ESC>")
		modules.editor.move_line_down()
		key.input("gi")
	end,
})
key.map({
	"i",
	"<A-k>",
	function()
		key.input("<ESC>")
		modules.editor.move_line_up()
		key.input("gi")
	end,
})
key.map({ "v", "<A-j>", modules.editor.move_selection_down })
key.map({ "v", "<A-k>", modules.editor.move_selection_up })

-- Replace word under cursor in buffer
key.map({ "n", "<leader>s%", modules.editor.replace_current_word_in_buffer })
-- Replace word under cursor in line
key.map({ "n", "<leader>ss", modules.editor.replace_current_word_in_line })
-- Commenting lines
key.map({ "n", "<leader><space>", modules.editor.comment_line })
key.map({ "x", "<leader><space>", modules.editor.comment_selection })
-- Toggling booleans
key.map({ "n", "<leader>~", modules.editor.toggle_boolean })
-- Yank all buffer
key.map({ "n", "<leader>y%", modules.editor.yank_all })
