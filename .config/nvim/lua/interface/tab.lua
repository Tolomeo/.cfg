local Module = require("_shared.module")
-- local key = require("_shared.key")

local Tab = {}

Tab.setup = function()
	-- key.nmap({ "<C-t>", "<Cmd>tabnew<Cr>" })
end

return Module:new(Tab)
