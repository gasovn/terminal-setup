return {
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    build = function()
      vim.cmd([[silent! GoInstallDeps]])
    end,
    opts = {},
    keys = {
      { "<leader>cgt", "<cmd>GoTagAdd json<CR>", desc = "Add json tags", ft = "go" },
      { "<leader>cgT", "<cmd>GoTagRm json<CR>", desc = "Remove json tags", ft = "go" },
      { "<leader>cgm", "<cmd>GoMod tidy<CR>", desc = "Go mod tidy", ft = "go" },
      { "<leader>cge", "<cmd>GoIfErr<CR>", desc = "Go if err", ft = "go" },
      { "<leader>cgs", "<cmd>GoTestAdd<CR>", desc = "Generate test", ft = "go" },
    },
  },
}
