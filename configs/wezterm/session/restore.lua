-- Builds windows, tabs and panes from a session model.
--
-- The mux is passed in rather than required, so the module is unit-testable
-- with a fake that records every call.
--
-- Measured on a real wezterm: pane:split { size = r } gives the NEW pane the
-- share r of the container, and the new pane lands on the side named by
-- direction. The model stores exactly that number.

local M = {}

local function first_cwd(node)
    if node.kind == 'leaf' then return node.cwd end
    return first_cwd(node.a)
end

local function replay(pane, node, ctx, state)
    if node.kind == 'leaf' then
        if node.zoomed then state.zoom_pane = pane end
        return
    end
    local created = pane:split {
        direction = node.dir,
        size = node.ratio,
        cwd = ctx.resolve_cwd(first_cwd(node.b)),
    }
    replay(pane, node.a, ctx, state)
    replay(created, node.b, ctx, state)
end

local function apply_tab(tab, pane, model, ctx)
    local state = {}
    replay(pane, model.layout, ctx, state)

    if model.title then tab:set_title(model.title) end
    if model.color then ctx.set_color(tab:tab_id(), model.color) end
    if state.zoom_pane then
        state.zoom_pane:activate()
        tab:set_zoomed(true)
    end
end

function M.build(mux, windows, ctx)
    local created = {}
    for _, w in ipairs(windows) do
        local first = w.tabs[1]
        local tab, pane, win = mux.spawn_window {
            workspace = w.workspace,
            cwd = ctx.resolve_cwd(first_cwd(first.layout)),
        }
        apply_tab(tab, pane, first, ctx)
        local active = first.is_active and tab or nil

        for i = 2, #w.tabs do
            local model = w.tabs[i]
            local t, p = win:spawn_tab { cwd = ctx.resolve_cwd(first_cwd(model.layout)) }
            apply_tab(t, p, model, ctx)
            if model.is_active then active = t end
        end

        if active then active:activate() end
        table.insert(created, win)
    end
    return created
end

return M
