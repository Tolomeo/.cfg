local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")
local au = require("_shared.au")

local Github = {}

Github.plugins = {
	{
		"pwntester/octo.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"kyazdani42/nvim-web-devicons",
		},
	},
	{
		"xiyaowong/telescope-octo-commands.nvim",
		requires = {
			"pwntester/octo.nvim",
		},
	},
}

Github.setup = function()
	Github._setup_keymaps()
	Github._setup_plugins()
end

Github._setup_keymaps = function()
	-- local keymaps = settings.keymaps()

	key.nmap({ "<leader>G", Github.github_actions_menu })

	--[[ au.group({
		"OctoBuffer",
		{
			{
				"FileType",
				"octo",
				function(cmd)
					local octo_buffer = _G.octo_buffers[cmd.buf]

					-- vim.pretty_print(_G.octo_buffers)
					vim.pretty_print(cmd)
					-- vim.pretty_print(_G.octo_buffers[cmd.buf])
				end,
			},
			{
				"FileType",
				"octo_panel",
				function(cmd)
					-- vim.pretty_print(_G.octo_buffers)
					vim.pretty_print(cmd)
					-- vim.pretty_print(_G.octo_buffers[cmd.buf])
				end,
			},
			{
				"BufEnter",
				-- "octo://*/review/*/file/*",
				"octo://",
				function(cmd)
					vim.pretty_print(cmd)
				end,
			},
		},
	}) ]]
end

Github.pull_requests_menu = function(options)
	local menu = {
		{
			"List",
			"Lists pending pull requests in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo pr list", ""),
		},
		{
			"Create",
			"Creates a new pull request for the current branch",
			handler = fn.bind(vim.fn.execute, "Octo pr create", ""),
		},
		{
			"List all",
			"Lists all pull requests in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo pr search", ""),
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").menu(menu, options)
end

Github.issues_menu = function(options)
	local menu = {
		{
			"List",
			"Lists pending issues in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo issue list", ""),
		},
		{
			"Create",
			"Creates a new issue in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo issue create", ""),
		},
		{
			"List all",
			"Lists all issues in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo issue search", ""),
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").menu(menu, options)
end

Github._is_review_diff = function()
	local has_review = require("octo.reviews").get_current_review()
	local in_diff_window = require("octo.utils").in_diff_window()

	return has_review and in_diff_window
end

Github.diff_menu = function(options)
	local menu = {
		{
			"Add comment",
			"<space>ca",
			handler = require("octo.mappings").add_review_comment,
		},
		{
			"Add suggestion",
			"<space>sa",
			handler = require("octo.mappings").add_review_suggestion,
		},
		{
			"Move to changed files",
			"<leader>e",
			handler = require("octo.mappings").focus_files,
		},
		{
			"Toggle changed files",
			"<leader>b",
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Move to next comment thread",
			"]t",
			handler = require("octo.mappings").next_thread,
		},
		{
			"Move to previous comment thread",
			"[t",
			handler = require("octo.mappings").prev_thread,
		},
		{
			"Select next changed file",
			"]q",
			handler = require("octo.mappings").select_next_entry,
		},
		{
			"Select previous changed file",
			"[q",
			handler = require("octo.mappings").select_prev_entry,
		},
		{
			"Close review tab",
			"<C-c>",
			handler = require("octo.mappings").close_review_tab,
		},
		{
			"Toggle viewed files",
			"<leader><space>",
			handler = require("octo.mappings").toggle_viewed,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
end

Github._is_changed_files_list = function()
	return vim.api.nvim_buf_get_option(0, "filetype") == "octo_panel"
end

Github.files_changes_menu = function(options)
	local menu = {
		{
			"Next changed file",
			"j",
			handler = require("octo.mappings").next_entry,
		},
		{
			"Previous changed file",
			"k",
			handler = require("octo.mappings").prev_entry,
		},
		{
			"Select changed file",
			"<Cr>",
			handler = require("octo.mappings").select_entry,
		},
		{
			"Refresh changed files",
			"R",
			handler = require("octo.mappings").refresh_files,
		},
		{
			"Toggle changed files",
			"<leader>b",
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Select next changed file",
			"]q",
			handler = require("octo.mappings").select_next_entry,
		},
		{
			"Select previous changed file",
			"[q",
			handler = require("octo.mappings").select_prev_entry,
		},
		{
			"Close review tab",
			"<C-c>",
			handler = require("octo.mappings").close_review_tab,
		},
		{
			"Toggle viewed files",
			"<leader><space>",
			handler = require("octo.mappings").toggle_viewed,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
end

Github.github_actions_menu = function()
	local github_pickers = {
		{ prompt_title = "GH Pull Requests", find = Github.pull_requests_menu },
		{ prompt_title = "GH Issues", find = Github.issues_menu },
	}

	if Github._is_review_diff() then
		table.insert(github_pickers, 1, { prompt_title = "Diff actions", find = Github.diff_menu })
	elseif Github._is_changed_files_list() then
		table.insert(github_pickers, 1, { prompt_title = "Changed files", find = Github.files_changes_menu })
	end

	require("finder.picker").Pickers(github_pickers):find()
end

Github._setup_plugins = function()
	-- GithubSigns
	-- see https://github.com/whatsthatsmell/dots/blob/master/public%20dots/vim-nvim/lua/joel/mappings.lua
	require("gitsigns").setup({
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
		},
	})

	-- Octo
	require("octo").setup({
		right_bubble_delimiter = "┃",
		left_bubble_delimiter = "┃",
	})
	require("telescope").load_extension("octo_commands")
end

return Module:new(Github)
