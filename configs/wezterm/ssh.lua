local wezterm = require 'wezterm'
local hosts = require 'ssh-hosts'
local M = {}

local DEFAULT_PORT = 22

-- ── Helpers ──────────────────────────────────────────────────────────

-- Build grouped choices list for InputSelector.
-- icon: nerd-font glyph prepended to each host label.
local function build_choices(icon)
    local choices = {}
    local seen_group = nil
    for _, h in ipairs(hosts) do
        local port = h.port or DEFAULT_PORT
        -- Group separator
        if h.group and h.group ~= seen_group then
            seen_group = h.group
            table.insert(choices, { id = '', label = '── ' .. h.group .. ' ──' })
        end
        -- Host entry: "󰣀 gitlab  (10.0.0.XXX :2200)"
        local suffix = h.host
        if port ~= DEFAULT_PORT then
            suffix = suffix .. ' :' .. port
        end
        local label = icon .. ' ' .. h.name .. '  (' .. suffix .. ')'
        table.insert(choices, { id = h.name, label = label })
    end
    return choices
end

-- Find host entry by name.
local function find_host(name)
    for _, h in ipairs(hosts) do
        if h.name == name then return h end
    end
    return nil
end

-- ── SSH domains ──────────────────────────────────────────────────────

-- Use WezTerm's auto-generated domains from ~/.ssh/config.
-- They correctly inherit all SSH settings (ports, keys, proxy, etc.).
-- ssh-hosts.lua provides only UI metadata: groups and auto-commands.
function M.apply(config)
    config.ssh_domains = wezterm.default_ssh_domains()
end

-- ── SSH connect menu ─────────────────────────────────────────────────

function M.connect_action()
    return wezterm.action_callback(function(window, pane)
        local choices = build_choices '󰣀'
        window:perform_action(
            wezterm.action.InputSelector {
                title = '  SSH Connect',
                choices = choices,
                action = wezterm.action_callback(function(w, p, id, _label)
                    if not id or id == '' then return end
                    local h = find_host(id)
                    if not h then return end
                    -- Use SSH: domain — no WezTerm needed on remote host
                    local domain_name = 'SSH:' .. id
                    -- Run the host's auto-command as the session program. On an
                    -- SSH: domain (multiplexing None) args execute on the remote,
                    -- so this avoids the timing race of typing into the pane
                    -- before the remote shell is ready. After the cmd returns we
                    -- exec the connecting user's login shell, so exiting the cmd
                    -- (e.g. `sudo -iu deploy`) drops back into your own account
                    -- instead of closing the tab.
                    local spawn = { domain = { DomainName = domain_name } }
                    if h.cmd then
                        spawn.args = { 'sh', '-c', h.cmd .. '; exec "$SHELL" -l' }
                    end
                    -- A domain whose last tab was closed goes Detached, and
                    -- spawn_tab refuses to spawn into a Detached domain (the menu
                    -- would then silently do nothing). Re-attach it first.
                    local dom = wezterm.mux.get_domain(domain_name)
                    if dom and dom:state() == 'Detached' then
                        dom:attach()
                    end
                    w:mux_window():spawn_tab(spawn)
                end),
            },
            pane
        )
    end)
end

-- ── SFTP menu ────────────────────────────────────────────────────────

function M.sftp_action()
    return wezterm.action_callback(function(window, pane)
        local choices = build_choices '󰉋'
        window:perform_action(
            wezterm.action.InputSelector {
                title = '󰉋  SFTP — Open in Dolphin',
                choices = choices,
                action = wezterm.action_callback(function(_w, _p, id, _label)
                    if not id or id == '' then return end
                    wezterm.run_child_process { 'dolphin', 'sftp://' .. id .. '/' }
                end),
            },
            pane
        )
    end)
end

return M
