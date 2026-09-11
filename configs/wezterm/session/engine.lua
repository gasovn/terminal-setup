-- Decides when the mirror on disk may be written, and drives restore.
--
-- No wezterm API here: init.lua supplies the mux, the store and the clock,
-- which keeps this logic unit-testable.

local M = {}

local Engine = {}
Engine.__index = Engine

function M.new(deps)
    return setmetatable({
        mux = deps.mux,
        store = deps.store,
        snapshot = deps.snapshot,
        restore = deps.restore,
        ctx = deps.ctx,
        now = deps.now or os.time,
        log = deps.log or function() end,
        armed = false,
        last_fingerprint = nil,
    }, Engine)
end

-- Nothing is written until the user has answered the restore question:
-- otherwise a freshly opened empty window overwrites a set collected all day.
function Engine:arm()
    self.armed = true
end

function Engine:tick()
    if not self.armed then return false end

    self.ctx.now = self.now()
    local ok, model = pcall(self.snapshot.capture, self.mux, self.ctx)
    if not ok then
        self.log('session: capture failed: ' .. tostring(model))
        return false
    end

    local fingerprint = self.snapshot.fingerprint(model)
    if fingerprint == self.last_fingerprint then return false end

    if not self.store:write(model) then return false end
    self.last_fingerprint = fingerprint
    return true
end

-- A snapshot of an unknown version, or one whose windows carry no tabs, is
-- treated as no snapshot at all: it would only fail inside restore.build and
-- leave the user without the bootstrap window.
function Engine:pending()
    local saved = self.store:read()
    if type(saved) ~= 'table' or saved.version ~= 1 or type(saved.windows) ~= 'table' then
        return nil
    end

    local windows = {}
    for _, w in ipairs(saved.windows) do
        if type(w) == 'table' and type(w.tabs) == 'table' and #w.tabs > 0 then
            table.insert(windows, w)
        end
    end
    if #windows == 0 then return nil end

    saved.windows = windows
    return saved
end

-- Rebuilding replaces whatever the mux holds, and the next tick mirrors that
-- to disk. The snapshot is moved aside first, so restoring one window out of
-- three cannot destroy the other two: they stay in previous.json.
function Engine:restore_windows(windows)
    self.store:rotate()

    local ok, created = pcall(self.restore.build, self.mux, windows, self.ctx)
    if not ok then self.log('session: restore failed: ' .. tostring(created)) end
    self:arm()

    return ok and type(created) == 'table' and #created > 0
end

-- A mux window spawned at runtime gets its GUI window a turn of the event loop
-- later, measured at about 30 ms. Close the bootstrap before that and wezterm
-- is left with nothing on screen, so it quits.
function M.bootstrap_close_decision(gui_window_count, attempts_left)
    if gui_window_count ~= nil and gui_window_count > 1 then return 'close' end
    if attempts_left > 0 then return 'wait' end
    return 'keep'
end

function Engine:start_clean()
    self.store:rotate()
    self:arm()
end

return M
