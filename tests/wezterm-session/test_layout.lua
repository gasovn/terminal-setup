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

-- Measured: a 24-row container split with size = 0.25 leaves 17 rows above,
-- one divider row, 6 rows below.
local upper = { left = 0, top = 0,  width = 59, height = 17 }
local lower = { left = 0, top = 18, width = 59, height = 6 }

h.it('builds a split from two panes stacked one above the other', function()
    h.eq(layout.build({ upper, lower }), {
        kind = 'split',
        dir = 'Bottom',
        ratio = 0.25,
        a = { kind = 'leaf', rect = upper },
        b = { kind = 'leaf', rect = lower },
    })
end)
