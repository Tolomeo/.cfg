local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
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

function Format.setup_formatter()
	local keymap = settings.keymap
	local formatters = settings.config["language.formatters"]

	require("formatter").setup({
		filetype = fn.ireduce(fn.entries(formatters), function(_formatter_setup_filetype, entry)
			local formatter_name, filetypes = entry[1], entry[2]

			for _, filetype in ipairs(filetypes) do
				if not _formatter_setup_filetype[filetype] then
					_formatter_setup_filetype[filetype] = {}
				end

				table.insert(
					_formatter_setup_filetype[filetype],
					require("formatter.filetypes." .. filetype)[formatter_name]
				)
			end

			return _formatter_setup_filetype
		end, {
			["*"] = {
				require("formatter.filetypes.any").remove_trailing_whitespace,
			},
		}),
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
