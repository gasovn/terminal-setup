-- Minimal test harness: no external dependencies, runs under luajit.
local M = {}

local total, failures = 0, 0

local function fmt(v, indent)
    indent = indent or ''
    -- Quoted, so that the string '0.25' does not look like the number 0.25.
    if type(v) == 'string' then return "'" .. v .. "'" end
    if type(v) ~= 'table' then return tostring(v) end
    local keys = {}
    for k in pairs(v) do table.insert(keys, k) end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    local parts = {}
    for _, k in ipairs(keys) do
        table.insert(parts, indent .. '  ' .. tostring(k) .. ' = ' .. fmt(v[k], indent .. '  '))
    end
    return '{\n' .. table.concat(parts, ',\n') .. '\n' .. indent .. '}'
end

local function deep_eq(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) == 'number' then return math.abs(a - b) < 1e-9 end
    if type(a) ~= 'table' then return a == b end
    for k, v in pairs(a) do
        if not deep_eq(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

function M.it(name, fn)
    total = total + 1
    local ok, err = pcall(fn)
    if ok then
        print('  ok   ' .. name)
    else
        failures = failures + 1
        print('  FAIL ' .. name)
        print('       ' .. tostring(err))
    end
end

function M.eq(actual, expected, msg)
    if not deep_eq(actual, expected) then
        error((msg or 'values differ')
            .. '\nexpected: ' .. fmt(expected)
            .. '\nactual:   ' .. fmt(actual), 2)
    end
end

function M.report()
    print(string.format('%d tests, %d failures', total, failures))
    -- An empty run means the test files stopped being reachable, not success.
    if total == 0 then
        print('no tests were collected')
        os.exit(1)
    end
    os.exit(failures == 0 and 0 or 1)
end

return M
