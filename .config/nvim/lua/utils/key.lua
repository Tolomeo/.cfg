local M = {}

function M.feed(keys)
	return vim.fn.feedkeys(keys)
end

function M.to_term_code(keys)
	return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M.map(config)
	local opts = {noremap = true, silent = true}
	for i, v in pairs(config) do
		if type(i) == 'string' then opts[i] = v end
	end

	return vim.api.nvim_set_keymap(config[1], config[2], config[3], opts)
end

function M.map_buffer(config)
	local opts = {noremap = true, silent = true}
	for i, v in pairs(config) do
		if type(i) == 'string' then opts[i] = v end
	end

	return vim.api.nvim_buf_set_keymap(0, config[1], config[2], config[3], opts)
end

return M
