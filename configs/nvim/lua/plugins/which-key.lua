return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>m", group = "Markdown" },
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>q", group = "Quit/Session" },
        { "<leader>r", group = "Rename/Replace" },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>t", group = "Test" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>D", group = "Database" },
      },
    },
  },
}
