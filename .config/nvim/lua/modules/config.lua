local module = require("utils.module")
local Config = {}

function Config:setup()
	-- TODO: verify if possible to do this in lua
	vim.cmd([[
		:command! EditConfig :tabedit ~/.config/nvim
	]])
end

return module.create(Config)
