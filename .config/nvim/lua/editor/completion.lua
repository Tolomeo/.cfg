local Module = require("_shared.module")
local settings = require("settings")

---@class Editor.Completion
local Completion = {}

Completion.plugins = {
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
}

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

function Completion:setup()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	local keymaps = settings.keymaps()

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body) -- For `luasnip` users.
			end,
		},
		mapping = cmp.mapping.preset.insert({
			[keymaps["dropdown.item.next"]] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
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
			[keymaps["dropdown.open"]] = cmp.mapping.complete({}),
			-- ['<C-e>'] = cmp.mapping.abort(),
			[keymaps["dropdown.item.confirm"]] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		}),
		sources = cmp.config.sources({
			{ name = "path" },
			{ name = "nvim_lsp", keyword_length = 3 },
			{ name = "luasnip", keyword_length = 3 },
			{ name = "buffer", keyword_length = 2 },
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

	require("luasnip.loaders.from_vscode").lazy_load()
end

---@param capabilities table
---@return table
function Completion:default_capabilities(capabilities)
	return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

return Module:new(Completion)
