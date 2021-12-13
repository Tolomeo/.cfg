local cmd = vim.api.nvim_command

local function autocmd(this, event, spec)
    local is_table = type(spec) == 'table'
    local pattern = is_table and spec[1] or '*'
    local action = is_table and spec[2] or spec
    if type(action) == 'function' then
        action = this.set(action)
    end
    local e = type(event) == 'table' and table.concat(event, ',') or event
    cmd('autocmd ' .. e .. ' ' .. pattern .. ' ' .. action)
end

local S = {
    __au = {},
}

local X = setmetatable({}, {
    __index = S,
    __newindex = autocmd,
    __call = autocmd,
})

function S.exec(id)
    S.__au[id]()
end

function S.set(fn)
    local id = string.format('%p', fn)
    S.__au[id] = fn
    return string.format('lua require("utils.au").exec("%s")', id)
end

function S.group(grp, cmds)
    cmd('augroup ' .. grp)
    cmd('autocmd!')
    if type(cmds) == 'function' then
        cmds(X)
    else
        for _, au in ipairs(cmds) do
            autocmd(S, au[1], { au[2], au[3] })
        end
    end
    cmd('augroup END')
end

return X

--[[
https://gist.github.com/numToStr/1ab83dd2e919de9235f9f774ef8076da

-- # Simple autocmd with one event: au.<event> = string | fn | { pattern: string, action: string | fn }

-- 1. If you want aucmd to fire on every buffer, you can use the style below
au.TextYankPost = function()
    vim.highlight.on_yank({ higroup = 'Visual', timeout = 120 })
end

-- 2. With a pattern
au.BufEnter = {
    '*.txt',
    function()
        if vim.bo.buftype == 'help' then
            cmd('wincmd L')
            local nr = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_keymap(nr, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
        end
    end,
}

-- TIP: action can be a ex-cmd or a lua function
au.BufRead = function()
    print(vim.bo.filetype)
end

au.BufRead = { '*.txt', 'echo &ft' }

-- # Autocmd with multiple event: au(events: table, cmd: string | fn | {pattern: string, action: string | fn})

-- For this you can just call the required module just like a function
au({ 'BufNewFile', 'BufRead' }, {
    '.eslintrc,.prettierrc,*.json*',
    function()
        vim.bo.filetype = 'json'
    end,
})

-- # Autocmd group: au.group(group: string, cmds: fn(au) | {event: string, pattern: string, action: string | fn})

-- 1. Where action is a ex-cmd
au.group('PackerGroup', {
    { 'BufWritePost', 'plugins.lua', 'source <afile> | PackerCompile' },
})

-- 2. Where action is a function
au.group('CocOverrides', {
    {
        'FileType',
        'typescript,json',
        function()
            vim.api.nvim_buf_set_option(0, 'formatexpr', "CocAction('formatSelected')")
        end,
    },
    {
        'User',
        'CocJumpPlaceholder',
        function()
            vim.fn.CocActionAsync('showSignatureHelp')
        end,
    },
})


-- 3. Or behold some meta-magic
-- You can give a function as a second arg which receives aucmd-metatable as an argument
-- Which you can use to set autocmd individually
au.group('CocOverrides', function(grp)
    grp.FileType = {
        'typescript,json',
        function()
            vim.api.nvim_buf_set_option(0, 'formatexpr', "CocAction('formatSelected')")
        end,
    }
    grp.User = {
        'CocJumpPlaceholder',
        function()
            vim.fn.CocActionAsync('showSignatureHelp')
        end,
    }
end) ]]
