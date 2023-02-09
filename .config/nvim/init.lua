local settings = require("settings")
local config = require("config")
local fs = require("_shared.fs")

-- User settings

local settings_dir = vim.fn.stdpath("data") .. "/cfg"
local settings_dir_exists, settings_dir_error

settings_dir_exists = fs.existsSync(settings_dir)

if not settings_dir_exists then
	settings_dir_exists, settings_dir_error = fs.mkdirSync(settings_dir)
end

local user_settings_file = settings_dir .. "/settings.json"
local user_settings_exists, user_settings_error, user_settings

if settings_dir_error then
	error(settings_dir_error)
end

user_settings_exists = fs.existsSync(user_settings_file)

if not user_settings_exists then
	user_settings_exists, user_settings_error = fs.writeFileSync(user_settings_file, "{}")
end

if user_settings_error then
	error(user_settings_error)
end

user_settings, user_settings_error = fs.readFileSync(user_settings_file)

if user_settings_error then
	error(user_settings_error)
end

user_settings = vim.fn.json_decode(user_settings)

settings(user_settings)

-- Initialisation
config:init()
