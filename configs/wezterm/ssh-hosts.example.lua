-- SSH host definitions for WezTerm SSH domains and launcher menu.
-- Copy this file to private/wezterm/ssh-hosts.lua and fill in your hosts.
--
-- Fields:
--   name  (required) — SSH host alias (must match Host in SSH config)
--   group (required) — group label shown in the SSH connect menu
--   host  (required) — IP address or hostname
--   port  (optional) — SSH port, default 22
--   cmd   (optional) — command to run after SSH connection establishes

return {
  { name = 'my-server',  group = 'Example',     host = '10.0.0.XXX' },
  { name = 'my-db',      group = 'Databases',    host = '10.0.0.XXX', port = 5432 },
  { name = 'my-app',     group = 'Application',  host = '10.0.0.XXX', cmd = 'sudo -iu deploy' },
}
