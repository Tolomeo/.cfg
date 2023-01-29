local Module = require("_shared.module")
local key = require("_shared.key")
local settings = require("settings")

---@class Cfg.Editor.Format
local Format = {}

Format.plugins = {
	-- Formatter
	"sbdchd/neoformat",
	-- Folds
	{ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" },
}

function Format:setup()
	self:setup_formatter()
	self:setup_folds()
end

function Format.setup_formatter()
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

function Format:setup_folds()
	require("ufo").setup()
end

return Module:new(Format)
