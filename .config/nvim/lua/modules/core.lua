local M = {}

M.plugins = {
	-- Automatic management of tags
	"ludovicchabant/vim-gutentags",
	-- Reload and restard commands
	"famiu/nvim-reload",
	-- Automatically changes cwd based on the root of the project
	"airblade/vim-rooter",
	-- Automatic management of sessions
	"rmagatti/auto-session",
}

function M.setup()
	-- Setting files/dirs to look for to understand what the root dir is
	vim.api.nvim_set_var("rooter_patterns", { "=nvim", ".git", "package.json" })

	require("auto-session").setup()
end

return M
