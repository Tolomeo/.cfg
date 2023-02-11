local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

local Format = Module:extend({
	plugins = {
		-- Formatter
		{ "sbdchd/neoformat" },
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
	-- Enable basic formatting when a filetype is not found
	vim.g.neoformat_basic_format_retab = 1
	vim.g.neoformat_basic_format_align = 1
	vim.g.neoformat_basic_format_trim = 1
	-- Have Neoformat look for a formatter executable in the node_modules/.bin directory in the current working directory or one of its parents
	vim.g.neoformat_try_node_exe = 1
	-- Mappings
	key.nmap({ keymap["language.format"], "<cmd>Neoformat<Cr>" })
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
