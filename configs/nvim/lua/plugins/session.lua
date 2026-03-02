return {
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      { "<leader>qs", "<cmd>SessionSave<CR>", desc = "Save Session" },
      { "<leader>qr", "<cmd>SessionRestore<CR>", desc = "Restore Session" },
      { "<leader>qd", "<cmd>SessionDelete<CR>", desc = "Delete Session" },
      { "<leader>qf", "<cmd>SessionSearch<CR>", desc = "Search Sessions" },
    },
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/tmp" },
      bypass_save_filetypes = { "alpha", "neo-tree" },
      pre_save_cmds = { "Neotree close" },
      post_restore_cmds = { "Neotree show filesystem left" },
    },
  },
}
