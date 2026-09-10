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
