local wezterm = require 'wezterm'
local utils = require 'utils'
local M = {}

-- ══ THEME: BEGIN ══
-- Gruvbox Material palette for WezTerm appearance.lua
-- Semantic names mapped from Catppuccin → Gruvbox Material
M.colors = {
    rosewater = '#d3869b',   -- purple (warm accent)
    flamingo  = '#ea6962',   -- red
    pink      = '#d3869b',   -- purple
    mauve     = '#d3869b',   -- purple
    red       = '#ea6962',   -- red
    maroon    = '#ea6962',   -- red
    peach     = '#e78a4e',   -- orange
    yellow    = '#d8a657',   -- yellow
    green     = '#a9b665',   -- green
    teal      = '#89b482',   -- aqua (accent)
    sky       = '#89b482',   -- aqua
    sapphire  = '#7daea3',   -- blue
    blue      = '#7daea3',   -- blue
    lavender  = '#d3869b',   -- purple
    text      = '#d4be98',   -- fg
    subtext1  = '#ddc7a1',   -- fg1
    subtext0  = '#a89984',   -- grey2
    overlay2  = '#a89984',   -- grey2
    overlay1  = '#928374',   -- grey1
    overlay0  = '#7c6f64',   -- grey0
    surface2  = '#5a524c',   -- bg5
    surface1  = '#45403d',   -- bg3
    surface0  = '#32302f',   -- bg1
    base      = '#282828',   -- bg0
    mantle    = '#1d2021',   -- bg_dim
    crust     = '#141617',   -- darkest
}
M.scheme = 'Gruvbox Material (Gogh)'
-- ══ THEME: END ══

M.tab_palette = {
    { bg = M.colors.red,    fg = M.colors.base },
    { bg = M.colors.green,  fg = M.colors.base },
    { bg = M.colors.yellow, fg = M.colors.base },
    { bg = M.colors.blue,   fg = M.colors.base },
    { bg = M.colors.mauve,  fg = M.colors.base },
    { bg = M.colors.peach,  fg = M.colors.base },
}

function M.apply(config)
    local c = M.colors

    -- Color scheme
    config.color_scheme = M.scheme

    -- Font
    config.font = wezterm.font_with_fallback {
        { family = 'FiraCode Nerd Font', harfbuzz_features = { 'calt', 'liga', 'ss01', 'ss02', 'ss03' } },
        'Noto Color Emoji',
        'Symbols Nerd Font',
    }
    config.font_size = 13

    -- Window
    config.window_background_opacity = 0.95
    config.window_decorations = 'TITLE | RESIZE'
    config.window_padding = { left = 10, right = 20, top = 8, bottom = 8 }
    config.initial_cols = 170
    config.initial_rows = 42

    -- Cursor
    config.default_cursor_style = 'BlinkingBlock'
    config.cursor_blink_rate = 500
    config.cursor_blink_ease_in = 'Constant'
    config.cursor_blink_ease_out = 'Constant'

    -- Scrollbar
    config.enable_scroll_bar = true
    config.scrollback_lines = 10000

    -- Inactive panes dimmed
    config.inactive_pane_hsb = {
        saturation = 0.85,
        brightness = 0.7,
    }

    -- Fancy tab bar
    config.use_fancy_tab_bar = true
    config.show_new_tab_button_in_tab_bar = true
    config.tab_max_width = 40
    config.show_tab_index_in_tab_bar = true
    config.switch_to_last_active_tab_when_closing_tab = true

    -- Tab bar colors (Catppuccin Mocha)
    config.window_frame = {
        font = wezterm.font('FiraCode Nerd Font', { weight = 'Medium' }),
        font_size = 11,
        active_titlebar_bg = c.base,
        inactive_titlebar_bg = c.mantle,
    }

    config.colors = {
        tab_bar = {
            background = c.base,
            active_tab = {
                bg_color = c.teal,
                fg_color = c.base,
                intensity = 'Bold',
            },
            inactive_tab = {
                bg_color = c.surface0,
                fg_color = c.subtext1,
            },
            inactive_tab_hover = {
                bg_color = c.surface1,
                fg_color = c.text,
            },
            new_tab = {
                bg_color = c.surface0,
                fg_color = c.subtext1,
            },
            new_tab_hover = {
                bg_color = c.surface1,
                fg_color = c.text,
            },
        },
        split = c.surface1,
        visual_bell = c.surface0,
        scrollbar_thumb = c.overlay1,
    }

    -- Visual bell (no sound)
    config.audible_bell = 'Disabled'
    config.visual_bell = {
        fade_in_function = 'EaseIn',
        fade_in_duration_ms = 100,
        fade_out_function = 'EaseOut',
        fade_out_duration_ms = 100,
        target = 'CursorColor',
    }

    -- GPU and rendering
    config.front_end = 'WebGpu'
    config.webgpu_power_preference = 'HighPerformance'
    config.max_fps = 144
    config.animation_fps = 60

    -- Wayland
    config.enable_wayland = true

    -- Keyboard protocol (for Neovim)
    config.enable_kitty_keyboard = true
    config.debug_key_events = false

    -- Image protocol (for yazi previews)
    config.enable_kitty_graphics = true

    -- Auto-reload config on change
    config.automatically_reload_config = true

    -- Key map preference
    config.key_map_preference = 'Physical'

    -- Tab title formatting: [number: icon title ●]
    wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
        local pane = tab.active_pane
        local process = utils.basename(pane.foreground_process_name)
        local icon = utils.get_process_icon(process)
        local idx = tab.tab_index + 1

        local shells = { fish = true, bash = true, zsh = true }
        local title
        local dir

        local manual = tab.tab_title
        if manual and manual ~= '' then
            -- Manual name set via Ctrl+Shift+R — pencil icon, keep git dirty dot
            icon = '󰏫'
            title = manual
            local cwd = pane.current_working_dir
            if cwd then dir = cwd.file_path or tostring(cwd) end
        else
            -- SSH domain: show hostname from domain name (e.g. "SSH:stage" → "stage")
            local domain = pane.domain_name or ''
            local ssh_host_name = domain:match('^SSH:(.+)')
            if ssh_host_name then
                icon = '󰣀'
                title = ssh_host_name
            elseif shells[process] then
                local cwd = pane.current_working_dir
                if cwd then
                    dir = cwd.file_path or tostring(cwd)
                    title = process .. ' ' .. utils.shorten_path(dir)
                else
                    title = process
                end
            elseif process == 'ssh' then
                local host = utils.ssh_host(pane)
                title = host and ('ssh ' .. host) or 'ssh'
            else
                local cwd = pane.current_working_dir
                if cwd then dir = cwd.file_path or tostring(cwd) end
                -- Show "process dirname" so tabs like claude/nvim indicate which repo
                if dir then
                    local dirname = dir:match('([^/]+)/?$') or dir
                    title = process .. ' ' .. dirname
                else
                    title = pane.title
                    if title == '' or title == process then
                        title = process
                    end
                end
            end
        end

        -- Git dirty indicator
        local dirty = utils.git_dirty(dir)

        -- Truncate to fit, measured in display columns (#/sub count bytes and
        -- mis-budget the multibyte ● and icon). Reserve prefix + trailing dot.
        local prefix = ' ' .. idx .. ': ' .. icon .. ' '
        local trailing = dirty and ' ● ' or ' '
        local budget = max_width - wezterm.column_width(prefix) - wezterm.column_width(trailing)
        if wezterm.column_width(title) > budget then
            title = wezterm.truncate_right(title, math.max(budget - 1, 1)) .. '…'
        end

        local override_idx = utils.tab_color_override(tab.tab_id)
        local override = override_idx and M.tab_palette[override_idx]
        local obg, ofg
        if override then
            if tab.is_active then
                obg, ofg = override.bg, override.fg
            else
                obg = utils.dim_color(override.bg, 0.5)
                ofg = utils.dim_color(override.fg, 0.8)
            end
        end

        local parts = {
            { Text = ' ' .. idx .. ': ' .. icon .. ' ' .. title .. ' ' },
        }
        if dirty then
            table.insert(parts, { Foreground = { Color = override and ofg or c.yellow } })
            table.insert(parts, { Text = '● ' })
        end

        if override then
            table.insert(parts, 1, { Background = { Color = obg } })
            table.insert(parts, 2, { Foreground = { Color = ofg } })
        end

        return wezterm.format(parts)
    end)
end

return M
