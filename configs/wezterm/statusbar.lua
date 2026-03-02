local wezterm = require 'wezterm'
local utils = require 'utils'
local M = {}

-- ══ THEME: BEGIN ══
-- Gruvbox Material colors for WezTerm statusbar.lua
local c = {
    base     = '#282828',
    surface0 = '#32302f',
    surface1 = '#45403d',
    teal     = '#89b482',
    mauve    = '#d3869b',
    blue     = '#7daea3',
    green    = '#a9b665',
    yellow   = '#d8a657',
    peach    = '#e78a4e',
    text     = '#d4be98',
    overlay1 = '#928374',
}
-- ══ THEME: END ══

function M.setup()
    wezterm.on('update-status', function(window, pane)
        -- ── Track active tab for MRU switching (Ctrl+Tab) ──
        local win_id = tostring(window:window_id())
        local current_idx = 0
        for _, t in ipairs(window:mux_window():tabs_with_info()) do
            if t.is_active then current_idx = t.index; break end
        end
        if not wezterm.GLOBAL.mru then wezterm.GLOBAL.mru = {} end
        local mru = wezterm.GLOBAL.mru[win_id]
        if not mru then
            wezterm.GLOBAL.mru[win_id] = { prev = current_idx, current = current_idx }
        elseif mru.current ~= current_idx then
            wezterm.GLOBAL.mru[win_id] = { prev = mru.current, current = current_idx }
        end

        -- ── Left status: workspace ──
        local workspace = window:active_workspace()
        local left = wezterm.format {
            { Background = { Color = c.teal } },
            { Foreground = { Color = c.base } },
            { Text = '  ' .. workspace .. ' ' },
            { Background = { Color = 'none' } },
            { Foreground = { Color = c.teal } },
            { Text = '' },
        }
        window:set_left_status(left)

        -- ── Right status: [ssh host] | directory | date time ──
        local right_cells = {}

        -- SSH hostname (if connected via SSH domain)
        local domain = pane:get_domain_name()
        if domain and domain ~= 'local' and domain ~= '' then
            table.insert(right_cells, { icon = '󰣀', text = domain, fg = c.green })
        end

        -- Current directory
        local cwd = pane:get_current_working_dir()
        if cwd then
            local dir = cwd.file_path or tostring(cwd)
            table.insert(right_cells, { icon = '󰉋', text = utils.shorten_path(dir), fg = c.blue })
        end

        -- Battery (only if available)
        local battery = utils.get_battery()
        if battery then
            table.insert(right_cells, { icon = '', text = battery, fg = c.yellow })
        end

        -- Date & time
        local time = wezterm.strftime '%Y-%m-%d  %H:%M'
        table.insert(right_cells, { icon = '', text = time, fg = c.overlay1 })

        -- Build right status with powerline separators
        local elements = {}
        for i, cell in ipairs(right_cells) do
            local bg = (i == 1) and 'none' or c.surface0
            table.insert(elements, { Foreground = { Color = c.surface0 } })
            table.insert(elements, { Background = { Color = bg } })
            table.insert(elements, { Text = '' })
            table.insert(elements, { Background = { Color = c.surface0 } })
            table.insert(elements, { Foreground = { Color = cell.fg } })
            table.insert(elements, { Text = ' ' .. cell.icon .. ' ' .. cell.text .. ' ' })
        end

        window:set_right_status(wezterm.format(elements))
    end)
end

return M
