return {
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    -- Sync variant blocks until `go install` finishes for all 5 deps
    -- (gomodifytags, impl, iferr, gotests, json2go). Async :GoInstallDeps
    -- returns immediately, leaving tools missing on first launch.
    build = ":GoInstallDepsSync",
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
