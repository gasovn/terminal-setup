return {
  -- package.json version info
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = "json",
    opts = {},
    config = function(_, opts)
      require("package-info").setup(opts)
      -- Only activate on package.json
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "package.json",
        callback = function()
          vim.keymap.set("n", "<leader>ns", require("package-info").show, { buffer = true, desc = "Show package versions" })
          vim.keymap.set("n", "<leader>nu", require("package-info").update, { buffer = true, desc = "Update package" })
          vim.keymap.set("n", "<leader>nd", require("package-info").delete, { buffer = true, desc = "Delete package" })
          vim.keymap.set("n", "<leader>ni", require("package-info").install, { buffer = true, desc = "Install package" })
          vim.keymap.set("n", "<leader>nc", require("package-info").change_version, { buffer = true, desc = "Change version" })
        end,
      })
    end,
  },

  -- Cargo.toml version info
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      completion = {
        cmp = { enabled = true },
      },
    },
  },
}
