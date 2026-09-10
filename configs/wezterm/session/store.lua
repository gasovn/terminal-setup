-- Snapshot file on disk: atomic write, rotation on "start clean", quarantine
-- for a file we cannot parse.
--
-- Codec and clock are injected so the module is unit-testable without wezterm.

local M = {}

local Store = {}
Store.__index = Store

local function shell_quote(path)
    return "'" .. path:gsub("'", "'\\''") .. "'"
end

function M.new(opts)
    return setmetatable({
        dir = opts.dir,
        path = opts.dir .. '/current.json',
        previous = opts.dir .. '/previous.json',
        encode = opts.encode,
        decode = opts.decode,
        log = opts.log or function() end,
        now = opts.now or os.time,
    }, Store)
end

function Store:ensure_dir()
    os.execute('mkdir -p ' .. shell_quote(self.dir))
end

function Store:write(model)
    self:ensure_dir()
    local tmp = self.path .. '.tmp'
    local f, err = io.open(tmp, 'w')
    if not f then
        self.log('session: cannot write ' .. tmp .. ': ' .. tostring(err))
        return false
    end

    local ok, encoded = pcall(self.encode, model)
    if not ok then
        f:close()
        os.remove(tmp)
        self.log('session: cannot encode snapshot: ' .. tostring(encoded))
        return false
    end
    f:write(encoded)
    f:close()

    local renamed, rerr = os.rename(tmp, self.path)
    if not renamed then
        os.remove(tmp)
        self.log('session: cannot replace ' .. self.path .. ': ' .. tostring(rerr))
        return false
    end
    return true
end

function Store:read()
    local f = io.open(self.path, 'r')
    if not f then return nil end
    local raw = f:read('*a')
    f:close()

    local ok, model = pcall(self.decode, raw)
    if not ok or type(model) ~= 'table' then
        self:quarantine()
        return nil
    end
    return model
end

-- Called when the user chooses "start clean". Renaming instead of deleting
-- keeps the only irreversible action in the plugin reversible by hand.
function Store:rotate()
    local f = io.open(self.path, 'r')
    if not f then return true end
    f:close()

    local ok, err = os.rename(self.path, self.previous)
    if not ok then
        self.log('session: cannot rotate snapshot: ' .. tostring(err))
        return false
    end
    return true
end

-- Real implementation lands in Task 10; Store:read already calls it, so a stub
-- keeps this task honest about what is not built yet.
function Store:quarantine()
    self.log('session: quarantine not implemented yet')
end

return M
