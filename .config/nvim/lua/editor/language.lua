local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local validator = require("_shared.validator")

local Language = {}

Language.settings = {
	parsers = {},
	servers = {},
	keymaps = {
		["lsp.hover"] = "<leader>k",
		["lsp.document_symbol"] = "<leader>K",
		["lsp.references"] = "<leader>gr",
		["lsp.definition"] = "<leader>gd",
		["lsp.declaration"] = "<leader>gD",
		["lsp.type_definition"] = "<leader>gt",
		["lsp.implementation"] = "<leader>gi",
		["lsp.rename"] = "<leader>r",
		["lsp.code_action"] = "<C-Space>",
		["diagnostic.next"] = "<leader>dj",
		["diagnostic.prev"] = "<leader>dk",
		["diagnostic.list"] = "<leader>dl",
		format = "<leader>b",
	},
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
	"sbdchd/neoformat",
}

local on_server_attach = function(client, buffer)
	print(vim.inspect(client.resolved_capabilities))
	-- avoid usign formatting coming from lsp
	client.resolved_capabilities.document_formatting = false
	client.resolved_capabilities.document_range_formatting = false

	key.nmap(
		{ Language.settings.keymaps["lsp.hover"], vim.lsp.buf.hover, buffer = buffer },
		{ Language.settings.keymaps["lsp.document_symbol"], vim.lsp.buf.document_symbol, buffer = buffer },
		{ Language.settings.keymaps["lsp.references"], vim.lsp.buf.references, buffer = buffer },
		{ Language.settings.keymaps["lsp.definition"], vim.lsp.buf.definition, buffer = buffer },
		{ Language.settings.keymaps["lsp.declaration"], vim.lsp.buf.declaration, buffer = buffer },
		{ Language.settings.keymaps["lsp.type_definition"], vim.lsp.buf.type_definition, buffer = buffer },
		{ Language.settings.keymaps["lsp.implementation"], vim.lsp.buf.implementation, buffer = buffer },
		{ Language.settings.keymaps["lsp.code_action"], vim.lsp.buf.code_action, buffer = buffer },
		{ Language.settings.keymaps["lsp.rename"], vim.lsp.buf.rename, buffer = buffer },
		{ Language.settings.keymaps["diagnostic.next"], vim.diagnostic.goto_next, buffer = buffer },
		{ Language.settings.keymaps["diagnostic.prev"], vim.diagnostic.goto_prev, buffer = buffer },
		{ Language.settings.keymaps["diagnostic.list"], require("finder").find_diagnostics, buffer = buffer }
	)

	if not client.resolved_capabilities.document_highlight then
		return
	end

	au.group({
		"OnCursorHold",
		{
			{
				"CursorHold",
				buffer,
				vim.lsp.buf.document_highlight,
			},
			{
				"CursorHoldI",
				buffer,
				vim.lsp.buf.document_highlight,
			},
			{
				"CursorMoved",
				buffer,
				vim.lsp.buf.clear_references,
			},
		},
	})
end

Language.setup_servers = function(settings)
	local servers = settings.servers
	local capabilities = require("editor.completion").update_capabilities(vim.lsp.protocol.make_client_capabilities())
	local server_base_settings = {
		capabilities = capabilities,
		on_attach = on_server_attach,
	}

	require("nvim-lsp-installer").setup({
		automatic_installation = true,
	})

	for _, server in ipairs(servers) do
		local setup_server = require("lspconfig")[server.name].setup
		local server_settings = type(server.settings) == "function" and server.settings(server_base_settings)
			or server_base_settings

		setup_server(server_settings)
	end
end

Language.setup_parsers = function(_)
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
			border = "none",
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

Language.setup_formatter = function(settings)
	-- Enable basic formatting when a filetype is not found
	vim.g.neoformat_basic_format_retab = 1
	vim.g.neoformat_basic_format_align = 1
	vim.g.neoformat_basic_format_trim = 1
	-- Have Neoformat look for a formatter executable in the node_modules/.bin directory in the current working directory or one of its parents
	vim.g.neoformat_try_node_exe = 1
	-- Mappings
	key.nmap({ settings.keymaps.format, "<cmd>Neoformat<Cr>" })
end

Language.setup = validator.f.arguments({
	validator.f.shape({
		parsers = validator.f.optional(validator.f.list({ "string" })),
		servers = validator.f.optional(validator.f.list({
			validator.f.shape({
				name = "string",
				settings = validator.f.optional("function"),
			}),
		})),
	}),
}) .. function(settings)
	settings = vim.tbl_deep_extend("force", Language.settings, settings)

	Language.setup_servers(settings)
	Language.setup_parsers(settings)
	Language.setup_formatter(settings)
end

return Module:new(Language)
