local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")
local au = require("_shared.au")

local Git = {}

Git.plugins = {
	-- Add git related info in the signs columns and popups
	{ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } },
	-- Github issues and reviews
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

Git.setup = function()
	Git._setup_keymaps()
	Git._setup_plugins()
end

Git._setup_keymaps = function()
	local keymaps = settings.keymaps()

	key.nmap(
		{ keymaps["git.blame"], Git.blame },
		{ keymaps["git.log"], Git.log },
		{ keymaps["git.diff"], Git.diff },
		{ keymaps["git.merge"], Git.mergetool },
		{ keymaps["git.hunk"], Git.show_hunk_preview },
		{ keymaps["git.hunk.next"], Git.next_hunk_preview(keymaps["git.hunk.next"]) },
		{ keymaps["git.hunk.prev"], Git.prev_hunk_preview(keymaps["git.hunk.prev"]) },
		{ "<leader>G", Git.github_actions_menu }
	)

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

Git.pull_requests_menu = function(options)
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

Git.issues_menu = function(options)
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

Git._is_review_diff = function()
	local has_review = require("octo.reviews").get_current_review()
	local in_diff_window = require("octo.utils").in_diff_window()

	return has_review and in_diff_window
end

Git.diff_menu = function(options)
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

Git._is_changed_files_list = function()
	return vim.api.nvim_buf_get_option(0, "filetype") == "octo_panel"
end

Git.files_changes_menu = function(options)
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

Git.github_actions_menu = function()
	local github_pickers = {
		{ prompt_title = "GH Pull Requests", find = Git.pull_requests_menu },
		{ prompt_title = "GH Issues", find = Git.issues_menu },
	}

	if Git._is_review_diff() then
		table.insert(github_pickers, 1, { prompt_title = "Diff actions", find = Git.diff_menu })
	elseif Git._is_changed_files_list() then
		table.insert(github_pickers, 1, { prompt_title = "Changed files", find = Git.files_changes_menu })
	end

	require("finder.picker").Pickers(github_pickers):find()
end

Git._setup_plugins = function()
	-- GitSigns
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

function Git.blame()
	key.input(":Git blame<CR>")
end

function Git.log()
	key.input(":Git log<CR>")
end

function Git.diff()
	key.input(":Git diff<CR>")
end

function Git.mergetool()
	key.input(":Git mergetool<CR>")
end

-- TODO: move to core?
function Git.has_diff()
	return vim.api.nvim_win_get_option(0, "diff") ~= 0
end

function Git.show_hunk_preview()
	require("gitsigns").preview_hunk()
end

-- vim.api.nvim_set_keymap("n", "<TAB>", "&diff ? '<TAB>' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function Git.next_hunk_preview(next)
	return function()
		if not Git.has_diff() then
			key.input(next)
			return
		end

		require("gitsigns.actions").next_hunk()
	end
end

-- vim.api.nvim_set_keymap("n", "<S-TAB>", "&diff ? '<S-TAB>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", {noremap = true, silent = true, expr = true})
function Git.prev_hunk_preview(next)
	return function()
		if not Git.has_diff() then
			key.input(next)
			return
		end

		require("gitsigns.actions").prev_hunk()
	end
end

return Module:new(Git)
