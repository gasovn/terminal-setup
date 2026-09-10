-- Pane layout as a tree of splits.
--
-- Pure Lua: no wezterm API, so it is unit-testable under luajit.
--
-- Rectangles use the shape of panes_with_info(): left/top are 0-based cell
-- coordinates, width/height are cell counts. Neighbouring panes are separated
-- by exactly one divider cell, so a pane at left=0 width=59 is followed by one
-- at left=60.
--
-- ratio is the share of the second part (b) of the container -- exactly the
-- number pane:split { size = ... } expects.
--
-- M.build returns the root node of the tree, or nil when there is nothing to
-- build: no rectangles at all, or an arrangement it cannot cut into splits.

local M = {}

local function bounds(rects)
    local l, t, r, b = math.huge, math.huge, -math.huge, -math.huge
    for _, q in ipairs(rects) do
        l = math.min(l, q.left)
        t = math.min(t, q.top)
        r = math.max(r, q.left + q.width)
        b = math.max(b, q.top + q.height)
    end
    return l, t, r, b
end

local function cut_at_x(rects, x)
    local a, b = {}, {}
    for _, q in ipairs(rects) do
        if q.left + q.width <= x then
            table.insert(a, q)
        elseif q.left >= x + 1 then
            table.insert(b, q)
        end
    end
    if #a > 0 and #b > 0 and #a + #b == #rects then return a, b end
    return nil
end

local function cut_at_y(rects, y)
    local a, b = {}, {}
    for _, q in ipairs(rects) do
        if q.top + q.height <= y then
            table.insert(a, q)
        elseif q.top >= y + 1 then
            table.insert(b, q)
        end
    end
    if #a > 0 and #b > 0 and #a + #b == #rects then return a, b end
    return nil
end

function M.build(rects)
    if #rects == 0 then return nil end
    if #rects == 1 then return { kind = 'leaf', rect = rects[1] } end

    local l, t, r, bt = bounds(rects)
    for _, q in ipairs(rects) do
        local x = q.left + q.width
        if x < r then
            local a, b = cut_at_x(rects, x)
            if a then
                local ta, tb = M.build(a), M.build(b)
                if ta and tb then
                    return {
                        kind = 'split',
                        dir = 'Right',
                        ratio = (r - (x + 1)) / (r - l),
                        a = ta,
                        b = tb,
                    }
                end
            end
        end
    end

    for _, q in ipairs(rects) do
        local y = q.top + q.height
        if y < bt then
            local a, b = cut_at_y(rects, y)
            if a then
                local ta, tb = M.build(a), M.build(b)
                if ta and tb then
                    return {
                        kind = 'split',
                        dir = 'Bottom',
                        ratio = (bt - (y + 1)) / (bt - t),
                        a = ta,
                        b = tb,
                    }
                end
            end
        end
    end

    return nil
end

return M
