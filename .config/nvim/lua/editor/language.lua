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

function Language:on_server_attach(client, buffer)
	local keymaps = settings.keymaps()
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

function Language:default_servers()
	local runtime_path = vim.split(package.path, ";")
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")

	return {
		{
			name = "sumneko_lua",
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
						library = vim.api.nvim_get_runtime_file("", true),
					},
					-- Do not send telemetry data containing a randomized but unique identifier
					telemetry = {
						enable = false,
					},
				},
			},
		},
	}
end

function Language:default_server_config()
	return {
		capabilities = require("editor.completion"):default_capabilities({}),
		on_attach = fn.bind(self.on_server_attach, self),
	}
end

function Language:setup_servers()
	local options = settings.options()
	local default_servers = Language:default_servers()
	local default_server_config = Language:default_server_config()
	local servers = fn.push(default_servers, unpack(options["language.servers"]))

	require("nvim-lsp-installer").setup({
		automatic_installation = true,
	})

	for _, server in ipairs(servers) do
		local server_config = {
			settings = server.settings,
			capabilities = default_server_config.capabilities,
			on_attach = default_server_config.on_attach,
		}

		require("lspconfig")[server.name].setup(server_config)
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
			prefix = "▌",
		},
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
