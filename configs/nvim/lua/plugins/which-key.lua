return {
  -- Unified icon provider used by which-key, pickers, and other UI plugins.
  -- Falls back to nvim-web-devicons when missing, but mini.icons gives
  -- consistent rendering across all consumers.
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
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
