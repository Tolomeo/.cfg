local Module = require("_shared.module")
local key = require("_shared.key")

---@class Finder
local Finder = {}

Finder.plugins = {
	"romainl/vim-cool",
}

Finder.modules = {
	"finder.list",
	"finder.picker",
}

function Finder:setup()
	self:_setup_keymaps()
	self:_setup_plugins()
end

function Finder:_setup_keymaps()
	key.nmap(
		-- Keep search results centered
		{ "n", "nzzzv" },
		{ "N", "Nzzzv" }
	)
end

function Finder:_setup_plugins()
	-- Vim-cool
	vim.g.CoolTotalMatches = 1
end

return Module:new(Finder)
