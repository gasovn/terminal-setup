local h = require 'harness'
local fakes = require 'fakes'
local restore = require 'session.restore'

local function ctx(colors)
    return {
        resolve_cwd = function(cwd) return cwd end,
        set_color = function(tab_id, color) colors[tostring(tab_id)] = color end,
        log = function() end,
    }
end

local function leaf(cwd, zoomed)
    return { kind = 'leaf', cwd = cwd, zoomed = zoomed or false }
end

h.it('spawns one window with one tab and activates it', function()
    local rec = fakes.recorder()

    restore.build(fakes.mux(rec, {}), { {
        workspace = 'main',
        tabs = { { is_active = true, layout = leaf('/home/wolf/code') } },
    } }, ctx({}))

    h.eq(#rec.calls, 2)
    h.eq(rec.calls[1].op, 'spawn_window')
    h.eq(rec.calls[1].workspace, 'main')
    h.eq(rec.calls[1].cwd, '/home/wolf/code')
    h.eq(rec.calls[2].op, 'activate_tab')
    h.eq(rec.calls[2].tab, rec.calls[1].tab)
end)
