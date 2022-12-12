local Module = require("_shared.module")
local au = require("_shared.au")

---@class Editor.Spelling
local Spelling = {}

function Spelling:setup()
	au.group({
		"OnMarkdownBufferOpen",
		{
			{
				{ "BufRead", "BufNewFile" },
				"*.md",
				"setlocal spell",
			},
		},
	})
end

return Module:new(Spelling)
