-- SSH host definitions loader.
-- Tries to load real hosts from private/wezterm/ssh-hosts.lua.
-- Falls back to empty list if private config is not present.
-- See ssh-hosts.example.lua for the expected format.

local dir = debug.getinfo(1, 'S').source:match('@?(.*/)') or ''
local ok, hosts = pcall(dofile, dir .. '../private/wezterm/ssh-hosts.lua')
if not ok then hosts = {} end
return hosts
