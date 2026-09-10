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

function Engine:pending()
    local saved = self.store:read()
    if type(saved) ~= 'table' or type(saved.windows) ~= 'table' or #saved.windows == 0 then
        return nil
    end
    return saved
end

function Engine:restore_windows(windows)
    local ok, err = pcall(self.restore.build, self.mux, windows, self.ctx)
    if not ok then self.log('session: restore failed: ' .. tostring(err)) end
    self:arm()
    return ok
end

function Engine:start_clean()
    self.store:rotate()
    self:arm()
end

return M
