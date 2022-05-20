local Module = require("_shared.module")
local au = require("_shared.au")

local Spelling = {}

Spelling.setup = function()
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
