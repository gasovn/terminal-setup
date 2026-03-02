local wezterm = require 'wezterm'
local M = {}

function M.apply(config)
    -- Auto-generate SSH domains from ~/.ssh/config
    -- Each Host entry becomes a launchable domain
    config.ssh_domains = wezterm.default_ssh_domains()
end

return M
