-- Reads the whole mux into a plain model table.
--
-- The mux is passed in rather than required, so the module is unit-testable
-- with a fake. Tabs and windows carry no identifiers: colours and titles are
-- applied to whatever tab id the restore happens to create, so position in the
-- snapshot is identity enough.

local layout = require 'session.layout'

local M = {}

local function pane_cwd(pane)
    local ok, url = pcall(function() return pane:get_current_working_dir() end)
    if not ok or url == nil then return nil end
    if type(url) == 'string' then return url end
    return url.file_path
end

local function to_model(node)
    if node.kind == 'leaf' then
        return {
            kind = 'leaf',
            cwd = pane_cwd(node.rect.pane),
            zoomed = node.rect.is_zoomed or false,
        }
    end
    return {
        kind = 'split',
        dir = node.dir,
        ratio = node.ratio,
        a = to_model(node.a),
        b = to_model(node.b),
    }
end

local function tab_model(info, ctx)
    local tab = info.tab

    local rects = tab:panes_with_info()
    local tree = layout.build(rects)
    if not tree then
        ctx.log('session: layout not representable as splits, keeping first pane only')
        tree = { kind = 'leaf', rect = rects[1] }
    end

    local title = tab:get_title()
    if title == '' then title = nil end

    return {
        title = title,
        color = ctx.colors[tostring(tab:tab_id())],
        is_active = info.is_active,
        layout = to_model(tree),
    }
end

local function is_focused(win)
    local ok, gui = pcall(function() return win:gui_window() end)
    if not ok or gui == nil then return false end
    local ok2, focused = pcall(function() return gui:is_focused() end)
    return ok2 and focused or false
end

function M.capture(mux, ctx)
    local windows = {}
    for _, win in ipairs(mux.all_windows()) do
        local id = win:window_id()
        if is_focused(win) then ctx.last_active[id] = ctx.now end

        local tabs = {}
        for _, info in ipairs(win:tabs_with_info()) do
            table.insert(tabs, tab_model(info, ctx))
        end

        table.insert(windows, {
            workspace = win:get_workspace(),
            last_active = ctx.last_active[id],
            tabs = tabs,
        })
    end
    return { version = 1, saved_at = ctx.now, windows = windows }
end

return M
