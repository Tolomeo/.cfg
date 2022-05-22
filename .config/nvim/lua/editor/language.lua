local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Language = {}

Language.settings = {
	parsers = {},
	servers = {}
}

Language.plugins = {
	-- Highlight, edit, and code navigation parsing library
	"nvim-treesitter/nvim-treesitter",
	-- Syntax aware text-objects based on treesitter
	{ "nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter" },
	-- lsp
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer",
	-- formatting
	"sbdchd/neoformat"
}

local on_server_attach = function(client, buffer)
	-- avoid usign formatting coming from lsp
	client.resolved_capabilities.document_formatting = false
	client.resolved_capabilities.document_range_formatting = false

	key.nmap(
		{ "<leader>k", vim.lsp.buf.hover, buffer = buffer },
		{ "<leader>K", vim.lsp.buf.document_symbol, buffer = buffer },
		{ "<leader>gr", vim.lsp.buf.references, buffer = buffer },
		{ "<leader>gd", vim.lsp.buf.definition, buffer = buffer },
		{ "<leader>gD", vim.lsp.buf.declaration, buffer = buffer },
		{ "<leader>gt", vim.lsp.buf.type_definition, buffer = buffer },
		{ "<leader>gi", vim.lsp.buf.implementation, buffer = buffer },
		-- { "<leader>b", vim.lsp.buf.formatting, buffer = buffer },
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

Language.setup_servers = function()
	local servers = Language.settings.servers
	local capabilities = require('editor.completion').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	local server_base_settings = {
		capabilities = capabilities,
		on_attach = on_server_attach
	}

	require("nvim-lsp-installer").setup({
		automatic_installation = true
	})

	for _, server in ipairs(servers) do
		local setup_server = require('lspconfig')[server.name].setup
		local server_settings = type(server.settings) == "function" and server.settings(server_base_settings) or server_base_settings

		setup_server(server_settings)
	end
end

Language.setup_parsers = function()
	local parsers = Language.settings.parsers

	require("nvim-treesitter.configs").setup({
		ensure_installed = parsers,
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
		lsp_interop = {
			enable = true,
			border = 'none',
			peek_definition_code = {
				["<leader>df"] = "@function.outer",
				["<leader>dF"] = "@class.outer",
			},
		},
		context_commentstring = {
			enable = true,
		},
	})
end

Language.setup_formatter = function()
	-- Enable basic formatting when a filetype is not found
	vim.g.neoformat_basic_format_retab = 1
	vim.g.neoformat_basic_format_align = 1
	vim.g.neoformat_basic_format_trim = 1
	-- Have Neoformat look for a formatter executable in the node_modules/.bin directory in the current working directory or one of its parents
	vim.g.neoformat_try_node_exe = 1

	key.nmap({ "<leader>b", "<cmd>Neoformat<Cr>" })
end

Language.setup = validator.f.arguments({
	validator.f.shape({
		parsers = validator.f.optional(validator.f.list({ "string" })),
		servers = validator.f.optional(validator.f.list({
			validator.f.shape({
				name = "string",
				settings = validator.f.optional("function")
			})
		}))
	})
}) .. function(settings)
	Language.settings = vim.tbl_deep_extend("force", Language.settings, settings)

	Language.setup_servers()
	Language.setup_parsers()
	Language.setup_formatter()
end

return Module:new(Language)
