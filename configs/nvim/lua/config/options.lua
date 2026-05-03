-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & indentation (2 spaces default, overridden per filetype)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Appearance
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Clipboard (Wayland via wl-clipboard)
vim.opt.clipboard = "unnamedplus"

-- Swap / Backup / Undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- Split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Sessions (auto-session): include localoptions so filetype/highlights restore.
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Misc
vim.opt.wrap = false
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"
vim.opt.mouse = "a"
vim.opt.showmode = false -- lualine shows mode

-- EditorConfig (native in Neovim 0.9+)
vim.g.editorconfig = true

-- Russian layout support in Normal mode (langmap)
-- Maps Cyrillic chars to Latin equivalents by QWERTY position.
-- Only affects Normal/Visual/Operator-pending modes, not Insert.
vim.opt.langmap = table.concat({
  "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz",
  "Ж:",       -- : (command mode)
  "ж\\;",     -- ; (repeat f/t)
  'Э"',       -- " (registers)
  "э'",       -- ' (marks)
  "Б<",       -- < (unindent)
  "б\\,",     -- , (reverse f/t)
  "Ю>",       -- > (indent)
  "ю.",       -- . (repeat last change)
  "х[",       -- [
  "Х{",       -- { (paragraph back)
  "ъ]",       -- ]
  "Ъ}",       -- } (paragraph forward)
  "ё`",       -- ` (exact mark position)
  "Ё~",       -- ~ (toggle case)
}, ",")
vim.opt.langremap = false

-- Disable netrw (neo-tree will replace it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable language providers we don't use (silences :checkhealth warnings).
-- No plugins here need RPC into perl/ruby/node/python runtimes.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
