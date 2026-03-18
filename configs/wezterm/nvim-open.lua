local wezterm = require 'wezterm'
local act = wezterm.action
local M = {}

function M.setup()
    wezterm.on('open-uri', function(window, pane, uri)
        -- Only handle nvim:// URIs; let others fall through to default handler
        local file_line = uri:match('^nvim://(.*)')
        if not file_line then
            -- Return nil to allow default handling (http://, etc.)
            return
        end

        -- Parse file:line[:col] — try 3-group first, then 2-group
        local file, line, col
        file, line, col = file_line:match('^(.+):(%d+):(%d+)$')
        if not file then
            file, line = file_line:match('^(.+):(%d+)$')
        end
        if not file then
            return false
        end

        -- Resolve relative path against current pane's cwd
        if not file:match('^/') then
            local cwd_url = pane:get_current_working_dir()
            if cwd_url then
                local cwd_path = cwd_url.file_path or tostring(cwd_url)
                file = cwd_path .. '/' .. file
            end
        end

        -- Find nvim socket in adjacent panes of the same tab
        -- Uses `test -S` because io.open() cannot detect Unix socket files
        local tab = pane:tab()
        local current_id = pane:pane_id()
        local nvim_pane = nil
        local nvim_pane_idx = nil
        local socket = nil

        for idx, p in ipairs(tab:panes()) do
            if p:pane_id() ~= current_id then
                local candidate = '/tmp/nvim-wez-' .. p:pane_id() .. '.sock'
                local ok = os.execute('test -S "' .. candidate .. '"')
                if ok then
                    nvim_pane = p
                    nvim_pane_idx = idx - 1  -- WezTerm uses 0-based index
                    socket = candidate
                    break
                end
            end
        end

        if not socket then
            wezterm.log_warn('nvim-open: no nvim socket found in adjacent panes')
            return false
        end

        -- Escape spaces in file path for nvim :e command
        local escaped_file = file:gsub(' ', '\\ ')

        -- Build nvim command: exit to normal mode, open file, go to line
        local cmd = string.format('<C-\\><C-n>:e %s<CR>:%sG<CR>', escaped_file, line)
        if col then
            cmd = string.format('<C-\\><C-n>:e %s<CR>:%sG%s|<CR>', escaped_file, line, col)
        end

        wezterm.run_child_process {
            'nvim', '--server', socket, '--remote-send', cmd,
        }

        -- Focus the nvim pane
        window:perform_action(act.ActivatePaneByIndex(nvim_pane_idx), pane)

        -- Return false to prevent WezTerm from opening nvim:// in browser
        return false
    end)
end

return M
