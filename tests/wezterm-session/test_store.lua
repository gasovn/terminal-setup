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

h.it('moves the previous snapshot aside instead of deleting it', function()
    local dir, logs = tmpdir(), {}
    local store = new_store(dir, logs)
    store:write({ marker = 'yesterday' })

    h.eq(store:rotate(), true)
    h.eq(store:read(), nil)

    local kept = io.open(dir .. '/previous.json', 'r')
    h.eq(kept ~= nil, true)
    h.eq(kept:read('*a'), 'ENC:yesterday')
    kept:close()
end)

h.it('rotating with no snapshot present is not an error', function()
    h.eq(new_store(tmpdir(), {}):rotate(), true)
end)

h.it('quarantines a snapshot it cannot parse and reports it', function()
    local dir, logs = tmpdir(), {}
    local store = new_store(dir, logs)

    local f = io.open(dir .. '/current.json', 'w')
    f:write('{ this is not our format')
    f:close()

    h.eq(store:read(), nil)

    local quarantined = io.open(dir .. '/broken-4242.json', 'r')
    h.eq(quarantined ~= nil, true)
    quarantined:close()

    h.eq(#logs, 1)
    h.eq(logs[1]:find('broken%-4242%.json') ~= nil, true)
end)
