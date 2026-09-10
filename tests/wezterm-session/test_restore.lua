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

h.it('replays a nested split tree in depth-first order', function()
    local rec = fakes.recorder()

    restore.build(fakes.mux(rec, {}), { {
        workspace = 'main',
        tabs = { {
            is_active = true,
            layout = {
                kind = 'split', dir = 'Right', ratio = 0.25,
                a = {
                    kind = 'split', dir = 'Bottom', ratio = 0.25,
                    a = leaf('/upper'), b = leaf('/lower'),
                },
                b = leaf('/right'),
            },
        } },
    } }, ctx({}))

    local splits = {}
    for _, call in ipairs(rec.calls) do
        if call.op == 'split' then table.insert(splits, call) end
    end

    h.eq(#splits, 2)
    -- The outer split comes first and carries the cwd of its own subtree.
    h.eq(splits[1].dir, 'Right')
    h.eq(splits[1].size, 0.25)
    h.eq(splits[1].cwd, '/right')
    -- The inner split happens on the original pane, not on the new one.
    h.eq(splits[2].dir, 'Bottom')
    h.eq(splits[2].size, 0.25)
    h.eq(splits[2].cwd, '/lower')
    h.eq(splits[2].on, splits[1].on)
    h.eq(splits[1].new ~= splits[2].new, true)
end)
