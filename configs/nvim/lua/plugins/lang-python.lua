return {
  -- Auto-detect virtualenv
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    ft = "python",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<CR>", desc = "Select Virtualenv", ft = "python" },
    },
    opts = {},
  },
}
