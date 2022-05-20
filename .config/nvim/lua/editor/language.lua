local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
-- local validator = require("_shared.validator")

local defaults = {
	syntax = {
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
	servers = {
		bash = {
			name = "bashls",
			settings = function(base_settings) return base_settings end
		},
		lua = {
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
		},
		html = {
			name = "html",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
			settings = function(base_settings)
				base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
				return base_settings
			end
		},
		css = {
			name = "cssls",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
			settings = function(base_settings)
				base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
				return base_settings
			end
		},
		emmet = {
			name = "emmet_ls",
			settings = function(base_settings) return base_settings end
		},
		dockerfile = {
			name = "dockerls",
			settings = function(base_settings) return base_settings end
		},
		json = {
			name = "jsonls",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
			settings = function(base_settings)
				base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
				return base_settings
			end
		},
		yaml = {
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
		},
		typescript = {
			name = "tsserver",
			settings = function(base_settings) return base_settings end
		},
		cssmodules = {
			name = "cssmodules_ls",
			settings = function(base_settings) return base_settings end
		},
		eslint = {
			name = "eslint",
			settings = function(base_settings) return base_settings end
		}
	}
}

local Language = {}

Language.plugins = {
	-- Highlight, edit, and code navigation parsing library
	"nvim-treesitter/nvim-treesitter",
	-- Syntax aware text-objects based on treesitter
	{ "nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter" },
	-- lsp
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer"

}

Language._on_server_attach = function(client, buffer)
	key.nmap(
		{ "<leader>k", vim.lsp.buf.hover, buffer = buffer },
		{ "<leader>K", vim.lsp.buf.document_symbol, buffer = buffer },
		{ "<leader>gr", vim.lsp.buf.references, buffer = buffer },
		{ "<leader>gd", vim.lsp.buf.definition, buffer = buffer },
		{ "<leader>gD", vim.lsp.buf.declaration, buffer = buffer },
		{ "<leader>gt", vim.lsp.buf.type_definition, buffer = buffer },
		{ "<leader>gi", vim.lsp.buf.implementation, buffer = buffer },
		{ "<leader>b", vim.lsp.buf.formatting, buffer = buffer },
		{ "<leader>r", vim.lsp.buf.rename, buffer = buffer },
		{ "<leader>dj", vim.diagnostic.goto_next, buffer = buffer },
		{ "<leader>dk", vim.diagnostic.goto_prev, buffer = buffer },
		-- TODO: this probaly shouldn't be here
		{ "<leader>dl", "<cmd>Telescope diagnostics<Cr>", buffer = buffer },
		{ "<C-Space>", vim.lsp.buf.code_action, buffer = buffer }
	)

	if not client.resolved_capabilities.document_highlight then return end

	au.group({
		"OnCursorHold",
		{
			{
				"CursorHold",
				buffer,
				vim.lsp.buf.document_highlight
			},
			{
				"CursorHoldI",
				buffer,
				vim.lsp.buf.document_highlight
			},
			{
				"CursorMoved",
				buffer,
				vim.lsp.buf.clear_references
			},
		},
	})
end

Language.setup = function(settings)
	settings = vim.tbl_deep_extend("force", defaults, settings)

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

	require("nvim-lsp-installer").setup({
		automatic_installation = true
	})

	for _, language_server in pairs(settings.servers) do
		require('lspconfig')[language_server.name].setup(language_server.settings({
			capabilities = capabilities,
			on_attach = Language._on_server_attach
		}))
	end

	require("nvim-treesitter.configs").setup({
		ensure_installed = settings.syntax,
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
end

return Module:new(Language)
