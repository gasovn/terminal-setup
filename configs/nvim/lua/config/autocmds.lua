local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Restore cursor position on file open
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-save on focus lost
autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("AutoSave", { clear = true }),
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Filetype-specific indentation
autocmd("FileType", {
  group = augroup("FileTypeIndent", { clear = true }),
  pattern = { "go", "python", "rust", "cs" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Auto-resize splits on window resize
autocmd("VimResized", {
  group = augroup("AutoResize", { clear = true }),
  command = "tabdo wincmd =",
})

-- Open Neo-tree when nvim is started with a directory argument
autocmd("VimEnter", {
  group = augroup("OpenNeoTree", { clear = true }),
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      -- Delete the empty directory buffer
      vim.cmd("bdelete")
      -- cd into the directory so telescope/lsp work correctly
      vim.cmd("cd " .. vim.fn.fnameescape(arg))
      -- Open neo-tree
      vim.cmd("Neotree show")
    end
  end,
})

-- WezTerm integration: auto-start RPC socket for cross-pane navigation
local wez_pane = os.getenv("WEZTERM_PANE")
if wez_pane then
  local socket_path = "/tmp/nvim-wez-" .. wez_pane .. ".sock"

  autocmd("VimEnter", {
    group = augroup("WezTermSocket", { clear = true }),
    callback = function()
      -- Remove stale socket from previous crash
      os.remove(socket_path)
      vim.fn.serverstart(socket_path)
    end,
  })

  autocmd("VimLeave", {
    group = augroup("WezTermSocketCleanup", { clear = true }),
    callback = function()
      vim.fn.serverstop(socket_path)
      os.remove(socket_path)
    end,
  })

  -- Open file at line, called via --remote-expr from WezTerm's nvim-open module.
  -- Uses RPC instead of --remote-send to bypass terminal/insert mode issues.
  function _G.wezterm_open(file, line)
    -- Find a window with a regular buffer (skip terminal, neo-tree, etc.)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
      if bt == "" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
    vim.cmd("edit +" .. line .. " " .. vim.fn.fnameescape(file))
    return "ok"
  end
end
