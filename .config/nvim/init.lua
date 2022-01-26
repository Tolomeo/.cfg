require("options")
local modules = require("modules")
local au = require("utils.au")
local key = require("utils.key")

-- INITIALISATION

modules.setup({
	color_scheme = "edge",
})

-- AUTOCMDS
-- TODO: move autocmds into modules

-- Recompiling config whenever something changes
au.group("NvimConfigChange", {
	{
		"BufWritePost",
		"~/.config/nvim/**",
		modules.plugins.compile,
	},
})

-- Spellchecking only some files
au.group("SpellCheck", {
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
au.group("YankHighlight", {
	{
		"TextYankPost",
		"*",
		vim.highlight.on_yank,
	},
})

-- KEYMAPS

-- Pressing ESC in normal mode clears search highlighting
key.map({"n", "<ESC>", ":noh<CR><ESC>"})
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
key.map({ "n", "H", "0" })
-- Right
key.map({ "n", "<A-l>", "w" })
key.map({ "n", "L", "$" })
-- Up
key.map({ "n", "<A-k>", "(" })
key.map({ "n", "K", "gg" })
-- Down
key.map({ "n", "<A-j>", ")" })
key.map({ "n", "J", "G" })

-- Duplicating lines up and down
-- TODO: making this work in visual mode too
key.map({ "n", "<C-A-k>", "mayyP`a" })
key.map({ "n", "<C-A-j>", "mayyp`a" })

-- Adding empty lines in normal mode with enter
-- TODO: making this work in visual mode too
key.map({ "n", "<CR>", "O<ESC>j" })
key.map({ "n", "<A-CR>", "o<ESC>k" })

-- Controlling indentation with C-h and C-l
key.map({ "n", "<C-h>", "<<" })
key.map({ "n", "<C-l>", ">>" })
key.map({ "i", "<C-h>", "<C-d>" })
key.map({ "i", "<C-l>", "<C-t>" })
key.map({ "v", "<C-h>", "<gv" })
key.map({ "v", "<C-l>", ">gv" })

-- Keep search results centred
key.map({ "n", "n", "nzzzv" })
key.map({ "n", "N", "Nzzzv" })

-- Repeating last macro with Q
key.map({"n", "Q", "@@"})

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
key.map({ "n", "<C-A-p>", modules.finder.find_commands })
key.map({ "n", "<C-A-e>", modules.finder.find_projects })
key.map({ "n", "<C-f>", modules.finder.find_in_buffer })
key.map({ "n", "<C-A-f>", modules.finder.find_in_files })
key.map({ "n", "<C-y>", modules.finder.find_yanks })
key.map({ "n", "<F1>", modules.finder.find_in_documentation })
key.map({ "n", "<C-z>", modules.finder.find_spelling })
key.map({ "n", "<C-b>", modules.finder.find_buffers })
key.map({ "n", "<C-t>", modules.finder.find_todos })

-- Quickfix and location lists keybindings
key.map({ "n", "<C-c>", modules.quickfix.toggle })
key.map({ "n", "<leader>c", modules.quickfix.jump })
-- TODO: C-n is synonim for ESC, so if used it clashes with ESC mappings
-- it is needed to find different mappings for next and prev
-- IDEA: use arrow keys?
key.map({ "n", "<C-]>", modules.quickfix.next })
-- key.map({ "n", "<C-[>", modules.quickfix.prev })

-- Moving lines up and down
-- see https://vim.fandom.com/wiki/Moving_lines_up_or_down#Reordering_up_to_nine_lines
key.map({ "n", "<C-j>", modules.editor.move_line_down })
key.map({ "n", "<C-k>", modules.editor.move_line_up })
key.map({
	"i",
	"<C-j>",
	function()
		key.input("<ESC>")
		modules.editor.move_line_down()
		key.input("gi")
	end,
})
key.map({
	"i",
	"<C-k>",
	function()
		key.input("<ESC>")
		modules.editor.move_line_up()
		key.input("gi")
	end,
})
key.map({ "v", "<C-j>", modules.editor.move_selection_down })
key.map({ "v", "<C-k>", modules.editor.move_selection_up })

-- Replace word under cursor in buffer
key.map({ "n", "<leader>sb", modules.editor.replace_current_word_in_buffer })
-- Replace word under cursor in line
key.map({ "n", "<leader>sl", modules.editor.replace_current_word_in_line })
-- Commenting lines
key.map({ "n", "<leader><space>", modules.editor.comment_line })
key.map({ "x", "<leader><space>", modules.editor.comment_selection })
