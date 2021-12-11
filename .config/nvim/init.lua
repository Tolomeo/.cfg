require('defaults')
local modules = require('modules')
local plugins = require('plugins')

modules.setup()

plugins.setup(function(use)
	modules.for_each(function (module)
		use(module.plugins)
	end)
end)

-- Keymapping
local key = require('utils.key')
_G.user = {
	modules = modules
}

-- Remapping arrows to nothing
key.map { "i", "<left>", "<nop>" }
key.map { "i", "<left>", "<nop>" }
key.map { "i", "<right>", "<nop>" }
key.map { "i", "<up>", "<nop>" }
key.map { "i", "<down>", "<nop>" }

-- Movement multipliers
key.map { "n", "H", "0" }
key.map { "n", "<A-h>", "b" }
key.map { "n", "L", "$" }
key.map { "n", "<A-l>", "w" }
key.map { "n", "J", "<C-d>" }
key.map { "n", "K", "<C-u>" }

-- Adding empty lines in normal mode
key.map { "n", "<CR>", "O<ESC>j"}
key.map { "n", "<A-CR>", "o<ESC>k"}

-- Intellisense
key.map { "n", "<C-Space>", "v:lua.user.modules.intellisense.open_code_actions()", expr = true }
key.map { "n", "<leader>b", "v:lua.user.modules.intellisense.prettier_format()", expr = true }

key.map { "n", "<leader>l", "v:lua.user.modules.intellisense.eslint_fix()", expr = true }
key.map { "n", "<leader>d", "v:lua.user.modules.intellisense.go_to_definition()", expr = true }
key.map { "n", "<leader>k", "v:lua.user.modules.intellisense.show_symbol_doc()", expr = true }
key.map { "n", "<leader>rn", "v:lua.user.modules.intellisense.rename_symbol()", expr = true }
key.map { "i", "<C-Space>", "v:lua.user.modules.intellisense.open_suggestions()", expr = true }
key.map { "i", "<TAB>", "v:lua.user.modules.intellisense.next_suggestion('<TAB>')", expr = true }
key.map { "i", "<S-TAB>","v:lua.user.modules.intellisense.prev_suggestion()", expr = true }
key.map { "i", "<CR>", "v:lua.user.modules.intellisense.confirm_suggestion()", expr = true }
