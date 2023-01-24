local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local settings = require("settings")
local fn = require("_shared.fn")

---@class Editor.Language
local Language = {}

Language.plugins = {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lua" },
			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	},
	-- Format
	"sbdchd/neoformat",
	-- Folds
	{ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" },
}

function Language:setup_servers()
	local options = settings.options()
	local keymaps = settings.keymaps()

	local lsp = require("lsp-zero")
	lsp.preset("manual-setup")
	lsp.set_preferences({
		set_lsp_keymaps = false,
	})

	lsp.ensure_installed(fn.imap(options["language.servers"], function(server_config)
		return server_config.name
	end))

	lsp.nvim_workspace()
	for _, server_config in ipairs(options["language.servers"]) do
		lsp.configure(server_config.name, { settings = server_config.settings })
	end

	lsp.on_attach(function(client, buffer)
		-- avoid using formatting coming from lsp
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false

		key.nmap(
			{ keymaps["language.lsp.hover"], vim.lsp.buf.hover, buffer = buffer },
			{ keymaps["language.lsp.signature_help"], vim.lsp.buf.signature_help, buffer = buffer },
			{ keymaps["language.lsp.references"], vim.lsp.buf.references, buffer = buffer },
			{ keymaps["language.lsp.definition"], vim.lsp.buf.definition, buffer = buffer },
			{ keymaps["language.lsp.declaration"], vim.lsp.buf.declaration, buffer = buffer },
			{ keymaps["language.lsp.type_definition"], vim.lsp.buf.type_definition, buffer = buffer },
			{ keymaps["language.lsp.implementation"], vim.lsp.buf.implementation, buffer = buffer },
			{ keymaps["language.lsp.code_action"], vim.lsp.buf.code_action, buffer = buffer },
			{ keymaps["language.lsp.rename"], vim.lsp.buf.rename, buffer = buffer },
			{ keymaps["language.diagnostic.next"], vim.diagnostic.goto_next, buffer = buffer },
			{ keymaps["language.diagnostic.prev"], vim.diagnostic.goto_prev, buffer = buffer },
			{ keymaps["language.diagnostic.open"], vim.diagnostic.open_float, buffer = buffer },
			{
				keymaps["language.diagnostic.list"],
				function()
					require("interface.picker"):find_diagnostics()
				end,
				buffer = buffer,
			}
		)

		if client.server_capabilities.documentHighlightProvider then
			au.group({ "OnCursorHold" }, {
				"CursorHold",
				buffer,
				vim.lsp.buf.document_highlight,
			}, {
				"CursorHoldI",
				buffer,
				vim.lsp.buf.document_highlight,
			}, {
				"CursorMoved",
				buffer,
				vim.lsp.buf.clear_references,
			})
		end
	end)

	lsp.setup()
	--[[ local keymaps = settings.keymaps()
	local options = settings.options()
	-- local client_capabilities =
	local capabilities = require("editor.completion"):default_capabilities(
		vim.tbl_extend("force", vim.lsp.protocol.make_client_capabilities(), {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		})
	)
	local on_attach = function(client, buffer)
		-- avoid using formatting coming from lsp
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false

		local picker = require("interface.picker")

		key.nmap(
			{ keymaps["language.lsp.hover"], vim.lsp.buf.hover, buffer = buffer },
			{ keymaps["language.lsp.signature_help"], vim.lsp.buf.signature_help, buffer = buffer },
			{ keymaps["language.lsp.references"], vim.lsp.buf.references, buffer = buffer },
			{ keymaps["language.lsp.definition"], vim.lsp.buf.definition, buffer = buffer },
			{ keymaps["language.lsp.declaration"], vim.lsp.buf.declaration, buffer = buffer },
			{ keymaps["language.lsp.type_definition"], vim.lsp.buf.type_definition, buffer = buffer },
			{ keymaps["language.lsp.implementation"], vim.lsp.buf.implementation, buffer = buffer },
			{ keymaps["language.lsp.code_action"], vim.lsp.buf.code_action, buffer = buffer },
			{ keymaps["language.lsp.rename"], vim.lsp.buf.rename, buffer = buffer },
			{ keymaps["language.diagnostic.next"], vim.diagnostic.goto_next, buffer = buffer },
			{ keymaps["language.diagnostic.prev"], vim.diagnostic.goto_prev, buffer = buffer },
			{ keymaps["language.diagnostic.open"], vim.diagnostic.open_float, buffer = buffer },
			{ keymaps["language.diagnostic.list"], fn.bind(picker.find_diagnostics, picker), buffer = buffer }
		)

		if client.server_capabilities.documentHighlightProvider then
			au.group({ "OnCursorHold" }, {
				"CursorHold",
				buffer,
				vim.lsp.buf.document_highlight,
			}, {
				"CursorHoldI",
				buffer,
				vim.lsp.buf.document_highlight,
			}, {
				"CursorMoved",
				buffer,
				vim.lsp.buf.clear_references,
			})
		end
	end

	local server_base_settings = {
		capabilities = capabilities,
		on_attach = on_attach,
	}

	require("nvim-lsp-installer").setup({
		automatic_installation = true,
	})

	for _, server in ipairs(options["language.servers"]) do
		local setup_server = require("lspconfig")[server.name].setup
		local server_settings = type(server.settings) == "function" and server.settings(server_base_settings)
			or server_base_settings

		setup_server(server_settings)
	end

	-- Delay diagnostics in insert mode
	-- https://github.com/neovim/nvim-lspconfig/issues/127
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		-- delay update diagnostics
		update_in_insert = options["language.diagnostics.update_in_insert"],
		severity_sort = options["language.diagnostics.severity_sort"],
	})

	-- Diagnostic signs
	require("interface"):sign(
		{ name = "DiagnosticSignError", text = "▐" },
		{ name = "DiagnosticSignWarn", text = "▐" },
		{ name = "DiagnosticSignHint", text = "▐" },
		{ name = "DiagnosticSignInfo", text = "▐" }
	)

	vim.diagnostic.config({
		virtual_text = {
			prefix = "▉",
		},
	}) ]]
end

function Language:setup_formatter()
	local keymaps = settings.keymaps()
	-- Enable basic formatting when a filetype is not found
	vim.g.neoformat_basic_format_retab = 1
	vim.g.neoformat_basic_format_align = 1
	vim.g.neoformat_basic_format_trim = 1
	-- Have Neoformat look for a formatter executable in the node_modules/.bin directory in the current working directory or one of its parents
	vim.g.neoformat_try_node_exe = 1
	-- Mappings
	key.nmap({ keymaps["language.format"], "<cmd>Neoformat<Cr>" })
end

function Language:setup_folding()
	require("ufo").setup()
end

function Language:setup()
	self:setup_servers()
	self:setup_formatter()
	self:setup_folding()
end

return Module:new(Language)
