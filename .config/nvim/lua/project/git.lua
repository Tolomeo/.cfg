local Module = require("_shared.module")
local key = require("_shared.key")
local fn = require("_shared.fn")
local settings = require("settings")

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
end

Git.github_prs_actions_menu = function(options)
	local results = {
		{
			"List",
			function()
				vim.fn.execute("Octo pr list", "")
			end,
		},
		{
			"Create",
			function()
				vim.fn.execute("Octo pr create", "")
			end,
		},
		{
			"Search",
			function()
				vim.fn.execute("Octo pr search", "")
			end,
		},
	}
	local items = {
		results = results,
		entry_maker = function(pull_request_action)
			return {
				value = pull_request_action,
				ordinal = pull_request_action[1],
				display = pull_request_action[1],
			}
		end,
	}
	local on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		local pull_request_action = selection.value[2]
		modal_menu.actions.close(modal_menu.buffer)
		vim.defer_fn(function()
			pull_request_action()
		end, 1)
	end

	require("finder.picker").modal_menu(items, on_select, options)
end

Git.github_issues_actions_menu = function(options)
	local results = {
		{
			"List",
			function()
				vim.fn.execute("Octo issue list", "")
			end,
		},
		{
			"Create",
			function()
				vim.fn.execute("Octo issue create", "")
			end,
		},
		{
			"Search",
			function()
				vim.fn.execute("Octo issue search", "")
			end,
		},
	}
	local items = {
		results = results,
		entry_maker = function(pull_request_action)
			return {
				value = pull_request_action,
				ordinal = pull_request_action[1],
				display = pull_request_action[1],
			}
		end,
	}
	local on_select = function(modal_menu)
		local selection = modal_menu.state.get_selected_entry()
		local pull_request_action = selection.value[2]
		modal_menu.actions.close(modal_menu.buffer)
		vim.defer_fn(function()
			pull_request_action()
		end, 1)
	end

	require("finder.picker").modal_menu(items, on_select, options)
end

Git.github_actions_menu = function()
	require("finder.picker").Pickers({
		{ prompt_title = "Pull Requests", find = Git.github_prs_actions_menu },
		{ prompt_title = "Issues", find = Git.github_issues_actions_menu },
	}):find()
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
	require("octo").setup()
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
