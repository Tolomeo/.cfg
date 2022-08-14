local config = require("config")
local settings = require("settings")

-- User settings
local custom_settings_file = vim.fn.stdpath("config") .. "/settings.lua"
local custom_settings = vim.fn.filereadable(custom_settings_file) == 1 and dofile(custom_settings_file) or {}

settings.globals(custom_settings.globals or {})
settings.options(custom_settings.options or {})
settings.keymaps(custom_settings.keymaps or {})

-- Initialisation
config:init(custom_settings.options, custom_settings.keymaps)
