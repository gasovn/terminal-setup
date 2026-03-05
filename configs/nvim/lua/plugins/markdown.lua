return {
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && npm install",
    keys = {
      {
        "<leader>mp",
        function()
          vim.fn["mkdp#util#toggle_preview"]()
        end,
        desc = "Markdown Preview",
      },
    },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
