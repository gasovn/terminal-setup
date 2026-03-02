return {
  -- HTTP client (kulala - simpler alternative to rest.nvim, no luarocks needed)
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>hr", function() require("kulala").run() end, desc = "Run HTTP Request", ft = "http" },
      { "<leader>hl", function() require("kulala").replay() end, desc = "Replay Last Request", ft = "http" },
      { "<leader>hi", function() require("kulala").inspect() end, desc = "Inspect Request", ft = "http" },
      { "[r", function() require("kulala").jump_prev() end, desc = "Prev Request", ft = "http" },
      { "]r", function() require("kulala").jump_next() end, desc = "Next Request", ft = "http" },
    },
    opts = {},
  },
}
