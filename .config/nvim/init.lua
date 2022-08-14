local settings = require("settings")
local config = require("config")

-- User settings
local custom_settings_file = vim.fn.stdpath("config") .. "/settings.lua"
local custom_settings = vim.fn.filereadable(custom_settings_file) == 1 and dofile(custom_settings_file) or {}
settings(custom_settings)

-- Initialisation
config:init()
