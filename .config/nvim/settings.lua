local options = {
	["language.parsers"] = {
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
		"graphql",
	},
	["language.servers"] = {
		{
			name = "bashls",
		},
		{
			name = "sumneko_lua",
			settings = function(base_settings)
				local runtime_path = vim.split(package.path, ";")
				table.insert(runtime_path, "lua/?.lua")
				table.insert(runtime_path, "lua/?/init.lua")

				return vim.tbl_extend("force", base_settings, {
					settings = {
						Lua = {
							runtime = {
								-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
								-- Setup your lua path
								path = runtime_path,
							},
							diagnostics = {
								-- Get the language server to recognize the `vim` global
								globals = { "vim" },
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
					},
				})
			end,
		},
		{
			name = "html",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html
			settings = function(base_settings)
				base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
				return base_settings
			end,
		},
		{
			name = "cssls",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
			settings = function(base_settings)
				base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
				return base_settings
			end,
		},
		{
			name = "emmet_ls",
		},
		{
			name = "dockerls",
			settings = function(base_settings)
				return base_settings
			end,
		},
		{
			name = "jsonls",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
			settings = function(base_settings)
				base_settings.capabilities.textDocument.completion.completionItem.snippetSupport = true
				return base_settings
			end,
		},
		{
			name = "yamlls",
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls
			settings = function(base_settings)
				return vim.tbl_extend("force", base_settings, {
					settings = {
						schemas = {
							["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
						},
					},
				})
			end,
		},
		{
			name = "tsserver",
		},
		{
			name = "cssmodules_ls",
		},
		{
			name = "eslint",
		},
		{
			name = "graphql",
		},
	},
}

return {
	options = options,
}
