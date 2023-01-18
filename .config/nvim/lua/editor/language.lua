local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local settings = require("settings")
local fn = require("_shared.fn")

---@class Editor.Language
local Language = {}

Language.plugins = {
	-- lsp
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer",
	-- formatting
	"sbdchd/neoformat",
	-- folds
	{ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" },
}

function Language:setup_servers()
	local keymaps = settings.keymaps()
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

		local picker = require("finder.picker")

		key.nmap(
			{ keymaps["language.lsp.hover"], vim.lsp.buf.hover, buffer = buffer },
			{ keymaps["language.lsp.document_symbol"], vim.lsp.buf.document_symbol, buffer = buffer },
			{ keymaps["language.lsp.references"], vim.lsp.buf.references, buffer = buffer },
			{ keymaps["language.lsp.definition"], vim.lsp.buf.definition, buffer = buffer },
			{ keymaps["language.lsp.declaration"], vim.lsp.buf.declaration, buffer = buffer },
			{ keymaps["language.lsp.type_definition"], vim.lsp.buf.type_definition, buffer = buffer },
			{ keymaps["language.lsp.implementation"], vim.lsp.buf.implementation, buffer = buffer },
			{ keymaps["language.lsp.code_action"], vim.lsp.buf.code_action, buffer = buffer },
			{ keymaps["language.lsp.rename"], vim.lsp.buf.rename, buffer = buffer },
			{ keymaps["language.diagnostic.next"], vim.diagnostic.goto_next, buffer = buffer },
			{ keymaps["language.diagnostic.prev"], vim.diagnostic.goto_prev, buffer = buffer },
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
	})
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
