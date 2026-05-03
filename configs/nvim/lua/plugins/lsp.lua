return {
  -- Mason: manage LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
    },
  },

  -- Auto-install Mason packages that mason-lspconfig doesn't cover
  -- (formatters, linters, DAP adapters).
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettier",       -- conform: js/ts/json/yaml/html/css/md
        "goimports",      -- conform: go
        "black",          -- conform: python
        "isort",          -- conform: python imports
        "stylua",         -- conform: lua
        "ruff",           -- nvim-lint: python
        "golangci-lint",  -- nvim-lint: go
        "codelldb",       -- DAP: rust
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  -- Bridge between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "SmiteshP/nvim-navic",
    },
    config = function()
      local cmp_lsp = require("cmp_nvim_lsp")
      local navic = require("nvim-navic")

      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities()
      )

      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local bufnr = ev.buf

          if client and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, bufnr)
          end

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
          end

          map("gd", "<cmd>Telescope lsp_definitions<CR>", "Go to Definition")
          map("gr", "<cmd>Telescope lsp_references<CR>", "Go to References")
          map("gi", "<cmd>Telescope lsp_implementations<CR>", "Go to Implementation")
          map("gy", "<cmd>Telescope lsp_type_definitions<CR>", "Go to Type Definition")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>cd", vim.diagnostic.open_float, "Line Diagnostics")
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
        end,
      })

      -- Mason-lspconfig: ensure servers installed
      -- For C#: install on demand with :MasonInstall omnisharp + dotnet SDK
      -- (omnisharp shells out to `dotnet` and won't start without it).
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint",
          "gopls",
          "basedpyright",
          "rust_analyzer",
          "lua_ls",
          "jsonls",
          "yamlls",
          "html",
          "cssls",
          "dockerls",
          "bashls",
        },
        automatic_enable = false,
      })

      -- Configure servers via vim.lsp.config (Neovim 0.11+ native API)
      vim.lsp.config("eslint", {
        capabilities = capabilities,
      })

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        capabilities = capabilities,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            cargo = { allFeatures = true },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("jsonls", {
        capabilities = capabilities,
        settings = { json = { validate = { enable = true } } },
      })

      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = { yaml = { keyOrdering = false } },
      })

      vim.lsp.config("html", { capabilities = capabilities })
      vim.lsp.config("cssls", { capabilities = capabilities })
      vim.lsp.config("dockerls", { capabilities = capabilities })
      vim.lsp.config("bashls", { capabilities = capabilities })

      -- Enable all configured servers
      vim.lsp.enable({
        "eslint", "gopls", "basedpyright", "rust_analyzer",
        "lua_ls", "jsonls", "yamlls", "html", "cssls",
        "dockerls", "bashls",
      })

      -- ESLint auto-fix on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("EslintFixAll", { clear = true }),
        callback = function(ev)
          local clients = vim.lsp.get_clients({ bufnr = ev.buf, name = "eslint" })
          if #clients > 0 then
            vim.cmd("EslintFixAll")
          end
        end,
      })

      -- Diagnostic config
      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })
    end,
  },
}
