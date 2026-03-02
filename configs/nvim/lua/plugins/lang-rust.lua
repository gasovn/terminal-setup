return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            cargo = { allFeatures = true },
            inlayHints = {
              bindingModeHints = { enable = true },
              closureReturnTypeHints = { enable = "always" },
              lifetimeElisionHints = { enable = "always" },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = opts

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.keymap.set("n", "<leader>cr", "<cmd>RustLsp runnables<CR>", { buffer = bufnr, desc = "Rust Runnables" })
          vim.keymap.set("n", "<leader>ct", "<cmd>RustLsp testables<CR>", { buffer = bufnr, desc = "Rust Testables" })
          vim.keymap.set("n", "<leader>ce", "<cmd>RustLsp explainError<CR>", { buffer = bufnr, desc = "Explain Error" })
          vim.keymap.set("n", "<leader>cR", "<cmd>RustLsp run<CR>", { buffer = bufnr, desc = "Rust Run" })
          vim.keymap.set("n", "J", "<cmd>RustLsp joinLines<CR>", { buffer = bufnr, desc = "Join Lines" })
        end,
      })
    end,
  },
}
