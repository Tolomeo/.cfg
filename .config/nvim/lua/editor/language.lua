local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Language = {}

Language.plugins = {
	-- Highlight, edit, and code navigation parsing library
	"nvim-treesitter/nvim-treesitter",
	-- Syntax aware text-objects based on treesitter
	{ "nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter" },
	-- lsp
	"neovim/nvim-lspconfig"
}

--[[ key.imap(
	{ "<C-Space>", modules.editor.language.open_suggestions }
	-- { "<TAB>", modules.editor.language.next_suggestion("<TAB>") },
	-- { "<S-TAB>", modules.editor.language.prev_suggestion }
	-- { "<CR>", modules.editor.language.confirm_suggestion }
) ]]

local languages = {
	bash = {
		syntax = { "bash" },
		server = {
			{
				name = "bashls"
			}
		}
	},
	lua = {
		syntax = "lua",
		server = {
			{
				name = "sumneko_lua",
				settings = function(base_settings)
					local runtime_path = vim.split(package.path, ';')
					table.insert(runtime_path, "lua/?.lua")
					table.insert(runtime_path, "lua/?/init.lua")

					return vim.tbl_extend("force", base_settings, {
						settings = {
							Lua = {
								runtime = {
									-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
									version = 'LuaJIT',
									-- Setup your lua path
									path = runtime_path,
								},
								diagnostics = {
									-- Get the language server to recognize the `vim` global
									globals = { 'vim' },
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
								},
								-- Do not send telemetry data containing a randomized but unique identifier
								telemetry = {
									enable = false,
								},
							},
						}
					})
				end
			}
		}
	},
	htmlcss = {
		syntax = { "html", "css", "scss" },
		server = {
			{
				name = "html",
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
				settings = function(base_settings)
					base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
					return base_settings
				end
			},
			{
				name = "cssls",
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
				settings = function(base_settings)
					base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
					return base_settings
				end
			},
			{
				name = "emmet_ls"
			}
		},
	},
	docker = {
		syntax = "dockerfile",
		server = {
			{
				name = "dockerls",
			}
		}
	},
	json = {
		syntax = { "json", "jsonc" },
		server = {
			{
				name = "jsonls",
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
				settings = function(base_settings)
					base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
					return base_settings
				end
			}
		}
	},
	yaml = {
		syntax = "yaml",
		server = {
			{
				name = "yamlls",
				-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
				settings = function(base_settings)
					return vim.tbl_extend("force", base_settings, {
						settings = {
							schemas = {
								["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*"
							}
						}
					})
				end
			}
		}
	},
	javascript = {
		syntax = { "javascript", "typescript", "tsx" },
		server = {
			{
				name = "tsserver"
			},
			{
				name = "cssmodules_ls"
			},
			{
				name = "eslint"
			}
		},
	},
}

Language.setup = function()
	local lspconfig = require('lspconfig')
	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

	for _, language in pairs(languages) do
		if not language.server then goto continue end

		for _, language_server in ipairs(language.server) do
			local name, settings = language_server.name, language_server.settings or function(base_settings) return base_settings end

			lspconfig[name].setup(settings({
				capabilities = capabilities,
				on_attach = function(client)
					print(vim.inspect(client))

					key.nmap(
						{ "<leader>k", vim.lsp.buf.hover, buffer = 0 },
						-- { "<leader>K", vim.lsp.buf.document_symbol, buffer = 0 },
						{ "<leader>gr", vim.lsp.buf.references, buffer = 0 },
						{ "<leader>gd", vim.lsp.buf.definition, buffer = 0 },
						{ "<leader>gD", vim.lsp.buf.declaration, buffer = 0 },
						{ "<leader>gt", vim.lsp.buf.type_definition, buffer = 0 },
						{ "<leader>gi", vim.lsp.buf.implementation, buffer = 0 },
						{ "<leader>b", vim.lsp.buf.formatting, buffer = 0 },
						{ "<leader>r", vim.lsp.buf.rename, buffer = 0 },
						{ "<leader>dj", vim.diagnostic.goto_next, buffer = 0 },
						{ "<leader>dk", vim.diagnostic.goto_prev, buffer = 0 },
						-- TODO: this probaly shouldn't be here
						{ "<leader>dl", "<cmd>Telescope diagnostics<Cr>", buffer = 0 },
						{ "<C-Space>", vim.lsp.buf.code_action, buffer = 0 }
					-- { "<leader>B", modules.editor.language.eslint_fix },
					-- { "<leader>dl", modules.editor.language.show_diagnostics },
					)

					if (client.resolved_capabilities.document_highlight) then
						au.group({
							"OnCursorHold",
							{
								{
									"CursorHold",
									0,
									vim.lsp.buf.document_highlight
								},
								{
									"CursorHoldI",
									0,
									vim.lsp.buf.document_highlight
								},
								{
									"CursorMoved",
									0,
									vim.lsp.buf.clear_references
								},
							},
						})
					end
				end
			}))
		end

		::continue::
	end

	require("nvim-treesitter.configs").setup({
		ensure_installed = {
			"bash",
			"lua",
			"html",
			"css",
			"scss",
			"dockerfile",
			"dot",
			"json",
			"jsdoc",
			"yaml",
			"javascript",
			"typescript",
			"tsx",
		},
		sync_install = true,
		highlight = {
			enable = true, -- false will disable the whole extension
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "grn",
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		indent = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]m"] = "@function.outer",
					["]]"] = "@class.outer",
				},
				goto_next_end = {
					["]M"] = "@function.outer",
					["]["] = "@class.outer",
				},
				goto_previous_start = {
					["[m"] = "@function.outer",
					["[["] = "@class.outer",
				},
				goto_previous_end = {
					["[M"] = "@function.outer",
					["[]"] = "@class.outer",
				},
			},
		},
		context_commentstring = {
			enable = true,
		},
	})


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
end

Language.open_code_actions = function()
	-- return key.input("<Plug>(coc-codeaction)", "m")
end

Language.format = function()
	-- return vim.api.nvim_command('call CocAction("format")')
end

Language.eslint_fix = function()
	-- return vim.api.nvim_command("CocCommand eslint.executeAutofix")
end

Language.go_to_definition = function()
	-- return key.input("<Plug>(coc-definition)", "m")
end

Language.go_to_type_definition = function()
	-- return key.input("<Plug>(coc-type-definition)", "m")
end

Language.go_to_implementation = function()
	-- return key.input("<Plug>(coc-implementation)", "m")
end

Language.show_references = function()
	-- return key.input("<Plug>(coc-references)", "m")
end

Language.show_symbol_doc = function()
	-- return vim.api.nvim_command('call CocActionAsync("doHover")')
end

Language.rename_symbol = function()
	-- return key.input("<Plug>(coc-rename)", "m")
end

Language.highlight_symbol = function()
	-- return vim.api.nvim_command("call CocActionAsync('highlight')")
end

Language.show_diagnostics = function()
	-- return vim.api.nvim_command("CocDiagnostics")
end

Language.next_diagnostic = function()
	-- return key.input("<Plug>(coc-diagnostic-next)", "m")
end

Language.prev_diagnostic = function()
	-- return key.input("<Plug>(coc-diagnostic-prev)", "m")
end

-- TODO: move this check into core module
Language.has_suggestions = function()
	return vim.fn.pumvisible() ~= 0
end

Language.open_suggestions = function()
	-- return key.input(vim.fn["coc#refresh"]())
end

Language.next_suggestion = validator.f.arguments({ "string" })
		.. function(next)
			return function()
				--[[ if Language.has_suggestions() then
				return key.input("<C-n>")
			end

			return key.input(next) ]]
			end
		end

Language.prev_suggestion = function()
	--[[ if Language.has_suggestions() then
		return key.input("<C-p>")
	end

	return key.input("<C-h>") ]]
end

-- vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'", {silent = true, expr = true, noremap = true})
Language.confirm_suggestion = function()
	--[[ if Language.has_suggestions() then
		return key.feed(vim.fn["coc#_select_confirm"]())
	end

	return key.feed(key.to_term_code("<C-G>u<CR>") .. vim.fn["coc#on_enter"](), "n") ]]
end

return Module:new(Language)
