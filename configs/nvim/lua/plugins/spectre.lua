return {
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Search & Replace (Spectre)" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search word (Spectre)" },
      { "<leader>sr", mode = "v", function() require("spectre").open_visual() end, desc = "Search selection (Spectre)" },
    },
    opts = {},
  },
}
