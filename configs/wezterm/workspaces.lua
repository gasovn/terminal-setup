local wezterm = require 'wezterm'
local M = {}

function M.apply(config)
    -- Default workspace name
    config.default_workspace = 'main'
end

return M
