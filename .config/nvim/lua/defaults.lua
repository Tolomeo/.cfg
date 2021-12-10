	--Incremental live completion (note: this is now a default on master)
	vim.o.inccommand = 'nosplit'

	--Set highlight on search
	vim.o.hlsearch = true

	--Make line numbers default
	vim.wo.number = true

	--Do not save when switching buffers (note: this is now a default on master)
	vim.o.hidden = true

	-- Do not automatically create backup files
	vim.o.backup = false
	vim.o.writebackup = false

	--Enable mouse mode
	vim.o.mouse = 'a'

	--Enable break indent
	vim.o.breakindent = true

	--Save undo history
	vim.opt.undofile = true

	--Case insensitive searching UNLESS /C or capital in search
	vim.o.ignorecase = true
	vim.o.smartcase = true

	--Decrease update time
	vim.o.updatetime = 250

	-- Always show signcolumn
	vim.wo.signcolumn = 'yes'

	--Set colorscheme (order is important here)
	vim.o.termguicolors = true

	--Indent size
	vim.o.shiftwidth = 2
	vim.o.tabstop = 2
	vim.o.autoindent = true
	vim.o.smartindent = true

	-- Avoid word wrap because it's weird
	vim.o.wrap = false

	--Remap space as leader key
	vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
	vim.g.mapleader = ' '
	vim.g.maplocalleader = ' '

	-- Killing netrw
	vim.g.netrw_banner = 0
	vim.g.netrw_menu = 0
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
