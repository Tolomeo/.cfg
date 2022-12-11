local Module = require("_shared.module")
local key = require("_shared.key")

local Finder = {}

Finder.plugins = {
	"romainl/vim-cool",
}

Finder.modules = {
	"finder.list",
	"finder.picker",
}

Finder.setup = function()
	Finder._setup_keymaps()
	Finder._setup_plugins()
end

Finder._setup_keymaps = function()
	key.nmap(
		-- Keep search results centered
		{ "n", "nzzzv" },
		{ "N", "Nzzzv" }
	)
end

Finder._setup_plugins = function()
	-- Vim-cool
	vim.g.CoolTotalMatches = 1
end

return Module:new(Finder)
