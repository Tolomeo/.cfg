local validator = require("_shared.validator")
local fn = require("_shared.fn")
local arr = require("_shared.array")
local pt = require("_shared.path")

local nvim_args = fn.tail(vim.v.argv)

local Args = {}

Args.argv = vim.fn.argv

Args.arglist = function()
	return fn.imap(Args.argv(), function(arg)
		return pt.format({ arg, ":p" })
	end)
end

Args.find = validator.f.arguments({
	validator.f.shape({
		"string",
	}),
}) .. function(args)
	local name = args[1]

	return arr.find(nvim_args, function(arg)
		return arg == name
	end)
end

return Args
