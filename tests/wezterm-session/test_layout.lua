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

-- Measured on a real wezterm after: split Right 0.25, then split Bottom 0.25
-- on the original pane.
local three_a = { left = 0,  top = 0,  width = 59, height = 17 }
local three_b = { left = 0,  top = 18, width = 59, height = 6 }
local three_c = { left = 60, top = 0,  width = 20, height = 24 }

h.it('nests a horizontal split inside the left part of a vertical one', function()
    h.eq(layout.build({ three_a, three_b, three_c }), {
        kind = 'split',
        dir = 'Right',
        ratio = 0.25,
        a = {
            kind = 'split',
            dir = 'Bottom',
            ratio = 0.25,
            a = { kind = 'leaf', rect = three_a },
            b = { kind = 'leaf', rect = three_b },
        },
        b = { kind = 'leaf', rect = three_c },
    })
end)

-- Measured after a third split: Top 0.5 on the upper-left pane.
local four_a = { left = 0,  top = 0,  width = 59, height = 8 }
local four_b = { left = 0,  top = 9,  width = 59, height = 8 }
local four_c = { left = 0,  top = 18, width = 59, height = 6 }
local four_d = { left = 60, top = 0,  width = 20, height = 24 }

h.it('nests two horizontal splits inside a vertical one', function()
    h.eq(layout.build({ four_a, four_b, four_c, four_d }), {
        kind = 'split',
        dir = 'Right',
        ratio = 0.25,
        a = {
            kind = 'split',
            dir = 'Bottom',
            ratio = 15 / 24,
            a = { kind = 'leaf', rect = four_a },
            b = {
                kind = 'split',
                dir = 'Bottom',
                ratio = 6 / 15,
                a = { kind = 'leaf', rect = four_b },
                b = { kind = 'leaf', rect = four_c },
            },
        },
        b = { kind = 'leaf', rect = four_d },
    })
end)

h.it('returns a leaf for a single pane', function()
    local only = { left = 0, top = 0, width = 80, height = 24 }
    h.eq(layout.build({ only }), { kind = 'leaf', rect = only })
end)

-- A pinwheel cannot be produced by any sequence of splits: no straight cut
-- separates it into two groups. build() must say so instead of inventing a tree.
h.it('returns nil for a layout no sequence of splits can produce', function()
    local pinwheel = {
        { left = 0,  top = 0,  width = 20, height = 10 },
        { left = 21, top = 0,  width = 9,  height = 20 },
        { left = 11, top = 21, width = 19, height = 9 },
        { left = 0,  top = 11, width = 10, height = 19 },
        { left = 11, top = 11, width = 9,  height = 9 },
    }
    h.eq(layout.build(pinwheel), nil)
end)
