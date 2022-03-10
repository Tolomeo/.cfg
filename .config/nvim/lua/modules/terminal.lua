local module = require("utils.module")
local au = require("utils.au")
local Terminal = {}

function Terminal:autocommands()
	-- In the terminal emulator, insert mode becomes the default mode
	-- see https://github.com/neovim/neovim/issues/8816
	-- NOTE: there are some caveats and related workarounds documented at the link
	-- TODO: enter insert mode even when the buffer reloaded from being hidden
	-- also, no line numbers in the terminal
	au.group("OnTerminalBufferEnter", {
		{
			"TermOpen",
			"term://*",
			"startinsert",
		},
		{
			"TermOpen",
			"term://*",
			"setlocal nonumber norelativenumber",
		},
		{
			"BufEnter",
			"term://*",
			"if &buftype == 'terminal' | :startinsert | endif",
		},
	})
end

function Terminal:setup()
	-- TODO: verify if possible to do this in lua
	vim.cmd([[
		:command! EditConfig :tabedit ~/.config/nvim
	]])
end

return module.create(Terminal)
