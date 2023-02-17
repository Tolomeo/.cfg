local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

local Github = Module:extend({
	plugins = {
		{
			"pwntester/octo.nvim",
			dependencies = {
				{ "nvim-lua/plenary.nvim" },
				{ "nvim-telescope/telescope.nvim" },
				{ "kyazdani42/nvim-web-devicons" },
			},
		},
	},
})

function Github:setup()
	self:_setup_keymaps()
	self:_setup_plugins()
end

function Github:_setup_keymaps()
	local keymap = settings.keymap

	key.nmap({ keymap["github.actions"], fn.bind(self.actions_menu, self) })
end

function Github:repository_menu(options)
	local menu = {
		{
			"Create pull request",
			"Creates a new PR for the current branch",
			handler = fn.bind(vim.fn.execute, "Octo pr create", ""),
		},
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

	require("integration.finder"):menu(menu, options)
end

function Github:pending_review_menu(options)
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

	require("integration.finder"):context_menu(menu, options)
end

function Github:reactions_menu(options)
	local keymap = settings.keymap
	local menu = {
		{
			"Add/remove 🎉 reaction",
			keymap["github.react.tada"],
			handler = require("octo.mappings").react_hooray,
		},
		{
			"Add/remove ❤️ reaction",
			keymap["github.react.heart"],
			handler = require("octo.mappings").react_heart,
		},
		{
			"Add/remove 👀 reaction",
			keymap["github.react.eyes"],
			handler = require("octo.mappings").react_eyes,
		},
		{
			"Add/remove 👍 reaction",
			keymap["github.react.thumbs_up"],
			handler = require("octo.mappings").react_thumbs_up,
		},
		{
			"Add/remove 👎 reaction",
			keymap["github.react.thumbs_down"],
			handler = require("octo.mappings").react_thumbs_down,
		},
		{
			"Add/remove 🚀 reaction",
			keymap["github.react.rocket"],
			handler = require("octo.mappings").react_rocket,
		},
		{
			"Add/remove 😄 reaction",
			keymap["github.react.laugh"],
			handler = require("octo.mappings").react_laugh,
		},
		{
			"Add/remove 😕 reaction",
			keymap["github.react.confused"],
			handler = require("octo.mappings").react_confused,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("integration.finder"):context_menu(menu, options)
end

function Github:changed_file_diff_menu(options)
	local keymap = settings.keymap
	local menu = {
		{
			"Add comment",
			keymap["github.comment.add"],
			handler = require("octo.mappings").add_review_comment,
		},
		{
			"Add suggestion",
			keymap["github.suggestion.add"],
			handler = require("octo.mappings").add_review_suggestion,
		},
		{
			"Move to next comment thread",
			keymap["github.review.thread.next"],
			handler = require("octo.mappings").next_thread,
		},
		{
			"Move to previous comment thread",
			keymap["github.review.thread.previous"],
			handler = require("octo.mappings").prev_thread,
		},
		{
			"Move to changed files",
			keymap["github.review.files.focus"],
			handler = require("octo.mappings").focus_files,
		},
		{
			"Select next changed file",
			keymap["github.review.files.next.select"],
			handler = require("octo.mappings").select_next_entry,
		},
		{
			"Select previous changed file",
			keymap["github.review.files.previous.select"],
			handler = require("octo.mappings").select_prev_entry,
		},
		{
			"Mark/Unmark file as viewed",
			keymap["github.review.files.viewed.toggle"],
			handler = require("octo.mappings").toggle_viewed,
		},
		{
			"Open/Close changed files list",
			keymap["github.review.files.toggle"],
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Close review tab",
			keymap["github.review.close"],
			handler = require("octo.mappings").close_review_tab,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("integration.finder"):context_menu(menu, options)
end

function Github:changed_files_list_menu(options)
	local keymap = settings.keymap
	local menu = {
		{
			"Next changed file",
			keymap["github.review.files.next"],
			handler = require("octo.mappings").next_entry,
		},
		{
			"Previous changed file",
			keymap["github.review.files.previous"],
			handler = require("octo.mappings").prev_entry,
		},
		{
			"Select changed file",
			keymap["github.review.files.select"],
			handler = require("octo.mappings").select_entry,
		},
		{
			"Select next changed file",
			keymap["github.review.files.next.select"],
			handler = require("octo.mappings").select_next_entry,
		},
		{
			"Select previous changed file",
			keymap["github.review.files.previous.select"],
			handler = require("octo.mappings").select_prev_entry,
		},
		{
			"Mark/Unmark file as viewed",
			keymap["github.review.files.viewed.toggle"],
			handler = require("octo.mappings").toggle_viewed,
		},
		{
			"Refresh changed files",
			keymap["github.review.files.refresh"],
			handler = require("octo.mappings").refresh_files,
		},
		{
			"Open/Close changed files list",
			keymap["github.review.files.toggle"],
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Close review tab",
			keymap["github.review.close"],
			handler = require("octo.mappings").close_review_tab,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("integration.finder"):context_menu(menu, options)
end

function Github:pull_request_menu(options)
	local keymap = settings.keymap
	local menu = {
		{
			"Checkout pull request",
			keymap["github.pull.checkout"],
			handler = require("octo.mappings").checkout_pr,
		},
		{
			"Add comment",
			keymap["github.comment.add"],
			handler = require("octo.mappings").add_comment,
		},
		{
			"Delete comment",
			keymap["github.comment.delete"],
			handler = require("octo.mappings").delete_comment,
		},
		{
			"Go to next comment",
			keymap["github.comment.next"],
			handler = require("octo.mappings").next_comment,
		},
		{
			"Go to previous comment",
			keymap["github.comment.previous"],
			handler = require("octo.mappings").prev_comment,
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
			"List pull request changes",
			keymap["github.pull.changes.list"],
			handler = require("octo.mappings").list_changed_files,
		},
		{
			"Show pull request diff",
			keymap["github.pull.diff"],
			handler = require("octo.mappings").show_pr_diff,
		},
		{
			"List pull request commits",
			keymap["github.pull.commits.diff"],
			handler = require("octo.mappings").list_commits,
		},
		{
			"Add comment",
			keymap["github.comment.add"],
			handler = require("octo.mappings").add_comment,
		},
		{
			"Merge pull request with merge commit",
			handler = function()
				local delete_branch = vim.fn.confirm("Delete branch after merging?", "&Yes\n&No\n&Cancel", 2)

				if delete_branch == 1 then
					return vim.fn.execute("Octo pr merge commit delete")
				elseif delete_branch == 2 then
					return vim.fn.execute("Octo pr merge commit")
				end
			end,
		},
		{
			"Squash and merge pull request",
			handler = function()
				local delete_branch = vim.fn.confirm("Delete branch after merging?", "&Yes\n&No\n&Cancel", 2)

				if delete_branch == 1 then
					return vim.fn.execute("Octo pr merge squash delete")
				elseif delete_branch == 2 then
					return vim.fn.execute("Octo pr merge squash")
				end
			end,
		},
		{
			"Rebase and merge",
			handler = function()
				local delete_branch = vim.fn.confirm("Delete branch after merging?", "&Yes\n&No\n&Cancel", 2)

				if delete_branch == 1 then
					return vim.fn.execute("Octo pr merge rebase delete")
				elseif delete_branch == 2 then
					return vim.fn.execute("Octo pr merge rebase")
				end
			end,
		},
		--[[ {
			"Merge pull request",
			"<space>pm",
			handler = require("octo.mappings").merge_pr,
		},
		{
			"Squash and merge pull request",
			"<space>psm",
			handler = require("octo.mappings").squash_and_merge_pr,
		}, ]]
		{
			"Add pull request reviewer",
			keymap["github.pull.reviewer.add"],
			handler = require("octo.mappings").add_reviewer,
		},
		{
			"Remove pull request reviewer",
			keymap["github.pull.reviewer.remove"],
			handler = require("octo.mappings").remove_reviewer,
		},
		{
			"Mark pull request as ready for review",
			handler = fn.bind(vim.fn.execute, "Octo pr ready", ""),
		},
		{
			"Show the status of pull request checks",
			handler = fn.bind(vim.fn.execute, "Octo pr checks", ""),
		},
		{
			"Close pull request",
			keymap["github.pull.close"],
			handler = require("octo.mappings").close_issue,
		},
		{
			"Reopen pull request",
			keymap["github.pull.reopen"],
			handler = require("octo.mappings").reopen_issue,
		},
		{
			"Reload pull request",
			keymap["github.pull.refresh"],
			handler = require("octo.mappings").reload,
		},
		{
			"Open pull request in browser",
			keymap["github.pull.open.browser"],
			handler = require("octo.mappings").open_in_browser,
		},
		{
			"Copy pull request url",
			keymap["github.pull.copy.url"],
			handler = require("octo.mappings").copy_url,
		},
		{
			"Go to commented file",
			keymap["github.pull.open.file"],
			handler = require("octo.mappings").goto_file,
		},
		{
			"Add pull request assignee",
			keymap["github.pull.assignee.add"],
			handler = require("octo.mappings").add_assignee,
		},
		{
			"Remove pull request assignee",
			keymap["github.pull.assignee.remove"],
			handler = require("octo.mappings").remove_assignee,
		},
		{
			"Create label",
			keymap["github.pull.label.create"],
			handler = require("octo.mappings").create_label,
		},
		{
			"Add pull request label",
			keymap["github.pull.label.add"],
			handler = require("octo.mappings").add_label,
		},
		{
			"Remove pull request label",
			keymap["github.pull.label.remove"],
			handler = require("octo.mappings").remove_label,
		},
		{
			"Add pull request comment",
			keymap["github.comment.add"],
			handler = require("octo.mappings").add_comment,
		},
		{
			"Remove pull request comment",
			keymap["github.comment.delete"],
			handler = require("octo.mappings").delete_comment,
		},
		{
			"Go to next comment",
			keymap["github.comment.next"],
			handler = require("octo.mappings").next_comment,
		},
		{
			"Go to previous comment",
			keymap["github.comment.previous"],
			handler = require("octo.mappings").prev_comment,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("integration.finder"):context_menu(menu, options)
end

function Github:thread_actions_menu(options)
	local keymap = settings.keymap
	local menu = {
		{
			"Add comment",
			keymap["github.comment.add"],
			handler = require("octo.mappings").add_comment,
		},
		-- NOTE: this seems not to be working in threads
		--[[ {
			"Add suggestion",
			"<space>sa",
			handler = require("octo.mappings").add_suggestion,
		}, ]]
		{
			"Delete comment",
			keymap["github.comment.delete"],
			handler = require("octo.mappings").delete_comment,
		},
		{
			"Go to next comment",
			keymap["github.comment.next"],
			handler = require("octo.mappings").next_comment,
		},
		{
			"Go to previous comment",
			keymap["github.comment.previous"],
			handler = require("octo.mappings").prev_comment,
		},
		{
			"Move to changed files list",
			keymap["github.review.files.focus"],
			handler = require("octo.mappings").focus_files,
		},
		{
			"Select next changed file",
			keymap["github.review.files.next.select"],
			handler = require("octo.mappings").select_next_entry,
		},
		{
			"Select previous changed file",
			keymap["github.review.files.previous.select"],
			handler = require("octo.mappings").select_prev_entry,
		},
		{
			"Open/Close changed files list",
			keymap["github.review.files.toggle"],
			handler = require("octo.mappings").toggle_files,
		},
		{
			"Close review tab",
			keymap["github.review.close"],
			handler = require("octo.mappings").close_review_tab,
		},
		on_select = function(modal_menu)
			local selection = modal_menu.state.get_selected_entry()
			modal_menu.actions.close(modal_menu.buffer)
			selection.value.handler()
		end,
	}

	require("integration.finder"):context_menu(menu, options)
end

function Github:actions_menu()
	local context_menus = {}
	local buffer_name = vim.api.nvim_buf_get_name(0)

	-- Pull request buffer
	if string.match(buffer_name, "^octo://.+/pull/%d+$") then
		local pr_menu_prompt_title = "Pull request #" .. vim.fn.fnamemodify(buffer_name, ":t")
		table.insert(
			context_menus,
			{ prompt_title = pr_menu_prompt_title, find = fn.bind(self.pull_request_menu, self) }
		)
		table.insert(context_menus, { prompt_title = "Reactions", find = fn.bind(self.reactions_menu, self) })
	-- Changed files panel
	elseif string.match(buffer_name, "^.+/OctoChangedFiles%-%d+$") then
		table.insert(
			context_menus,
			{ prompt_title = "Changed files", find = fn.bind(self.changed_files_list_menu, self) }
		)
		table.insert(context_menus, { prompt_title = "Pending review", find = fn.bind(self.pending_review_menu, self) })
	-- Changed file diff panel (either left or right)
	elseif string.match(buffer_name, "^octo://.+/review/.+/file/.+$") then
		local prompt_title = vim.fn.fnamemodify(buffer_name, ":t")
		table.insert(context_menus, { prompt_title = prompt_title, find = fn.bind(self.changed_file_diff_menu, self) })
		table.insert(context_menus, { prompt_title = "Pending review", find = fn.bind(self.pending_review_menu, self) })
	-- Comment thread panel
	elseif string.match(buffer_name, "^octo://.+/review/.+/threads/.+$") then
		local thread_menu_prompt_title = vim.fn.fnamemodify(buffer_name, ":t")
		table.insert(
			context_menus,
			{ prompt_title = thread_menu_prompt_title, find = fn.bind(self.thread_actions_menu, self) }
		)
		table.insert(context_menus, { prompt_title = "Reactions", find = fn.bind(self.reactions_menu, self) })
		table.insert(context_menus, { prompt_title = "Pending review", find = fn.bind(self.pending_review_menu, self) })
	end

	if #context_menus > 1 then
		table.insert(context_menus, { prompt_title = "Repository", find = fn.bind(self.repository_menu, self) })
		return require("integration.finder"):tabs(context_menus):find()
	end

	return self:repository_menu({ prompt_title = "Repository" })
end

function Github:_setup_plugins()
	local config = settings.config
	local keymap = settings.keymap

	require("octo").setup({
		right_bubble_delimiter = config["theme.section_separator"],
		left_bubble_delimiter = config["theme.section_separator"],
		mappings = {
			issue = {
				--[[ close_issue = { lhs = "<space>ic", desc = "close issue" },
				reopen_issue = { lhs = "<space>io", desc = "reopen issue" },
				list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
				reload = { lhs = "<C-r>", desc = "reload issue" },
				open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
				copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
				add_assignee = { lhs = "<space>aa", desc = "add assignee" },
				remove_assignee = { lhs = "<space>ad", desc = "remove assignee" },
				create_label = { lhs = "<space>lc", desc = "create label" },
				add_label = { lhs = "<space>la", desc = "add label" },
				remove_label = { lhs = "<space>ld", desc = "remove label" },
				goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" }, ]]
				add_comment = { lhs = keymap["github.comment.add"], desc = "add comment" },
				delete_comment = { lhs = keymap["github.comment.delete"], desc = "delete comment" },
				next_comment = { lhs = keymap["github.comment.next"], desc = "go to next comment" },
				prev_comment = { lhs = keymap["github.comment.previous"], desc = "go to previous comment" },
				react_hooray = { lhs = keymap["github.react.tada"], desc = "add/remove 🎉 reaction" },
				react_heart = { lhs = keymap["github.react.heart"], desc = "add/remove ❤️ reaction" },
				react_eyes = { lhs = keymap["github.react.eyes"], desc = "add/remove 👀 reaction" },
				react_thumbs_up = { lhs = keymap["github.react.thumbs_up"], desc = "add/remove 👍 reaction" },
				react_thumbs_down = { lhs = keymap["github.react.thumbs_down"], desc = "add/remove 👎 reaction" },
				react_rocket = { lhs = keymap["github.react.rocket"], desc = "add/remove 🚀 reaction" },
				react_laugh = { lhs = keymap["github.react.laugh"], desc = "add/remove 😄 reaction" },
				react_confused = { lhs = keymap["github.react.confused"], desc = "add/remove 😕 reaction" },
			},
			pull_request = {
				checkout_pr = { lhs = keymap["github.pull.checkout"], desc = "checkout PR" },
				-- merge_pr = { lhs = "<space>pm", desc = "merge commit PR" },
				-- squash_and_merge_pr = { lhs = "<space>psm", desc = "squash and merge PR" },
				list_commits = { lhs = keymap["github.pull.commits.diff"], desc = "list PR commits" },
				list_changed_files = { lhs = keymap["github.pull.changes.list"], desc = "list PR changed files" },
				show_pr_diff = { lhs = keymap["github.pull.diff"], desc = "show PR diff" },
				add_reviewer = { lhs = keymap["github.pull.reviewer.add"], desc = "add reviewer" },
				remove_reviewer = { lhs = keymap["github.pull.reviewer.remove"], desc = "remove reviewer request" },
				close_issue = { lhs = "<space>ic", desc = "close PR" },
				reopen_issue = { lhs = keymap["github.pull.close"], desc = "reopen PR" },
				-- list_issues = { lhs = "<space>il", desc = "list open issues on same repo" },
				reload = { lhs = keymap["github.pull.refresh"], desc = "reload PR" },
				open_in_browser = { lhs = keymap["github.pull.open.browser"], desc = "open PR in browser" },
				copy_url = { lhs = keymap["github.pull.copy.url"], desc = "copy url to system clipboard" },
				goto_file = { lhs = keymap["github.pull.open.file"], desc = "go to file" },
				add_assignee = { lhs = keymap["github.pull.assignee.add"], desc = "add assignee" },
				remove_assignee = { lhs = keymap["github.pull.assignee.remove"], desc = "remove assignee" },
				create_label = { lhs = keymap["github.pull.label.create"], desc = "create label" },
				add_label = { lhs = keymap["github.pull.label.add"], desc = "add label" },
				remove_label = { lhs = keymap["github.pull.label.remove"], desc = "remove label" },
				-- goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
				add_comment = { lhs = keymap["github.comment.add"], desc = "add comment" },
				delete_comment = { lhs = keymap["github.comment.delete"], desc = "delete comment" },
				next_comment = { lhs = keymap["github.comment.next"], desc = "go to next comment" },
				prev_comment = { lhs = keymap["github.comment.previous"], desc = "go to previous comment" },
				react_hooray = { lhs = keymap["github.react.tada"], desc = "add/remove 🎉 reaction" },
				react_heart = { lhs = keymap["github.react.heart"], desc = "add/remove ❤️ reaction" },
				react_eyes = { lhs = keymap["github.react.eyes"], desc = "add/remove 👀 reaction" },
				react_thumbs_up = { lhs = keymap["github.react.thumbs_up"], desc = "add/remove 👍 reaction" },
				react_thumbs_down = { lhs = keymap["github.react.thumbs_down"], desc = "add/remove 👎 reaction" },
				react_rocket = { lhs = keymap["github.react.rocket"], desc = "add/remove 🚀 reaction" },
				react_laugh = { lhs = keymap["github.react.laugh"], desc = "add/remove 😄 reaction" },
				react_confused = { lhs = keymap["github.react.confused"], desc = "add/remove 😕 reaction" },
			},
			review_thread = {
				-- goto_issue = { lhs = "<space>gi", desc = "navigate to a local repo issue" },
				add_comment = { lhs = keymap["github.comment.add"], desc = "add review comment" },
				delete_comment = { lhs = keymap["github.comment.delete"], desc = "delete review comment" },
				next_comment = { lhs = keymap["github.comment.next"], desc = "go to next review comment" },
				prev_comment = { lhs = keymap["github.comment.previous"], desc = "go to review previous comment" },
				add_suggestion = { lhs = keymap["github.suggestion.add"], desc = "add review suggestion" },
				select_next_entry = {
					lhs = keymap["github.review.files.next.select"],
					desc = "move to previous changed file",
				},
				select_prev_entry = {
					lhs = keymap["github.review.files.previous.select"],
					desc = "move to next changed file",
				},
				close_review_tab = { lhs = keymap["github.review.close"], desc = "close review tab" },
				react_hooray = { lhs = keymap["github.react.tada"], desc = "add/remove 🎉 reaction" },
				react_heart = { lhs = keymap["github.react.heart"], desc = "add/remove ❤️ reaction" },
				react_eyes = { lhs = keymap["github.react.eyes"], desc = "add/remove 👀 reaction" },
				react_thumbs_up = { lhs = keymap["github.react.thumbs_up"], desc = "add/remove 👍 reaction" },
				react_thumbs_down = { lhs = keymap["github.react.thumbs_down"], desc = "add/remove 👎 reaction" },
				react_rocket = { lhs = keymap["github.react.rocket"], desc = "add/remove 🚀 reaction" },
				react_laugh = { lhs = keymap["github.react.laugh"], desc = "add/remove 😄 reaction" },
				react_confused = { lhs = keymap["github.react.confused"], desc = "add/remove 😕 reaction" },
			},
			submit_win = {
				approve_review = { lhs = keymap["github.review.submit.approve"], desc = "approve review" },
				comment_review = { lhs = keymap["github.review.submit.comment"], desc = "comment review" },
				request_changes = {
					lhs = keymap["github.review.submit.request_changes"],
					desc = "request changes review",
				},
				close_review_tab = { lhs = keymap["github.review.close"], desc = "close review tab" },
			},
			review_diff = {
				add_review_comment = { lhs = keymap["github.comment.add"], desc = "add a new review comment" },
				add_review_suggestion = {
					lhs = keymap["github.suggestion.add"],
					desc = "add a new review suggestion",
				},
				focus_files = { lhs = keymap["github.review.files.focus"], desc = "move focus to changed file panel" },
				toggle_files = { lhs = keymap["github.review.files.toggle"], desc = "hide/show changed files panel" },
				next_thread = { lhs = keymap["github.review.thread.next"], desc = "move to next thread" },
				prev_thread = { lhs = keymap["github.review.thread.previous"], desc = "move to previous thread" },
				select_next_entry = {
					lhs = keymap["github.review.files.next.select"],
					desc = "move to previous changed file",
				},
				select_prev_entry = {
					lhs = keymap["github.review.files.previous.select"],
					desc = "move to next changed file",
				},
				close_review_tab = { lhs = keymap["github.review.close"], desc = "close review tab" },
				toggle_viewed = {
					lhs = keymap["github.review.files.viewed.toggle"],
					desc = "toggle viewer viewed state",
				},
			},
			file_panel = {
				next_entry = { lhs = keymap["github.review.files.next"], desc = "move to next changed file" },
				prev_entry = { lhs = keymap["github.review.files.previous"], desc = "move to previous changed file" },
				select_entry = {
					lhs = keymap["github.review.files.select"],
					desc = "show selected changed file diffs",
				},
				refresh_files = { lhs = keymap["github.review.files.refresh"], desc = "refresh changed files panel" },
				focus_files = { lhs = keymap["github.review.files.focus"], desc = "move focus to changed file panel" },
				toggle_files = { lhs = keymap["github.review.files.toggle"], desc = "hide/show changed files panel" },
				select_next_entry = {
					lhs = keymap["github.review.files.next.select"],
					desc = "move to previous changed file",
				},
				select_prev_entry = {
					lhs = keymap["github.review.files.previous.select"],
					desc = "move to next changed file",
				},
				close_review_tab = { lhs = keymap["github.review.close"], desc = "close review tab" },
				toggle_viewed = {
					lhs = keymap["github.review.files.viewed.toggle"],
					desc = "toggle viewer viewed state",
				},
			},
		},
	})
end

return Github:new()
