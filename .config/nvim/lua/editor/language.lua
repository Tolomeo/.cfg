local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

local Language = Module:extend({
	plugins = {
		{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
		-- Nvim config development
		{ "folke/neodev.nvim" },
		-- Lsp
		{ "neovim/nvim-lspconfig" },
		{ "williamboman/mason-lspconfig.nvim" },
		-- Completion
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-cmdline" },
		{ "L3MON4D3/LuaSnip" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "rafamadriz/friendly-snippets" },
		-- Winbar
		{
			"SmiteshP/nvim-navic",
			requires = { "neovim/nvim-lspconfig" },
			config = function()
				require("nvim-navic").setup({
					highlight = true,
					separator = " > ",
					depth_limit_indicator = settings.opt.listchars.extend,
				})
			end,
		},
	},
})

---@private
function Language:on_server_attach(client, buffer)
	local keymap = settings.keymap
	local picker = require("integration.picker")

	key.nmap(
		{ keymap["language.lsp.hover"], vim.lsp.buf.hover, buffer = buffer },
		{ keymap["language.lsp.signature_help"], vim.lsp.buf.signature_help, buffer = buffer },
		{ keymap["language.lsp.references"], vim.lsp.buf.references, buffer = buffer },
		{ keymap["language.lsp.definition"], vim.lsp.buf.definition, buffer = buffer },
		{ keymap["language.lsp.declaration"], vim.lsp.buf.declaration, buffer = buffer },
		{ keymap["language.lsp.type_definition"], vim.lsp.buf.type_definition, buffer = buffer },
		{ keymap["language.lsp.implementation"], vim.lsp.buf.implementation, buffer = buffer },
		{ keymap["language.lsp.code_action"], vim.lsp.buf.code_action, buffer = buffer },
		{ keymap["language.lsp.rename"], vim.lsp.buf.rename, buffer = buffer },
		{ keymap["language.diagnostic.next"], vim.diagnostic.goto_next, buffer = buffer },
		{ keymap["language.diagnostic.prev"], vim.diagnostic.goto_prev, buffer = buffer },
		{ keymap["language.diagnostic.open"], vim.diagnostic.open_float, buffer = buffer },
		{ keymap["language.diagnostic.list"], fn.bind(picker.find_diagnostics, picker), buffer = buffer }
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

	-- extending global winbar to display information coming from lsp server
	if client.server_capabilities.documentSymbolProvider then
		local buffer_win = fn.ifind(vim.fn.getwininfo(), function(win)
			return win.bufnr == buffer
		end)

		if buffer_win then
			vim.wo[buffer_win.winid].winbar =
				string.format("%s >> %s", fn.trim(vim.o.winbar), "%{%v:lua.require('nvim-navic').get_location()%}")

			require("nvim-navic").attach(client, buffer)
		end
	end
end

function Language:default_server_config()
	return {
		capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
		on_attach = fn.bind(self.on_server_attach, self),
	}
end

function Language:setup_servers()
	local config = settings.config
	local float_win_config = require("interface.window"):float_config()
	local servers = config["language.servers"]
	local default_server_config = self:default_server_config()

	require("mason-lspconfig").setup({
		automatic_installation = true,
	})

	require("neodev").setup()

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
		update_in_insert = config["language.diagnostics.update_in_insert"],
		underline = true,
		severity_sort = config["language.diagnostics.severity_sort"],
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
	local keymap = settings.keymap
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			[keymap["dropdown.item.next"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),

			[keymap["dropdown.item.prev"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),

			[keymap["dropdown.scroll.up"]] = cmp.mapping.scroll_docs(-4),

			[keymap["dropdown.scroll.down"]] = cmp.mapping.scroll_docs(4),

			[keymap["dropdown.open"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.abort()
					fallback()
				else
					cmp.complete()
				end
			end),

			-- ['<C-e>'] = cmp.mapping.abort(),

			[keymap["dropdown.item.confirm"]] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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

return Language:new()
