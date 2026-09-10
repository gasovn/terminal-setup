-- Session restore: mirrors the mux to disk and offers to rebuild it at startup.
--
-- This is the only module under session/ that touches wezterm directly; the
-- rest take their dependencies as arguments so they can be unit-tested.

local wezterm = require 'wezterm'
local act = wezterm.action
local engine_mod = require 'session.engine'
local restore = require 'session.restore'
local snapshot = require 'session.snapshot'
local store_mod = require 'session.store'

local M = {}

local function log(msg)
    wezterm.log_info(msg)
end

local function shell_quote(path)
    return "'" .. path:gsub("'", "'\\''") .. "'"
end

local function dir_exists(path)
    local ok = os.execute('test -d ' .. shell_quote(path))
    return ok == true or ok == 0
end

local function state_dir()
    local base = os.getenv('XDG_STATE_HOME')
    if base == nil or base == '' then
        base = wezterm.home_dir .. '/.local/state'
    end
    return base .. '/wezterm-session'
end

local function make_ctx()
    wezterm.GLOBAL.session = wezterm.GLOBAL.session or { last_active = {} }

    return {
        last_active = wezterm.GLOBAL.session.last_active,
        -- Colours are filled lazily by utils.tab_color_override when the colour
        -- picker's marker file is consumed, so read them through a proxy rather
        -- than snapshotting the table once at startup.
        colors = setmetatable({}, {
            __index = function(_, key)
                return (wezterm.GLOBAL.tab_colors or {})[key]
            end,
        }),
        now = os.time(),
        log = log,
        resolve_cwd = function(cwd)
            return restore.resolve_cwd(cwd, dir_exists, wezterm.home_dir)
        end,
        set_color = function(tab_id, color)
            wezterm.GLOBAL.tab_colors = wezterm.GLOBAL.tab_colors or {}
            wezterm.GLOBAL.tab_colors[tostring(tab_id)] = color
        end,
    }
end

local function describe(window, index)
    local names = {}
    for _, tab in ipairs(window.tabs) do
        if tab.title then table.insert(names, tab.title) end
        if #names == 3 then break end
    end

    local when = 'время неизвестно'
    if window.last_active then
        when = os.date('%d.%m %H:%M', window.last_active)
    end

    return string.format('Окно %d · %s · вкладок: %d · %s · %s',
        index, window.workspace, #window.tabs,
        #names > 0 and table.concat(names, ', ') or 'без имён', when)
end

local function selector(eng, model, on_dismiss)
    local choices = { { label = 'Восстановить всё', id = 'all' } }
    for index, window in ipairs(model.windows) do
        table.insert(choices, { label = describe(window, index), id = tostring(index) })
    end
    table.insert(choices, { label = 'Начать чисто', id = 'clean' })

    return act.InputSelector {
        title = 'Восстановление сессии',
        choices = choices,
        action = wezterm.action_callback(function(window, pane, id, _label)
            if id == nil then
                -- Escape: ask again on the next tick instead of guessing.
                on_dismiss()
                return
            end
            if id == 'clean' then
                eng:start_clean()
                return
            end

            if id == 'all' then
                eng:restore_windows(model.windows)
            else
                local chosen = model.windows[tonumber(id)]
                if chosen then
                    eng:restore_windows({ chosen })
                else
                    eng:arm()
                end
            end

            -- The bootstrap window has served its purpose: closing its only tab
            -- closes the window and leaves just the restored set on screen.
            window:perform_action(act.CloseCurrentTab { confirm = false }, pane)
        end),
    }
end

function M.setup()
    local store = store_mod.new {
        dir = state_dir(),
        encode = wezterm.json_encode,
        decode = wezterm.json_parse,
        log = log,
    }

    local eng = engine_mod.new {
        mux = wezterm.mux,
        store = store,
        snapshot = snapshot,
        restore = restore,
        ctx = make_ctx(),
        now = os.time,
        log = log,
    }

    local pending, asking = nil, false

    wezterm.on('gui-startup', function(cmd)
        local ok, saved = pcall(function() return eng:pending() end)
        if not ok then
            log('session: cannot read snapshot: ' .. tostring(saved))
            saved = nil
        end

        wezterm.mux.spawn_window(cmd or {})

        if saved then
            pending = saved
        else
            eng:arm()
        end
    end)

    -- statusbar.lua registers its own update-status handler; both run, verified
    -- on a real wezterm, so nothing there has to be touched.
    wezterm.on('update-status', function(window, pane)
        if pending then
            if eng.armed then
                pending = nil
            elseif not asking then
                asking = true
                window:perform_action(
                    selector(eng, pending, function() asking = false end), pane)
            end
            return
        end
        eng:tick()
    end)
end

return M
