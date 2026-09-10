local h = require 'harness'
local fakes = require 'fakes'
local snapshot = require 'session.snapshot'

-- What the module needs from the outside world: the tab colour table and the
-- window activity map (both live in wezterm.GLOBAL in production), the clock,
-- and a logger.
local function ctx()
    return {
        colors = {},
        last_active = {},
        now = 1000,
        log = function() end,
    }
end

h.it('captures one window with one tab and one pane', function()
    local rec = fakes.recorder()
    local pane = fakes.pane(rec, 1, '/home/wolf/code/pipe-health')
    local tab = fakes.tab(rec, 7, '', {
        { left = 0, top = 0, width = 80, height = 24, pane = pane },
    })
    local win = fakes.win(rec, 3, 'main', { tab }, true)

    h.eq(snapshot.capture(fakes.mux(rec, { win }), ctx()), {
        version = 1,
        saved_at = 1000,
        windows = { {
            workspace = 'main',
            last_active = 1000,
            tabs = { {
                is_active = true,
                layout = {
                    kind = 'leaf',
                    cwd = '/home/wolf/code/pipe-health',
                    zoomed = false,
                },
            } },
        } },
    })
end)

h.it('captures manual title, colour, zoom and the active tab', function()
    local rec = fakes.recorder()
    local c = ctx()
    c.colors['7'] = '#a9b665'

    local left = fakes.pane(rec, 1, '/home/wolf/code/pipe-health')
    local right = fakes.pane(rec, 2, '/home/wolf/homelab')
    local named = fakes.tab(rec, 7, 'PipeHealth', {
        { left = 0,  top = 0, width = 59, height = 24, pane = left },
        { left = 60, top = 0, width = 20, height = 24, pane = right, is_zoomed = true },
    })
    local plain = fakes.tab(rec, 8, '', {
        { left = 0, top = 0, width = 80, height = 24, pane = fakes.pane(rec, 3, '/tmp') },
    })
    local win = fakes.win(rec, 3, 'main', { named, plain }, true)
    win.active_index = 2

    local model = snapshot.capture(fakes.mux(rec, { win }), c)

    h.eq(model.windows[1].tabs[1], {
        title = 'PipeHealth',
        color = '#a9b665',
        is_active = false,
        layout = {
            kind = 'split', dir = 'Right', ratio = 0.25,
            a = { kind = 'leaf', cwd = '/home/wolf/code/pipe-health', zoomed = false },
            b = { kind = 'leaf', cwd = '/home/wolf/homelab', zoomed = true },
        },
    })
    h.eq(model.windows[1].tabs[2].is_active, true)
    h.eq(model.windows[1].tabs[2].title, nil)
end)

h.it('captures every window, its workspace and its last activity', function()
    local rec = fakes.recorder()
    local main = fakes.win(rec, 3, 'main', {
        fakes.tab(rec, 7, '', { { left = 0, top = 0, width = 80, height = 24,
                                  pane = fakes.pane(rec, 1, '/a') } }),
    }, true)
    local other = fakes.win(rec, 4, 'homelab', {
        fakes.tab(rec, 9, '', { { left = 0, top = 0, width = 80, height = 24,
                                  pane = fakes.pane(rec, 2, '/b') } }),
    }, false)

    local model = snapshot.capture(fakes.mux(rec, { main, other }), ctx())

    h.eq(#model.windows, 2)
    h.eq(model.windows[1].workspace, 'main')
    h.eq(model.windows[2].workspace, 'homelab')
    h.eq(model.windows[1].last_active, 1000)
    h.eq(model.windows[2].last_active, nil)
end)
