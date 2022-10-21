local Module = require("_shared.module")
local settings = require("settings")

local Completion = {}

Completion.default_capabilities = function(capabilities)
	return require("cmp_nvim_lsp").default_capabilities(capabilities)
end

Completion.plugins = {
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"saadparwaiz1/cmp_luasnip",
}

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

Completion.setup = function()
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
			-- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
			-- ['<C-f>'] = cmp.mapping.scroll_docs(4),
			[keymaps["dropdown.open"]] = cmp.mapping.complete(),
			-- ['<C-e>'] = cmp.mapping.abort(),
			[keymaps["dropdown.item.confirm"]] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" }, -- For luasnip users.
		}, {
			{ name = "buffer" },
		}),
	})

	-- Set configuration for specific filetype.
	--[[ cmp.setup.filetype('gitcommit', {
		sources = cmp.config.sources({
			{ name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
		}, {
			{ name = 'buffer' },
		})
	}) ]]

	-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
	--[[ cmp.setup.cmdline('/', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = 'buffer' }
		}
	}) ]]

	-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	--[[ cmp.setup.cmdline(':', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = 'path' }
		}, {
			{ name = 'cmdline' }
		})
	}) ]]
end

return Module:new(Completion)
