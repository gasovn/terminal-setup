local wezterm = require 'wezterm'
local M = {}

-- Process name → Nerd Font icon
M.process_icons = {
    ['fish'] = '󰈺',
    ['bash'] = '',
    ['zsh'] = '',
    ['nvim'] = '',
    ['vim'] = '',
    ['ssh'] = '󰣀',
    ['docker'] = '',
    ['node'] = '󰎙',
    ['python'] = '',
    ['python3'] = '',
    ['go'] = '',
    ['cargo'] = '',
    ['git'] = '',
    ['htop'] = '',
    ['btop'] = '',
    ['top'] = '',
    ['yazi'] = '󰉋',
    ['lazygit'] = '',
    ['make'] = '',
    ['npm'] = '',
    ['pnpm'] = '',
    ['claude'] = '󰚩',
    ['sudo'] = '',
}

function M.get_process_icon(name)
    return M.process_icons[name] or ''
end

-- Extract process name from full path, resolving known version-based binaries
function M.basename(path)
    if not path then return '' end
    -- Claude Code: ~/.local/share/claude/versions/X.Y.Z → "claude"
    if path:find('/claude/versions/') then return 'claude' end
    return path:match('([^/]+)$') or path
end

-- Shorten path: /home/wolf/projects/foo/bar → ~/p/foo/bar
function M.shorten_path(path)
    if not path then return '' end
    local home = os.getenv('HOME') or ''
    path = path:gsub('^' .. home:gsub('([%.%-%+])', '%%%1'), '~')
    local parts = {}
    for part in path:gmatch('[^/]+') do
        table.insert(parts, part)
    end
    if #parts <= 3 then return path end
    -- Keep first (~ or root indicator) and last 2
    if parts[1] == '~' then
        return '~/' .. '…/' .. parts[#parts - 1] .. '/' .. parts[#parts]
    end
    return '…/' .. parts[#parts - 1] .. '/' .. parts[#parts]
end

-- Check if directory has uncommitted git changes (cached, 5s TTL)
-- Uses io.popen because wezterm.run_child_process can't be called
-- from synchronous callbacks like format-tab-title.
function M.git_dirty(dir)
    if not dir then return false end
    if not wezterm.GLOBAL.git_cache then wezterm.GLOBAL.git_cache = {} end
    local cache = wezterm.GLOBAL.git_cache[dir]
    local now = os.time()
    if cache and (now - cache.time) < 5 then return cache.dirty end

    local cmd = string.format(
        'git -C "%s" status --porcelain -unormal --ignore-submodules 2>/dev/null',
        dir
    )
    local handle = io.popen(cmd)
    local stdout = handle:read('*a')
    handle:close()
    local dirty = stdout ~= nil and stdout ~= ''
    wezterm.GLOBAL.git_cache[dir] = { dirty = dirty, time = now }
    return dirty
end

-- Extract SSH hostname from pane info
function M.ssh_host(pane)
    -- 1. Try pane.title — remote shell usually sets "user@host: path"
    local title = pane.title or ''
    local host = title:match('^%S+@([^:%s]+)')
    if host then return host end

    -- 2. Try argv via mux API — gets "ssh hostname" from command args
    local ok, mux_pane = pcall(function()
        return wezterm.mux.get_pane(pane.pane_id)
    end)
    if ok and mux_pane then
        local info = mux_pane:get_foreground_process_info()
        if info and info.argv then
            -- Find the hostname arg: skip flags (-o, -p, etc.) and their values
            local argv = info.argv
            local skip_next = false
            for i = 2, #argv do
                if skip_next then
                    skip_next = false
                elseif argv[i]:match('^%-[bcDEeFIiJLlmOopQRSWw]$') then
                    skip_next = true -- next arg is value for this flag
                elseif not argv[i]:match('^%-') then
                    -- First non-flag argument is [user@]hostname
                    local h = argv[i]:match('@(.+)') or argv[i]
                    return h
                end
            end
        end
    end

    return nil
end

-- Get battery info (returns nil if no battery)
function M.get_battery()
    local info = wezterm.battery_info()
    if #info == 0 then return nil end
    local b = info[1]
    local pct = math.floor(b.state_of_charge * 100 + 0.5)
    local icon
    if pct >= 80 then icon = '󰁹'
    elseif pct >= 60 then icon = '󰂀'
    elseif pct >= 40 then icon = '󰁾'
    elseif pct >= 20 then icon = '󰁼'
    else icon = '󰁺' end
    return icon .. ' ' .. pct .. '%'
end

return M
