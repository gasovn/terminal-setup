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

h.it('restores the manual title, the colour and the zoomed pane', function()
    local rec = fakes.recorder()
    local colors = {}

    restore.build(fakes.mux(rec, {}), { {
        workspace = 'main',
        tabs = { {
            title = 'PipeHealth', color = '#a9b665', is_active = true,
            layout = {
                kind = 'split', dir = 'Right', ratio = 0.25,
                a = leaf('/left'), b = leaf('/right', true),
            },
        } },
    } }, ctx(colors))

    local ops = {}
    for _, call in ipairs(rec.calls) do table.insert(ops, call.op) end
    h.eq(ops, {
        'spawn_window', 'split', 'set_title', 'activate_pane', 'set_zoomed', 'activate_tab',
    })

    local titled
    for _, call in ipairs(rec.calls) do
        if call.op == 'set_title' then titled = call end
    end
    h.eq(titled.title, 'PipeHealth')
    h.eq(colors[tostring(titled.tab)], '#a9b665')
end)

h.it('restores several windows, their workspaces and the active tab of each', function()
    local rec = fakes.recorder()

    restore.build(fakes.mux(rec, {}), {
        {
            workspace = 'main',
            tabs = {
                { is_active = false, layout = leaf('/a') },
                { is_active = true,  layout = leaf('/b') },
            },
        },
        {
            workspace = 'homelab',
            tabs = { { is_active = true, layout = leaf('/c') } },
        },
    }, ctx({}))

    local spawned_windows, spawned_tabs, activated = {}, {}, {}
    for _, call in ipairs(rec.calls) do
        if call.op == 'spawn_window' then table.insert(spawned_windows, call.workspace) end
        if call.op == 'spawn_tab' then table.insert(spawned_tabs, call.cwd) end
        if call.op == 'activate_tab' then table.insert(activated, call.tab) end
    end

    h.eq(spawned_windows, { 'main', 'homelab' })
    h.eq(spawned_tabs, { '/b' })
    h.eq(#activated, 2)
end)
