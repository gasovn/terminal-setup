local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Default shell
config.default_prog = { '/usr/bin/fish' }

-- Load modules
require('appearance').apply(config)
require('keybinds').apply(config)
require('kitty-cyrillic-fix').apply(config)
require('ssh').apply(config)
require('workspaces').apply(config)
require('hyperlinks').apply(config)
require('statusbar').setup()
require('nvim-open').setup()
local session_ok, session_err = pcall(function() require('session.init').setup() end)
if not session_ok then
    wezterm.log_error('session restore disabled: ' .. tostring(session_err))
end

return config
