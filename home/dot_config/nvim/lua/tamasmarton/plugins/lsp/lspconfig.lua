-- LSP: Neovim 0.11+ natív API (vim.lsp.config / vim.lsp.enable).
-- Az nvim-lspconfig csak az alap szerver-definíciókat adja, a bekapcsolást a mason-lspconfig végzi.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      "b0o/SchemaStore.nvim",
      { "antosha417/nvim-lsp-file-operations", config = true },  -- fájl átnevezésnél importok frissítése
    },
    config = function()
      -- Minden szerver: blink.cmp képességek
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- ── Szerverenkénti beállítások ──────────────────────────────────
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            hint = { enable = true },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.config("vtsls", {
        settings = {
          complete_function_calls = true,
          vtsls = { autoUseWorkspaceTsdk = true, enableMoveToFileCodeAction = true },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
            inlayHints = {
              parameterNames = { enabled = "literals" },
              functionLikeReturnTypes = { enabled = true },
              enumMemberValues = { enabled = true },
            },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-node_modules", "-.vscode", "-.idea" },
            analyses = { unusedparams = true, unusedwrite = true, nilness = true, shadow = true },
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

      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact", "vue", "svelte" },
      })

      -- ── Diagnosztika megjelenése ────────────────────────────────────
      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
        float = { border = "rounded", source = "if_many" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰠠 ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })

      -- ── Billentyűk, ha egy LSP csatlakozik (josean kiosztás) ─────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("tamasmarton_lsp", { clear = true }),
        callback = function(ev)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end

          map("n", "gR", function() Snacks.picker.lsp_references() end, "Hivatkozások")
          map("n", "gD", vim.lsp.buf.declaration, "Deklaráció")
          map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Definíció")
          map("n", "gi", function() Snacks.picker.lsp_implementations() end, "Implementációk")
          map("n", "gt", function() Snacks.picker.lsp_type_definitions() end, "Típus definíció")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Átnevezés")
          map("n", "<leader>D", function() Snacks.picker.diagnostics_buffer() end, "Fájl diagnosztikái")
          map("n", "K", function() vim.lsp.buf.hover() end, "Dokumentáció")
          map("n", "<leader>rs", "<cmd>lsp restart<CR>", "LSP újraindítása")
          map("n", "<leader>cs", function() Snacks.picker.lsp_symbols() end, "Szimbólumok (fájl)")
          map("n", "<leader>cS", function() Snacks.picker.lsp_workspace_symbols() end, "Szimbólumok (projekt)")
          map("n", "<leader>ch", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, "Inlay hintek ki/be")
        end,
      })
    end,
  },

  -- Lua fejlesztés a Neovim configban (a neodev utódja)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
