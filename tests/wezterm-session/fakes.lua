-- Fake mux mirroring exactly the parts of the wezterm API the session modules
-- touch. Every mutating call is appended to rec.calls so tests can assert on
-- what the code asked the mux to do.
local M = {}

local Pane, Tab, Win = {}, {}, {}
Pane.__index, Tab.__index, Win.__index = Pane, Tab, Win

function M.recorder()
    return { calls = {}, next_id = 100 }
end

function M.pane(rec, id, cwd)
    return setmetatable({ rec = rec, id = id, cwd = cwd }, Pane)
end

function Pane:pane_id() return self.id end

function Pane:get_current_working_dir()
    if self.cwd == nil then return nil end
    return { file_path = self.cwd }
end

function Pane:activate()
    table.insert(self.rec.calls, { op = 'activate_pane', pane = self.id })
end

function Pane:split(opts)
    self.rec.next_id = self.rec.next_id + 1
    local p = M.pane(self.rec, self.rec.next_id, opts.cwd)
    table.insert(self.rec.calls, {
        op = 'split', on = self.id, dir = opts.direction,
        size = opts.size, cwd = opts.cwd, new = p.id,
    })
    return p
end

function M.tab(rec, id, title, panes)
    return setmetatable({ rec = rec, id = id, title = title or '', panes = panes or {} }, Tab)
end

function Tab:tab_id() return self.id end
function Tab:get_title() return self.title end

function Tab:set_title(t)
    self.title = t
    table.insert(self.rec.calls, { op = 'set_title', tab = self.id, title = t })
end

function Tab:panes_with_info()
    local out = {}
    for i, e in ipairs(self.panes) do
        out[i] = {
            index = i - 1, left = e.left, top = e.top,
            width = e.width, height = e.height,
            is_zoomed = e.is_zoomed or false, pane = e.pane,
        }
    end
    return out
end

function Tab:set_zoomed(v)
    table.insert(self.rec.calls, { op = 'set_zoomed', tab = self.id, value = v })
end

function Tab:activate()
    table.insert(self.rec.calls, { op = 'activate_tab', tab = self.id })
end

function M.win(rec, id, workspace, tabs, focused)
    return setmetatable({
        rec = rec, id = id, workspace = workspace,
        tabs = tabs or {}, focused = focused or false, active_index = 1,
    }, Win)
end

function Win:window_id() return self.id end
function Win:get_workspace() return self.workspace end

function Win:tabs_with_info()
    local out = {}
    for i, t in ipairs(self.tabs) do
        out[i] = { index = i - 1, is_active = (i == self.active_index), tab = t }
    end
    return out
end

function Win:gui_window()
    local focused = self.focused
    return { is_focused = function() return focused end }
end

local function fresh_tab(rec, cwd)
    rec.next_id = rec.next_id + 1
    local pane = M.pane(rec, rec.next_id, cwd)
    rec.next_id = rec.next_id + 1
    local tab = M.tab(rec, rec.next_id, '', {
        { left = 0, top = 0, width = 80, height = 24, pane = pane },
    })
    return tab, pane
end

function Win:spawn_tab(opts)
    local tab, pane = fresh_tab(self.rec, opts.cwd)
    table.insert(self.tabs, tab)
    table.insert(self.rec.calls, {
        op = 'spawn_tab', win = self.id, cwd = opts.cwd, tab = tab.id,
    })
    return tab, pane, self
end

function M.mux(rec, windows)
    return {
        all_windows = function() return windows end,
        spawn_window = function(opts)
            local tab, pane = fresh_tab(rec, opts.cwd)
            rec.next_id = rec.next_id + 1
            local win = M.win(rec, rec.next_id, opts.workspace, { tab })
            table.insert(windows, win)
            table.insert(rec.calls, {
                op = 'spawn_window', workspace = opts.workspace,
                cwd = opts.cwd, win = win.id, tab = tab.id,
            })
            return tab, pane, win
        end,
    }
end

return M
