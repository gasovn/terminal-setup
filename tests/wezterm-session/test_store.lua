local h = require 'harness'
local store_mod = require 'session.store'

-- The store's job is file mechanics, not encoding, so tests inject a trivial
-- codec instead of json.
local function codec()
    return {
        encode = function(model) return 'ENC:' .. model.marker end,
        decode = function(raw)
            local marker = raw:match('^ENC:(.*)$')
            if not marker then error('not our format') end
            return { marker = marker }
        end,
    }
end

local function tmpdir()
    local p = os.tmpname()
    os.remove(p)
    os.execute("mkdir -p '" .. p .. "'")
    return p
end

local function new_store(dir, logs)
    local c = codec()
    return store_mod.new {
        dir = dir,
        encode = c.encode,
        decode = c.decode,
        log = function(msg) table.insert(logs, msg) end,
        now = function() return 4242 end,
    }
end

h.it('writes a snapshot and reads it back', function()
    local dir, logs = tmpdir(), {}
    local store = new_store(dir, logs)

    h.eq(store:write({ marker = 'hello' }), true)
    h.eq(store:read(), { marker = 'hello' })
end)

h.it('returns nil when nothing was ever written', function()
    h.eq(new_store(tmpdir(), {}):read(), nil)
end)

h.it('leaves no temporary file behind', function()
    local dir = tmpdir()
    new_store(dir, {}):write({ marker = 'hello' })
    h.eq(io.open(dir .. '/current.json.tmp', 'r'), nil)
end)
