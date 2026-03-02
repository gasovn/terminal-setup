return {
  -- Treesitter (parser management + queries)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    lazy = false,
    config = function()
      -- Ensure parsers are installed
      local langs = {
        "javascript", "typescript", "tsx",
        "go", "gomod", "gosum",
        "python",
        "rust",
        "c_sharp",
        "json", "yaml", "toml",
        "html", "css", "scss",
        "lua", "luadoc",
        "bash", "fish",
        "markdown", "markdown_inline",
        "dockerfile",
        "sql",
        "http",
        "vim", "vimdoc",
        "regex",
        "gitcommit", "gitignore", "diff",
      }

      -- Install missing parsers asynchronously
      local installed = require("nvim-treesitter").get_installed()
      local to_install = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, langs)

      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- Enable treesitter-based highlighting and indentation for all buffers
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  -- Textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")
      local map = vim.keymap.set

      -- Select textobjects
      local select_maps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
      }
      for key, query in pairs(select_maps) do
        map({ "x", "o" }, key, function() select.select_textobject(query) end, { desc = query })
      end

      -- Move: next start
      local next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]a"] = "@parameter.inner",
      }
      for key, query in pairs(next_start) do
        map({ "n", "x", "o" }, key, function() move.goto_next_start(query) end, { desc = "Next " .. query })
      end

      -- Move: next end
      local next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
      }
      for key, query in pairs(next_end) do
        map({ "n", "x", "o" }, key, function() move.goto_next_end(query) end, { desc = "Next end " .. query })
      end

      -- Move: prev start
      local prev_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[a"] = "@parameter.inner",
      }
      for key, query in pairs(prev_start) do
        map({ "n", "x", "o" }, key, function() move.goto_previous_start(query) end, { desc = "Prev " .. query })
      end

      -- Move: prev end
      local prev_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
      }
      for key, query in pairs(prev_end) do
        map({ "n", "x", "o" }, key, function() move.goto_previous_end(query) end, { desc = "Prev end " .. query })
      end

      -- Swap
      map("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { desc = "Swap next argument" })
      map("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap prev argument" })
    end,
  },

  -- Sticky context (current function/class at top of screen)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      max_lines = 3,
      multiline_threshold = 1,
    },
  },
}
