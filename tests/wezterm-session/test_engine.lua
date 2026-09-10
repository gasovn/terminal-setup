local h = require 'harness'
local engine_mod = require 'session.engine'

local function fake_store()
    local store = { writes = 0, rotations = 0, saved = nil, model = nil }
    function store:write(model) self.writes = self.writes + 1; self.model = model; return true end
    function store:read() return self.saved end
    function store:rotate() self.rotations = self.rotations + 1; self.saved = nil; return true end
    return store
end

local function fake_snapshot(state)
    return {
        capture = function() return { version = 1, windows = state.windows } end,
        fingerprint = function(model) return #model.windows .. ':' .. state.marker end,
    }
end

local function new_engine(store, state)
    return engine_mod.new {
        mux = {},
        store = store,
        snapshot = fake_snapshot(state),
        restore = { build = function() state.built = true end },
        ctx = {},
        now = function() return 1000 end,
        log = function() end,
    }
end

h.it('writes nothing before the restore question is answered', function()
    local store, state = fake_store(), { windows = { {} }, marker = 'a' }
    local eng = new_engine(store, state)

    eng:tick()
    eng:tick()

    h.eq(store.writes, 0)
end)

h.it('writes once per change after being armed', function()
    local store, state = fake_store(), { windows = { {} }, marker = 'a' }
    local eng = new_engine(store, state)
    eng:arm()

    h.eq(eng:tick(), true)
    h.eq(eng:tick(), false)
    state.marker = 'b'
    h.eq(eng:tick(), true)
    h.eq(store.writes, 2)
end)

h.it('arms itself after restoring', function()
    local store, state = fake_store(), { windows = { {} }, marker = 'a' }
    local eng = new_engine(store, state)

    eng:restore_windows({ { workspace = 'main', tabs = {} } })

    h.eq(state.built, true)
    h.eq(eng:tick(), true)
end)

h.it('rotates the snapshot aside and arms itself on start clean', function()
    local store, state = fake_store(), { windows = { {} }, marker = 'a' }
    store.saved = { version = 1, windows = {} }
    local eng = new_engine(store, state)

    eng:start_clean()

    h.eq(store.rotations, 1)
    h.eq(eng:tick(), true)
end)

h.it('reports a failed capture instead of dying', function()
    local store, logged = fake_store(), {}
    local eng = engine_mod.new {
        mux = {},
        store = store,
        snapshot = {
            capture = function() error('mux exploded') end,
            fingerprint = function() return '' end,
        },
        restore = { build = function() end },
        ctx = {},
        now = function() return 1000 end,
        log = function(msg) table.insert(logged, msg) end,
    }
    eng:arm()

    h.eq(eng:tick(), false)
    h.eq(#logged, 1)
    h.eq(store.writes, 0)
end)
