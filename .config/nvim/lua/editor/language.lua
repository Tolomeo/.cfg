local Module = require("_shared.module")
local au = require("_shared.au")
local key = require("_shared.key")
local settings = require("settings")
local fn = require("_shared.fn")

---@class Language
local Language = {}

Language.plugins = {
	-- Highlight, edit, and code navigation parsing library
	{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
	-- Syntax aware text-objects based on treesitter
	{ "nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter" },
	-- lsp
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer",
	-- formatting
	"sbdchd/neoformat",
	-- Code docs
	{ "danymat/neogen", requires = "nvim-treesitter/nvim-treesitter" },
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

		if not client.server_capabilities.documentHighlightProvider then
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
end

function Language:setup_parsers()
	local options = settings.options()

	require("nvim-treesitter.configs").setup({
		ensure_installed = options["language.parsers"],
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

function Language:setup_annotator()
	require("neogen").setup({})
end

function Language:setup_folding()
	require("ufo").setup()
end

function Language:setup()
	self:setup_servers()
	self:setup_parsers()
	self:setup_formatter()
	self:setup_annotator()
	self:setup_folding()
end

return Module:new(Language)
