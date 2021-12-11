require('defaults')
_G.user = {
	modules = require('modules'),
	plugins = require('plugins')
}

user.modules.setup()

user.plugins.setup(function(use)
	user.modules.for_each(function (module)
		use(module.plugins)
	end)
end)


local key = require('utils.key')

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
key.map { "n", "<C-Space>", "v:lua.user.modules.intellisense.openCodeActions()", expr = true }
key.map { "n", "<leader>b", "v:lua.user.modules.intellisense.prettierFormat()", expr = true }

key.map { "n", "<leader>l", "v:lua.user.modules.intellisense.eslintFix()", expr = true }
key.map { "n", "<leader>d", "v:lua.user.modules.intellisense.goToDefinition()", expr = true }
key.map { "n", "<leader>k", "v:lua.user.modules.intellisense.showSymbolDocumentation()", expr = true }
key.map { "n", "<leader>rn", "v:lua.user.modules.intellisense.renameSymbol()", expr = true }
key.map { "i", "<C-Space>", "v:lua.user.modules.intellisense.openSuggestions()", expr = true }
key.map { "i", "<TAB>", "v:lua.user.modules.intellisense.nextSuggestion('<TAB>')", expr = true }
key.map { "i", "<S-TAB>","v:lua.user.modules.intellisense.prevSuggestion()", expr = true }
key.map { "i", "<CR>", "v:lua.user.modules.intellisense.confirmSuggestion()", expr = true }
