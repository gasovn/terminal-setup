local h = require 'harness'
local layout = require 'session.layout'

-- Geometry measured on a real wezterm: a container of 80 columns split with
-- size = 0.25 leaves 59 columns for the original pane, one divider column,
-- and 20 for the new one.
local left  = { left = 0,  top = 0, width = 59, height = 24 }
local right = { left = 60, top = 0, width = 20, height = 24 }

h.it('builds a split from two panes side by side', function()
    h.eq(layout.build({ left, right }), {
        kind = 'split',
        dir = 'Right',
        ratio = 0.25,
        a = { kind = 'leaf', rect = left },
        b = { kind = 'leaf', rect = right },
    })
end)
