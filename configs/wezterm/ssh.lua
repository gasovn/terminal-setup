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
        -- Host entry: "󰣀 gitlab  (10.0.0.230 :2200)"
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
                    -- Use SSHMUX: domain — auto-generated from ~/.ssh/config
                    local domain_name = 'SSHMUX:' .. id
                    local _tab, new_pane, _mux_win =
                        w:mux_window():spawn_tab { domain = { DomainName = domain_name } }
                    -- Send auto-command after SSH connection establishes
                    if h.cmd and new_pane then
                        wezterm.time.call_after(2, function()
                            new_pane:send_text(h.cmd .. '\n')
                        end)
                    end
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
