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
	key.nmap({ "<leader>G", Github.actions_menu })
end

Github.repository_menu = function(options)
	local menu = {
		{
			"List pull requests",
			"Lists pending pull requests in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo pr list", ""),
		},
		{
			"Create pull request",
			"Creates a new pull request for the current branch",
			handler = fn.bind(vim.fn.execute, "Octo pr create", ""),
		},
		{
			"List all pull requests",
			"Search among all pull requests in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo pr search", ""),
		},
		{
			"List issues",
			"Lists pending issues in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo issue list", ""),
		},
		{
			"Create issue",
			"Creates a new issue in the current repo",
			handler = fn.bind(vim.fn.execute, "Octo issue create", ""),
		},
		{
			"List all issues",
			"Search among all issues in the current repo",
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

Github.pending_review_menu = function(options)
	local menu = {
		{
			"List pending comments",
			handler = fn.bind(vim.fn.execute, "Octo review comments", ""),
		},
		{
			"Discard pull request review",
			handler = fn.bind(vim.fn.execute, "Octo review discard", ""),
		},
		{
			"Submit pull request review",
			handler = fn.bind(vim.fn.execute, "Octo review submit", ""),
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
end
Github.reactions_menu = function(options)
	local menu = {
		{
			"Add/remove 🎉 reaction",
			"<space>rp",
			handler = require("octo.mappings").react_hooray,
		},
		{
			"Add/remove ❤️ reaction",
			"<space>rh",
			handler = require("octo.mappings").react_heart,
		},
		{
			"Add/remove 👀 reaction",
			"<space>re",
			handler = require("octo.mappings").react_eyes,
		},
		{
			"Add/remove 👍 reaction",
			"<space>r+",
			handler = require("octo.mappings").react_thumbs_up,
		},
		{
			"Add/remove 👎 reaction",
			"<space>r-",
			handler = require("octo.mappings").react_thumbs_down,
		},
		{
			"Add/remove 🚀 reaction",
			"<space>rr",
			handler = require("octo.mappings").react_rocket,
		},
		{
			"Add/remove 😄 reaction",
			"<space>rl",
			handler = require("octo.mappings").react_laugh,
		},
		{
			"Add/remove 😕 reaction",
			"<space>rc",
			handler = require("octo.mappings").react_confused,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
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
			"Move to changed files",
			"<leader>e",
			handler = require("octo.mappings").focus_files,
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
			"Mark/Unmark file as viewed",
			"<leader><space>",
			handler = require("octo.mappings").toggle_viewed,
		},
		{
			"Open/Close changed files list",
			"<leader>b",
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Close review tab",
			"<C-c>",
			handler = require("octo.mappings").close_review_tab,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
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
			"Mark/Unmark file as viewed",
			"<leader><space>",
			handler = require("octo.mappings").toggle_viewed,
		},
		{
			"Refresh changed files",
			"R",
			handler = require("octo.mappings").refresh_files,
		},
		{
			"Open/Close changed files list",
			"<leader>b",
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Close review tab",
			"<C-c>",
			handler = require("octo.mappings").close_review_tab,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
end

Github.pull_request_menu = function(options)
	local menu = {
		{
			"Checkout pull request",
			"<space>po",
			handler = require("octo.mappings").checkout_pr,
		},
		{
			"Start pull request review",
			handler = fn.bind(vim.fn.execute, "Octo review start", ""),
		},
		{
			"Resume pull request review",
			handler = fn.bind(vim.fn.execute, "Octo review resume", ""),
		},
		{
			"Review pull request commit",
			handler = fn.bind(vim.fn.execute, "Octo review commmit", ""),
		},
		{
			"List pull request commits",
			"<space>pc",
			handler = require("octo.mappings").list_commits,
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
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
end

Github.thread_actions_menu = function(options)
	local menu = {
		{
			"Add comment",
			"<space>ca",
			handler = require("octo.mappings").add_comment,
		},
		-- NOTE: this seems not to be working
		--[[ {
			"Add suggestion",
			"<space>sa",
			handler = require("octo.mappings").add_suggestion,
		}, ]]
		{
			"Delete comment",
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
		{
			"Move to changed files list",
			"<leader>e",
			handler = require("octo.mappings").focus_files,
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
			"Open/Close changed files list",
			"<leader>b",
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Close review tab",
			"<C-c>",
			handler = require("octo.mappings").close_review_tab,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("finder.picker").context_menu(menu, options)
end

Github.actions_menu = function()
	local buffer_name = vim.api.nvim_buf_get_name(0)
	local github_pickers = {
		{ prompt_title = "Repository", find = Github.repository_menu },
	}

	if string.match(buffer_name, "octo://.+/pull/%d+$") then
		local pr_menu_prompt_title = "Pull request #" .. vim.fn.fnamemodify(buffer_name, ":t")
		table.insert(github_pickers, 1, { prompt_title = "Reactions", find = Github.reactions_menu })
		table.insert(github_pickers, 1, { prompt_title = pr_menu_prompt_title, find = Github.pull_request_menu })
	elseif string.match(buffer_name, "^.+/OctoChangedFiles%-%d+$") then
		table.insert(github_pickers, 1, { prompt_title = "Pending review", find = Github.pending_review_menu })
		table.insert(github_pickers, 1, { prompt_title = "Changed files", find = Github.changed_files_list_menu })
	elseif string.match(buffer_name, "^octo://.+/review/.+/file/.+$") then
		local prompt_title = vim.fn.fnamemodify(buffer_name, ":t")
		table.insert(github_pickers, 1, { prompt_title = "Pending review", find = Github.pending_review_menu })
		table.insert(github_pickers, 1, { prompt_title = prompt_title, find = Github.changed_file_diff_menu })
	elseif string.match(buffer_name, "octo://.+/review/.+/threads/.+$") then
		local thread_menu_prompt_title = vim.fn.fnamemodify(buffer_name, ":t")
		table.insert(github_pickers, 1, { prompt_title = "Pending review", find = Github.pending_review_menu })
		table.insert(github_pickers, 1, { prompt_title = "Reactions", find = Github.reactions_menu })
		table.insert(github_pickers, 1, { prompt_title = thread_menu_prompt_title, find = Github.thread_actions_menu })
	end

	if #github_pickers > 1 then
		return require("finder.picker").Pickers(github_pickers):find()
	end

	local repository_picker = github_pickers[1]
	return repository_picker.find({ prompt_title = repository_picker.prompt_title })
end

Github._setup_plugins = function()
	local options = require("settings").options()

	require("octo").setup({
		right_bubble_delimiter = options["theme.section_separator"],
		left_bubble_delimiter = options["theme.section_separator"],
	})

	require("telescope").load_extension("octo_commands")
end

return Module:new(Github)
