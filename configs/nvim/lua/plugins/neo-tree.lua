return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "File Explorer" },
      { "<leader>E", "<cmd>Neotree reveal<CR>", desc = "Reveal file in Explorer" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_modified_markers = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".git", "__pycache__", ".DS_Store" },
        },
      },
      window = {
        width = 35,
        mappings = {
          ["<space>"] = "none",
          ["R"] = "refresh",
          ["Y"] = function(state)
            local node = state.tree:get_node()
            local path = vim.fn.fnamemodify(node:get_id(), ":.")
            vim.fn.setreg("+", path)
            vim.notify("Copied: " .. path)
          end,
          ["gy"] = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path)
            vim.notify("Copied: " .. path)
          end,
        },
      },
      default_component_configs = {
        indent = { with_expanders = true },
        modified = { symbol = "●" },
        name = { use_git_status_colors = true },
        git_status = {
          symbols = {
            added     = "✚",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "★",
            ignored   = "◌",
            unstaged  = "󰄱",
            staged    = "󰱒",
            conflict  = "",
          },
        },
      },
      renderers = {
        directory = {
          { "indent" },
          { "icon" },
          { "current_filter" },
          {
            "container",
            content = {
              { "name", zindex = 10 },
              { "symlink_target", zindex = 10, highlight = "NeoTreeSymbolicLinkTarget" },
              { "clipboard", zindex = 10 },
              { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
              -- git_status always visible on directories (even when expanded)
              { "git_status", zindex = 20, align = "right" },
            },
          },
        },
      },
    },
  },
}
