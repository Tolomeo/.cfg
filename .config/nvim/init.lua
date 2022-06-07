local config = require("config")

-- User settings
local settings_file = vim.fn.stdpath("config") .. "/settings.lua"
local settings = vim.fn.filereadable(settings_file) == 1 and dofile(settings_file) or nil

-- Initialisation
config:init(settings)
