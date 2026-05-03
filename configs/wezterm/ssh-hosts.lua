-- SSH host definitions loader.
-- Tries to load real hosts from <repo>/private/wezterm/ssh-hosts.lua.
-- Falls back to empty list if private config is not present.
-- See ssh-hosts.example.lua for the expected format.

local wezterm = require 'wezterm'

-- ~/.config/wezterm is a symlink into the repo (configs/wezterm), so we need
-- the resolved path to navigate `..` up to the repo root rather than ~/.config/.
-- run_child_process is async (yields) and not allowed at config-load time, so
-- shell out via io.popen for a synchronous readlink.
local function realpath(p)
  local h = io.popen("readlink -f '" .. p:gsub("'", "'\\''") .. "' 2>/dev/null")
  if not h then return p end
  local out = h:read('*l')
  h:close()
  return out or p
end

local wezterm_dir = realpath(wezterm.config_dir)
local ok, hosts = pcall(dofile, wezterm_dir .. '/../../private/wezterm/ssh-hosts.lua')
if not ok then hosts = {} end
return hosts
