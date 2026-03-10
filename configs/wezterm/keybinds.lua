local wezterm = require 'wezterm'
local act = wezterm.action
local ssh = require 'ssh'
local M = {}

function M.apply(config)
    -- Leader key is not used — all WezTerm bindings use Ctrl+Shift or Alt
    -- to avoid conflicts with Neovim (which uses Space leader and Ctrl+<key>)

    config.keys = {
        -- ═══ Tabs ═══
        { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
        { key = 'q', mods = 'CTRL|SHIFT', action = act.CloseCurrentTab { confirm = true } },
        -- Ctrl+Tab: MRU tab switch (toggle between last two used tabs)
        {
            key = 'Tab',
            mods = 'CTRL',
            action = wezterm.action_callback(function(window, pane)
                local win_id = tostring(window:window_id())
                local mru = wezterm.GLOBAL.mru and wezterm.GLOBAL.mru[win_id]
                if mru and mru.prev ~= mru.current then
                    window:perform_action(act.ActivateTab(mru.prev), pane)
                else
                    window:perform_action(act.ActivateTabRelative(1), pane)
                end
            end),
        },
        { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
        -- Ctrl+Shift+1..9 — switch to tab by number
        { key = '1', mods = 'CTRL|SHIFT', action = act.ActivateTab(0) },
        { key = '2', mods = 'CTRL|SHIFT', action = act.ActivateTab(1) },
        { key = '3', mods = 'CTRL|SHIFT', action = act.ActivateTab(2) },
        { key = '4', mods = 'CTRL|SHIFT', action = act.ActivateTab(3) },
        { key = '5', mods = 'CTRL|SHIFT', action = act.ActivateTab(4) },
        { key = '6', mods = 'CTRL|SHIFT', action = act.ActivateTab(5) },
        { key = '7', mods = 'CTRL|SHIFT', action = act.ActivateTab(6) },
        { key = '8', mods = 'CTRL|SHIFT', action = act.ActivateTab(7) },
        { key = '9', mods = 'CTRL|SHIFT', action = act.ActivateTab(8) },
        -- Move tab left/right
        { key = '<', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
        { key = '>', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },

        -- ═══ Splits (panes) ═══
        -- Vertical split (pane to the right)
        { key = '\\', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
        -- Horizontal split (pane below)
        { key = '-', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
        -- Focus between panes
        { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Left' },
        { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Right' },
        { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Up' },
        { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Down' },
        -- Resize panes
        { key = 'LeftArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Left', 3 } },
        { key = 'RightArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Right', 3 } },
        { key = 'UpArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Up', 3 } },
        { key = 'DownArrow', mods = 'ALT', action = act.AdjustPaneSize { 'Down', 3 } },
        -- Close pane (Ctrl+W — как в старом конфиге)
        { key = 'w', mods = 'CTRL', action = act.CloseCurrentPane { confirm = false } },
        -- Zoom pane (toggle fullscreen)
        { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },

        -- ═══ Workspaces ═══
        -- List workspaces with fuzzy search
        { key = 's', mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },
        -- New workspace
        {
            key = 'n',
            mods = 'CTRL|SHIFT',
            action = act.PromptInputLine {
                description = wezterm.format {
                    { Attribute = { Intensity = 'Bold' } },
                    { Foreground = { Color = '#cba6f7' } },
                    { Text = '  Enter workspace name: ' },
                },
                action = wezterm.action_callback(function(window, pane, line)
                    if line and line ~= '' then
                        window:perform_action(act.SwitchToWorkspace { name = line }, pane)
                    end
                end),
            },
        },

        -- ═══ SSH quick connect ═══
        { key = 'h', mods = 'CTRL|SHIFT', action = ssh.connect_action() },

        -- ═══ SFTP via Dolphin ═══
        { key = 'f', mods = 'CTRL|SHIFT', action = ssh.sftp_action() },

        -- ═══ Browse directories → open nvim in new tab ═══
        {
            key = 'e',
            mods = 'CTRL|SHIFT',
            action = wezterm.action_callback(function(window, pane)
                local cwd_url = pane:get_current_working_dir()
                if not cwd_url then return end
                local cwd = cwd_url.file_path

                local success, stdout, stderr = wezterm.run_child_process {
                    'find', cwd, '-maxdepth', '1', '-mindepth', '1',
                    '-type', 'd', '-not', '-name', '.*',
                }
                if not success or not stdout then return end

                local choices = {}
                for line in stdout:gmatch('[^\n]+') do
                    local name = line:match('([^/]+)$')
                    if name then
                        local label = name
                        local ok, branch_out = wezterm.run_child_process {
                            'git', '-C', line, 'rev-parse', '--abbrev-ref', 'HEAD',
                        }
                        if ok and branch_out then
                            local branch = branch_out:gsub('%s+$', '')
                            if branch ~= '' then
                                label = name .. ' (' .. branch .. ')'
                            end
                        end
                        table.insert(choices, { label = label, id = line })
                    end
                end
                if #choices == 0 then return end

                table.sort(choices, function(a, b) return a.label < b.label end)

                window:perform_action(
                    act.InputSelector {
                        title = '  Open directory in nvim',
                        choices = choices,
                        fuzzy = true,
                        action = wezterm.action_callback(function(w, p, id, label)
                            if not id then return end
                            local _tab, new_pane, _win = w:mux_window():spawn_tab {
                                cwd = id,
                            }
                            if new_pane then
                                new_pane:send_text('nvim .\n')
                            end
                        end),
                    },
                    pane
                )
            end),
        },

        -- ═══ Copy mode ═══
        { key = 'x', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },

        -- ═══ Quick select ═══
        { key = 'Space', mods = 'CTRL|SHIFT', action = act.QuickSelect },

        -- ═══ Command palette ═══
        { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },

        -- ═══ Fix Delete key (sends ctrl-h instead of \e[3~ with kitty keyboard) ═══
        { key = 'Delete', mods = 'NONE', action = act.SendString '\x1b[3~' },
        { key = 'Delete', mods = 'CTRL', action = act.SendString '\x1b[3;5~' },

        -- ═══ Clipboard ═══
        { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
        { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

        -- ═══ Clear scrollback ═══
        {
            key = 'k',
            mods = 'CTRL|SHIFT',
            action = act.Multiple {
                act.ClearScrollback 'ScrollbackAndViewport',
                act.SendKey { key = 'l', mods = 'CTRL' },
            },
        },
    }

    -- Quick select patterns (extras beyond defaults)
    config.quick_select_patterns = {
        -- UUID
        '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
        -- IPv4
        '\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',
        -- Git short hash (7+ hex)
        '\\b[0-9a-f]{7,40}\\b',
    }

    -- Mouse bindings
    config.selection_word_boundary = ' \t\n{}[]()"\':;,.<>~!@#$%^&*|+=`'
    config.mouse_bindings = {
        -- Disable auto-copy on all selection types (single drag, double-click word, triple-click line)
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = act.DisableDefaultAssignment,
        },
        {
            event = { Up = { streak = 2, button = 'Left' } },
            mods = 'NONE',
            action = act.DisableDefaultAssignment,
        },
        {
            event = { Up = { streak = 3, button = 'Left' } },
            mods = 'NONE',
            action = act.DisableDefaultAssignment,
        },
        -- Right-click copies selection to clipboard and clears it (visual feedback)
        {
            event = { Up = { streak = 1, button = 'Right' } },
            mods = 'NONE',
            action = act.Multiple {
                act.CopyTo 'Clipboard',
                act.ClearSelection,
            },
        },
        -- Ctrl+Click opens hyperlinks
        {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.OpenLinkAtMouseCursor,
        },
        -- Smooth scroll: 3 lines per wheel tick (default ~5 feels too fast)
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = 'NONE',
            action = act.ScrollByLine(-3),
        },
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = 'NONE',
            action = act.ScrollByLine(3),
        },
    }
end

return M
