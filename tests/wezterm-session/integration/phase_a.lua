-- Phase A: build a known layout on a real wezterm, capture it, write the
-- snapshot and its fingerprint. Panes run `sleep`, so the instance exits by
-- itself once they finish.

local wezterm = require 'wezterm'

local repo = assert(os.getenv('SESSION_REPO'), 'SESSION_REPO is not set')
local out = assert(os.getenv('SESSION_OUT'), 'SESSION_OUT is not set')
local state = assert(os.getenv('SESSION_STATE'), 'SESSION_STATE is not set')

package.path = repo .. '/configs/wezterm/?.lua;' .. package.path

local snapshot = require 'session.snapshot'
local store_mod = require 'session.store'

local function write(name, text)
    local f = assert(io.open(out .. '/' .. name, 'w'))
    f:write(text)
    f:close()
end

-- What the round trip compares is the layout. OS focus is a property of the
-- window manager, legitimately differs between two runs, and is noise here.
local function ignore_focus(model)
    for _, w in ipairs(model.windows) do
        w.is_focused = false
    end
    return model
end

wezterm.on('gui-startup', function()
    local tab, pane, win = wezterm.mux.spawn_window { cwd = '/tmp' }
    pane:split { direction = 'Right', size = 0.25, cwd = repo }
    tab:set_title('Named')
    win:spawn_tab { cwd = wezterm.home_dir }

    wezterm.time.call_after(2, function()
        local model = snapshot.capture(wezterm.mux, {
            colors = {}, last_active = {}, now = 1000, log = function() end,
        })
        local store = store_mod.new {
            dir = state,
            encode = wezterm.json_encode,
            decode = wezterm.json_parse,
            log = function() end,
        }
        store:write(model)
        write('a.txt', snapshot.fingerprint(ignore_focus(model)))
    end)
end)

return { default_prog = { 'bash', '-c', 'sleep 6' } }
