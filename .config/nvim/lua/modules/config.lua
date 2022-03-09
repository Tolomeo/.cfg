local au = require("utils.au")
local M = {}

M.plugins = {}

function M.autocommands() end

function M.setup()
	-- TODO: verify if possible to do this in lua
	vim.cmd([[
		:command! EditConfig :tabedit ~/.config/nvim
	]])
end

return M
