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
key.nmap({ "<BS>", ":noh<CR>" })
-- please iTerm hotkey windows
key.tmap({ "<Esc>", "<C-\\><C-n>" })

-- write only if changed
key.nmap({ "<Leader>w", ":up<CR>", silent = false })
-- quit (or close window)
key.nmap({ "<Leader>q", ":q<CR>" })
-- Discard all changed buffers & quit
key.nmap({ "<Leader>Q", ":qall!<CR>" })
-- write all and quit
key.nmap({ "<Leader>W", ":wqall<CR>", silent = false })

-- Arrows are disabled in insert mode
key.imap({ "<left>", "<nop>" })
key.imap({ "<right>", "<nop>" })
key.imap({ "<up>", "<nop>" })
key.imap({ "<down>", "<nop>" })

-- Windows navigation
key.nmap({ "<C-h>", "<C-w>h" })
key.nmap({ "<C-l>", "<C-w>l" })
key.nmap({ "<C-k>", "<C-w>k" })
key.nmap({ "<C-j>", "<C-w>j" })

key.imap({ "<C-h>", "<Esc><C-w>h" })
key.imap({ "<C-l>", "<Esc><C-w>l" })
key.imap({ "<C-k>", "<Esc><C-w>k" })
key.imap({ "<C-j>", "<Esc><C-w>j" })

key.vmap({ "<C-h>", "<Esc><C-w>h" })
key.vmap({ "<C-l>", "<Esc><C-w>l" })
key.vmap({ "<C-k>", "<Esc><C-w>k" })
key.vmap({ "<C-j>", "<Esc><C-w>j" })

key.tmap({ "<C-h>", "<C-\\><C-n><C-w>h" })
key.tmap({ "<C-l>", "<C-\\><C-n><C-w>l" })
key.tmap({ "<C-k>", "<C-\\><C-n><C-w>k" })
key.tmap({ "<C-j>", "<C-\\><C-n><C-w>j" })

-- Easier split mappings
key.nmap({ "<Leader>;", "<C-W>R" })
key.nmap({ "<Leader>[", "<C-W>_" })
key.nmap({ "<Leader>]", "<C-W>|" })
key.nmap({ "<Leader>=", "<C-W>=" })
--
-- Movement multipliers
-- TODO: making this work in visual mode too
-- Left
key.nmap({ "<A-h>", "b" })
key.nmap({ "<A-S-h>", "B" })
key.nmap({ "H", "^" })
-- Right
key.nmap({ "<A-l>", "w" })
key.nmap({ "<A-S-l>", "W" })
key.nmap({ "L", "$" })
-- Up
key.nmap({ "<A-k>", "10k" })
key.nmap({ "<A-S-k>", "20k" })
key.nmap({ "K", "gg" })
-- Down
key.nmap({ "<A-j>", "10j" })
key.nmap({ "<A-S-j>", "20j" })
key.nmap({ "J", "G" })

-- Duplicating lines up and down
-- TODO: making this work in visual mode too
key.nmap({ "<C-A-k>", "mayyP`a" })
key.nmap({ "<C-A-j>", "mayyp`a" })

-- Controlling indentation
key.nmap({ "<Tab>", ">>" })
key.nmap({ "<S-Tab>", "<<" })
key.imap({ "<A-Tab>", "<C-t>" })
key.imap({ "<A-S-Tab>", "<C-d>" })
key.vmap({ "<Tab>", ">gv" })
key.vmap({ "<S-Tab>", "<gv" })

-- Because we are mapping S-Tab to indent, now C-i indents too so we need to recover it
key.nmap({ "<C-S-o>", "<C-i>" })

-- Keep search results centred
key.nmap({ "n", "nzzzv" })
key.nmap({ "N", "Nzzzv" })

-- Repeating last macro with Q
key.nmap({ "Q", "@@" })

-- Join lines and restore cursor location
-- key.map { "n", "J", "mjJ`j" }

-- Yank until the end of line  (note: this is now a default on master)
key.nmap({ "Y", "y$" })
-- Easy select all of file
key.nmap({ "<Leader>a", "ggVG<c-$>" })
-- Make visual yanks place the cursor back where started
key.vmap({ "y", "ygv<Esc>" })

-- Todos
key.nmap({ "<C-e>", modules.theme.toggle_tree })
key.nmap({ "<leader>e", modules.theme.focus_tree })

-- Intellisense
key.nmap({ "<C-Space>", modules.intellisense.open_code_actions })
key.nmap({ "<leader>l", modules.intellisense.eslint_fix })
key.nmap({ "<leader>gd", modules.intellisense.go_to_definition })
key.nmap({ "<leader>gt", modules.intellisense.go_to_type_definition })
key.nmap({ "<leader>gi", modules.intellisense.go_to_implementation })
key.nmap({ "<leader>K", modules.intellisense.show_references })
key.nmap({ "<leader>k", modules.intellisense.show_symbol_doc })
key.nmap({ "<leader>r", modules.intellisense.rename_symbol })
key.imap({ "<C-Space>", modules.intellisense.open_suggestions })
key.imap({ "<TAB>", modules.intellisense.next_suggestion("<TAB>") })
key.imap({ "<S-TAB>", modules.intellisense.prev_suggestion })
key.imap({ "<CR>", modules.intellisense.confirm_suggestion })
key.nmap({ "<leader>d", modules.intellisense.show_diagnostics })
key.nmap({ "<leader>[d", modules.intellisense.next_diagnostic })
key.nmap({ "<leader>]d", modules.intellisense.prev_diagnostic })
key.nmap({ "<leader>f", modules.intellisense.format })

-- Git
key.nmap({ "gb", modules.git.blame })
key.nmap({ "gl", modules.git.log })
key.nmap({ "gd", modules.git.diff })
key.nmap({ "gm", modules.git.mergetool })
key.nmap({ "gh", modules.git.show_hunk_preview })
key.nmap({ "]c", modules.git.next_hunk_preview("]c") })
key.nmap({ "[c", modules.git.prev_hunk_preview("[c") })

-- Finder
key.nmap({ "<C-p>", modules.finder.find_files })
key.nmap({ "<C-S-p>", modules.finder.find_commands })
key.nmap({ "<C-S-e>", modules.finder.find_projects })
key.nmap({ "<C-f>", modules.finder.find_in_buffer })
key.nmap({ "<C-S-f>", modules.finder.find_in_files })
-- key.nmap({ "<C-y>", modules.finder.find_yanks })
key.nmap({ "<F1>", modules.finder.find_in_documentation })
key.nmap({ "<C-z>", modules.finder.find_spelling })
key.nmap({ "<C-b>", modules.finder.find_buffers })
key.nmap({ "<C-t>", modules.finder.find_todos })

-- Quickfix and location lists keybindings
key.nmap({ "<C-c>", modules.quickfix.toggle })
key.nmap({ "<leader>c", modules.quickfix.jump })
-- TODO: C-n is synonim for ESC, so if used it clashes with ESC mappings
key.nmap({ "<C-]>", modules.quickfix.next })
key.nmap({ "<C-[>", modules.quickfix.prev })

-- Moving lines up and down
-- see https://vim.fandom.com/wiki/Moving_lines_up_or_down#Reordering_up_to_nine_lines
-- key.nmap({ "<C-j>", modules.editor.move_line_down })
-- key.nmap({ "<C-k>", modules.editor.move_line_up })
key.imap({
	"<A-j>",
	function()
		key.input("<ESC>")
		modules.editor.move_line_down()
		key.input("gi")
	end,
})
key.imap({
	"<A-k>",
	function()
		key.input("<ESC>")
		modules.editor.move_line_up()
		key.input("gi")
	end,
})
key.vmap({ "<A-j>", modules.editor.move_selection_down })
key.vmap({ "<A-k>", modules.editor.move_selection_up })

-- Replace word under cursor in buffer
key.nmap({ "<leader>s%", modules.editor.replace_current_word_in_buffer })
-- Replace word under cursor in line
key.nmap({ "<leader>ss", modules.editor.replace_current_word_in_line })
-- Commenting lines
key.nmap({ "<leader><space>", modules.editor.comment_line })
key.xmap({ "<leader><space>", modules.editor.comment_selection })
-- Toggling booleans
key.nmap({ "<leader>~", modules.editor.toggle_boolean })
-- Yank all buffer
key.nmap({ "<leader>y%", modules.editor.yank_all })
