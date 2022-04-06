local M = {}

function M.group(config)
	local name, commands = config[1], config[2]
	local opts = {}

	-- Overriding default opts
	for i, v in pairs(config) do
		if type(i) == "string" then
			opts[i] = v
		end
	end

	local group = vim.api.nvim_create_augroup(name, opts)

	for _, command in ipairs(commands) do
		command.group = group
		M.command(command)
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

	if type(handler) == "string" then
		opts.command = handler
	elseif type(handler) == "function" then
		opts.callback = handler
	end

	vim.api.nvim_create_autocmd(eventName, opts)
end

return M
