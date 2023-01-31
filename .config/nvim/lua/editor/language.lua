local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

---@class Cfg.Editor.Language
local Language = {}

Language.plugins = {
	-- Lsp
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer",
	-- Completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
}

---@private
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

---@private
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
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
		on_attach = fn.bind(self.on_server_attach, self),
	}
end

function Language:setup_servers()
	local options = settings.options()
	local float_win_config = require("interface.window"):float_config()
	local default_servers = Language:default_servers()
	local default_server_config = Language:default_server_config()
	local servers = fn.push(default_servers, unpack(options["language.servers"]))

	require("nvim-lsp-installer").setup({
		automatic_installation = true,
	})

	for _, server in ipairs(servers) do
		local server_config = {
			settings = server.settings,
			capabilities = fn.merge_deep(default_server_config.capabilities, server.capabilities),
			on_attach = default_server_config.on_attach,
		}

		require("lspconfig")[server.name].setup(server_config)
	end

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
		signs = true,
		update_in_insert = options["language.diagnostics.update_in_insert"],
		underline = true,
		severity_sort = options["language.diagnostics.severity_sort"],
		float = float_win_config,
	})

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float_win_config)

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, float_win_config)

	vim.api.nvim_create_user_command(
		"LspWorkspaceAdd",
		vim.lsp.buf.add_workspace_folder,
		{ desc = "Add folder to workspace" }
	)

	vim.api.nvim_create_user_command("LspWorkspaceList", function()
		vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, { desc = "List workspace folders" })

	vim.api.nvim_create_user_command(
		"LspWorkspaceRemove",
		vim.lsp.buf.remove_workspace_folder,
		{ desc = "Remove folder from workspace" }
	)
end

function Language:setup_snippets()
	local luasnip = require("luasnip")

	luasnip.config.set_config({
		region_check_events = "InsertEnter",
		delete_check_events = "InsertLeave",
	})

	require("luasnip.loaders.from_vscode").lazy_load()
end

function Language:setup_completion()
	local keymaps = settings.keymaps()
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			[keymaps["dropdown.item.next"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),

			[keymaps["dropdown.item.prev"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),

			[keymaps["dropdown.scroll.up"]] = cmp.mapping.scroll_docs(-4),

			[keymaps["dropdown.scroll.down"]] = cmp.mapping.scroll_docs(4),

			[keymaps["dropdown.open"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.abort()
					fallback()
				else
					cmp.complete()
				end
			end),

			-- ['<C-e>'] = cmp.mapping.abort(),

			[keymaps["dropdown.item.confirm"]] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		}),
		sources = cmp.config.sources({
			{ name = "path" },
			{ name = "nvim_lsp", keyword_length = 2 },
			{ name = "luasnip", keyword_length = 3 },
			{ name = "buffer", keyword_length = 1 },
		}),
	})

	-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
			{ name = "cmdline" },
		}),
	})
end

function Language:setup()
	self:setup_servers()
	self:setup_snippets()
	self:setup_completion()
end

return Module:new(Language)
