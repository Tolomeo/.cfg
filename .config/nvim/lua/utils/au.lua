local M = {}

function M.group(config)
	local name, autocmds = config[1], config[2]
	local opts = { clear = true }

	-- Overriding default opts
	for i, v in pairs(config) do
		if type(i) == "string" then
			opts[i] = v
		end
	end

	local group = vim.api.nvim_create_augroup(name, opts)

	for _, autocmd in ipairs(autocmds) do
		autocmd.group = group
		M.command(autocmd)
	end
end

function M.command(config)
	local eventName, pattern, handler = config[1], config[2], config[3]
	local opts = {}

	-- Overriding default opts
	for i, v in pairs(config) do
		if type(i) == "string" then
			opts[i] = v
		end
	end

	opts.pattern = pattern
	opts.command = type(handler) ~= "function" and handler or nil
	opts.callback = type(handler) == "function" and handler or nil

	vim.api.nvim_create_autocmd(eventName, opts)
end

return M
