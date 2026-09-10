-- Phase B: rebuild the session from the snapshot phase A left behind, then
-- capture again. The dialog is bypassed on purpose -- it needs a human, and
-- what is being verified here is the rebuild, not the menu.

local wezterm = require 'wezterm'

local repo = assert(os.getenv('SESSION_REPO'), 'SESSION_REPO is not set')
local out = assert(os.getenv('SESSION_OUT'), 'SESSION_OUT is not set')
local state = assert(os.getenv('SESSION_STATE'), 'SESSION_STATE is not set')

package.path = repo .. '/configs/wezterm/?.lua;' .. package.path

local restore = require 'session.restore'
local snapshot = require 'session.snapshot'
local store_mod = require 'session.store'

local function write(name, text)
    local f = assert(io.open(out .. '/' .. name, 'w'))
    f:write(text)
    f:close()
end

wezterm.on('gui-startup', function()
    local store = store_mod.new {
        dir = state,
        encode = wezterm.json_encode,
        decode = wezterm.json_parse,
        log = function() end,
    }

    local saved = store:read()
    if not saved then
        write('b.txt', 'NO SNAPSHOT')
        wezterm.mux.spawn_window {}
        return
    end

    restore.build(wezterm.mux, saved.windows, {
        resolve_cwd = function(cwd) return cwd or wezterm.home_dir end,
        set_color = function() end,
        log = function() end,
    })

    wezterm.time.call_after(2, function()
        local model = snapshot.capture(wezterm.mux, {
            colors = {}, last_active = {}, now = 1000, log = function() end,
        })
        write('b.txt', snapshot.fingerprint(model))
    end)
end)

return { default_prog = { 'bash', '-c', 'sleep 6' } }
