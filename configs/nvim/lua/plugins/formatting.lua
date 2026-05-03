return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format buffer" },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        go = { "gofmt", "goimports" },
        python = { "black", "isort" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      format_on_save = function(bufnr)
        -- Don't format if no config found for prettier
        local ft = vim.bo[bufnr].filetype
        local prettier_fts = {
          "javascript", "typescript", "javascriptreact", "typescriptreact",
          "json", "yaml", "html", "css", "scss", "markdown",
        }
        if vim.tbl_contains(prettier_fts, ft) then
          -- Check if prettier config exists
          local root = vim.fs.root(bufnr, { ".prettierrc", ".prettierrc.json", ".prettierrc.yml",
            ".prettierrc.js", ".prettierrc.cjs", "prettier.config.js", "prettier.config.cjs",
            "prettier.config.mjs", ".prettierrc.yaml", ".prettierrc.toml" })
          if not root then
            return nil -- skip formatting
          end
        end
        return { timeout_ms = 3000, lsp_fallback = true }
      end,
      formatters = {
        prettier = {
          require_cwd = true,
        },
        stylua = {
          require_cwd = true,
        },
        black = {
          require_cwd = true,
        },
      },
    },
  },
}
