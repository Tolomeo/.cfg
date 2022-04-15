local Module = require("utils.module")
local au = require("utils.au")
local key = require("utils.key")

local Intellisense = Module:new({
	plugins = {
		-- Conquer of completion
		"neoclide/coc.nvim",
		branch = "master",
		run = "yarn install --frozen-lockfile"
	},
	setup = function(self)
		-- Extensions, see https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#install-extensions
		vim.g.coc_global_extensions = {
			"coc-sumneko-lua",
			"coc-stylua",
			"coc-json",
			"coc-yaml",
			"coc-html",
			"coc-emmet",
			"coc-svg",
			"coc-css",
			"coc-cssmodules",
			"coc-tsserver",
			"coc-diagnostic",
			"coc-eslint",
			"coc-prettier",
			"coc-calc",
		}

		-- vim.cmd [[autocmd CursorHold * silent call CocActionAsync('highlight')]]
		au.group({ "CursorSymbolHighlight", {
			{
				"CursorHold",
				"*",
				self.highlight_symbol,
			},
		} })

		-- Spellchecking only some files
		au.group({
			"OnMarkdownBufferOpen",
			{
				{
					{ "BufRead", "BufNewFile" },
					"*.md",
					"setlocal spell",
				},
			},
		})
	end,
})

-- Module actions
function Intellisense.open_code_actions()
	return key.input("<Plug>(coc-codeaction)", "m")
end

function Intellisense.format()
	return vim.api.nvim_command('call CocAction("format")')
end

function Intellisense.eslint_fix()
	return vim.api.nvim_command("CocCommand eslint.executeAutofix")
end

function Intellisense.go_to_definition()
	return key.input("<Plug>(coc-definition)", "m")
end

function Intellisense.go_to_type_definition()
	return key.input("<Plug>(coc-type-definition)", "m")
end

function Intellisense.go_to_implementation()
	return key.input("<Plug>(coc-implementation)", "m")
end

function Intellisense.show_references()
	return key.input("<Plug>(coc-references)", "m")
end

function Intellisense.show_symbol_doc()
	return vim.api.nvim_command('call CocActionAsync("doHover")')
end

function Intellisense.rename_symbol()
	return key.input("<Plug>(coc-rename)", "m")
end

function Intellisense.highlight_symbol()
	return vim.api.nvim_command("call CocActionAsync('highlight')")
end

function Intellisense.show_diagnostics()
	return vim.api.nvim_command("CocDiagnostics")
end

function Intellisense.next_diagnostic()
	return key.input("<Plug>(coc-diagnostic-next)", "m")
end

function Intellisense.prev_diagnostic()
	return key.input("<Plug>(coc-diagnostic-prev)", "m")
end

-- TODO: move this check into core module
function Intellisense.has_suggestions()
	return vim.fn.pumvisible() ~= 0
end

function Intellisense.open_suggestions()
	return key.input(vim.fn["coc#refresh"]())
end

function Intellisense.next_suggestion(next)
	return function()
		if Intellisense.has_suggestions() then
			return key.input("<C-n>")
		end

		return key.input(next)
	end
end

function Intellisense.prev_suggestion()
	if Intellisense.has_suggestions() then
		return key.input("<C-p>")
	end

	return key.input("<C-h>")
end
-- vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'", {silent = true, expr = true, noremap = true})
function Intellisense.confirm_suggestion()
	if Intellisense.has_suggestions() then
		return key.feed(vim.fn["coc#_select_confirm"]())
	end

	return key.feed(key.to_term_code("<C-G>u<CR>") .. vim.fn["coc#on_enter"](), "n")
end

return Intellisense
