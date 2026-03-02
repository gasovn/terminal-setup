return {
  -- Enhanced TypeScript support
  {
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeCompletionsForModuleExports = true,
          includeCompletionsWithObjectLiteralMethodSnippets = true,
        },
        complete_function_calls = true,
      },
    },
    keys = {
      { "<leader>co", "<cmd>TSToolsOrganizeImports<CR>", desc = "Organize Imports", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
      { "<leader>cR", "<cmd>TSToolsRenameFile<CR>", desc = "Rename File", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
      { "<leader>ci", "<cmd>TSToolsAddMissingImports<CR>", desc = "Add Missing Imports", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
      { "<leader>cu", "<cmd>TSToolsRemoveUnused<CR>", desc = "Remove Unused Imports", ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" } },
    },
  },
}
