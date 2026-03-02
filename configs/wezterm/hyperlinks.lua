local wezterm = require 'wezterm'
local M = {}

function M.apply(config)
    config.hyperlink_rules = wezterm.default_hyperlink_rules()

    -- File paths with line numbers: src/main.go:42 → open in editor
    -- Matches patterns like: path/file.ext:line or path/file.ext:line:col
    table.insert(config.hyperlink_rules, {
        regex = [[[a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+:\d+(?::\d+)?]],
        format = 'file://$0',
    })

    -- Custom pattern template (uncomment and adjust URL):
    -- JIRA / Yandex Tracker ticket IDs, e.g. TECH-1234
    -- table.insert(config.hyperlink_rules, {
    --     regex = [[\b([A-Z]{2,10}-\d+)\b]],
    --     format = 'https://tracker.example.com/$1',
    -- })
end

return M
