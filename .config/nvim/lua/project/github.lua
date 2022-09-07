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

Github._is_changed_file_diff = function()
	local has_review = require("octo.reviews").get_current_review()
	local in_diff_window = require("octo.utils").in_diff_window()

	return has_review and in_diff_window
end

Github.changed_file_diff_menu = function(options)
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

Github.changed_files_list_menu = function(options)
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

Github._is_pull_request = function()
	return vim.api.nvim_buf_get_option(0, "filetype") == "octo"
end

Github.pull_request_menu = function(options)
	local menu = {
		{
			"Checkout pull request",
			"<space>po",
			handler = require("octo.mappings").checkout_pr,
		},
		{
			"Merge pull request",
			"<space>pm",
			handler = require("octo.mappings").merge_pr,
		},
		{
			"Squash and merge pull request",
			"<space>psm",
			handler = require("octo.mappings").squash_and_merge_pr,
		},
		{
			"List pull request commits",
			"<space>pc",
			handler = require("octo.mappings").list_commits,
		},
		{
			"List pull request changes",
			"<space>pf",
			handler = require("octo.mappings").list_changed_files,
		},
		{
			"Show pull request diff",
			"<space>pd",
			handler = require("octo.mappings").show_pr_diff,
		},
		{
			"Add pull request reviewer",
			"<space>va",
			handler = require("octo.mappings").add_reviewer,
		},
		{
			"Remove pull request reviewer",
			"<space>vd",
			handler = require("octo.mappings").remove_reviewer,
		},
		{
			"Close pull request",
			"<space>ic",
			handler = require("octo.mappings").close_issue,
		},
		{
			"Reopen pull request",
			"<space>io",
			handler = require("octo.mappings").reopen_issue,
		},
		{
			"Reload pull request",
			"<C-r>",
			handler = require("octo.mappings").reload,
		},
		{
			"Open pull request in browser",
			"<C-b>",
			handler = require("octo.mappings").open_in_browser,
		},
		{
			"Copy pull request url",
			"<C-y>",
			handler = require("octo.mappings").copy_url,
		},
		--[[ {
			"Go to file",
			"gf",
			handler = require("octo.mappings").goto_file,
		}, ]]
		{
			"Add pull request assignee",
			"<space>aa",
			handler = require("octo.mappings").add_assignee,
		},
		{
			"Remove pull request assignee",
			"<space>ad",
			handler = require("octo.mappings").remove_assignee,
		},
		--[[ {
			"Create label",
			"<space>lc",
			handler = require("octo.mappings").create_label,
		}, ]]
		{
			"Add pull request label",
			"<space>la",
			handler = require("octo.mappings").add_label,
		},
		{
			"Remove pull request label",
			"<space>la",
			handler = require("octo.mappings").remove_label,
		},
		{
			"Add pull request comment",
			"<space>ca",
			handler = require("octo.mappings").add_comment,
		},
		{
			"Remove pull request comment",
			"<space>cd",
			handler = require("octo.mappings").delete_comment,
		},
		{
			"Go to next comment",
			"]c",
			handler = require("octo.mappings").next_comment,
		},
		{
			"Go to previous comment",
			"[c",
			handler = require("octo.mappings").prev_comment,
		},

		-- react_hooray = { lhs = "<space>rp", desc = "add/remove 🎉 reaction" },
		-- react_heart = { lhs = "<space>rh", desc = "add/remove ❤️ reaction" },
		-- react_eyes = { lhs = "<space>re", desc = "add/remove 👀 reaction" },
		-- react_thumbs_up = { lhs = "<space>r+", desc = "add/remove 👍 reaction" },
		-- react_thumbs_down = { lhs = "<space>r-", desc = "add/remove 👎 reaction" },
		-- react_rocket = { lhs = "<space>rr", desc = "add/remove 🚀 reaction" },
		-- react_laugh = { lhs = "<space>rl", desc = "add/remove 😄 reaction" },
		-- react_confused = { lhs = "<space>rc", desc = "add/remove 😕 reaction" }
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

	if Github._is_changed_file_diff() then
		table.insert(github_pickers, 1, { prompt_title = "Diff actions", find = Github.changed_file_diff_menu })
	elseif Github._is_changed_files_list() then
		table.insert(github_pickers, 1, { prompt_title = "Changed files", find = Github.changed_files_list_menu })
	elseif Github._is_pull_request() then
		table.insert(github_pickers, 1, { prompt_title = "Pull request", find = Github.pull_request_menu })
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
