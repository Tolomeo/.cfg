local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local arr = require("_shared.array")
local map = require("_shared.map")
local settings = require("settings")

local Format = Module:extend({
	plugins = {
		-- Formatter
		{ "mhartington/formatter.nvim" },
		-- Folds
		{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },
		-- Comments
		{ "b3nj5m1n/kommentary" },
	},
})

function Format:setup()
	self:setup_formatter()
	self:setup_folds()
	self:setup_comments()
end

function Format.get_defaults()
	local util = require("formatter.util")
	local prettier_defaults = require("formatter.defaults.prettier")

	return setmetatable({
		less = {
			prettier = util.withl(prettier_defaults, "less"),
		},
		scss = {
			prettier = util.withl(prettier_defaults, "scss"),
		},
	}, {
		__index = function(_, filetype)
			return require(string.format("formatter.filetypes.%s", filetype))
		end,
	})
end

function Format:setup_formatter()
	local keymap = settings.keymap
	local language_configs = settings.config["language"]
	local formatter_defaults = self:get_defaults()

	local language_formatters = map.reduce(language_configs, function(_language_formatters, filetypes_config, filetypes)
		if filetypes_config.format == nil then
			return _language_formatters
		end

		for _, filetype in ipairs(fn.split(filetypes, ",")) do
			filetype = fn.trim(filetype)

			_language_formatters[filetype] = arr.map(filetypes_config.format, function(formatter_name)
				return formatter_defaults[filetype][formatter_name]
			end)
		end

		return _language_formatters
	end, {
		["*"] = {
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	})

	require("formatter").setup({
		filetype = language_formatters,
	})

	-- Mappings
	key.nmap({ keymap["language.format"], "<cmd>Format<Cr>" })
end

function Format:setup_folds()
	require("ufo").setup()
end

function Format:setup_comments()
	local keymap = settings.keymap

	vim.g.kommentary_create_default_mappings = false

	key.nmap({ keymap["buffer.line.comment"], fn.bind(self.comment_line, self) })
	key.vmap({ keymap["buffer.line.comment"], fn.bind(self.comment_selection, self) })
end

function Format:comment_line()
	key.input("<Plug>kommentary_line_default", "m")
end

-- vim.api.nvim_set_keymap("x", "<leader>/", "<Plug>kommentary_visual_default", {}
function Format:comment_selection()
	key.input("<Plug>kommentary_visual_default", "m")
end

return Format:new()
