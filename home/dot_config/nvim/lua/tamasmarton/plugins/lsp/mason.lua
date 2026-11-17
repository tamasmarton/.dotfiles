-- Mason: LSP szerverek, formázók, linterek és debuggerek telepítése (~/.local/share/nvim/mason)
-- A Node / Go / Java alapú eszközökhöz a mise által adott runtime kell a PATH-ban.

-- LSP szerverek (lspconfig nevek). A jdtls-t a mason-lspconfig NEM indítja, azt az nvim-jdtls kezeli.
local servers = {
  "lua_ls",
  -- JS / TS / web
  "vtsls", "eslint", "html", "cssls", "tailwindcss", "emmet_language_server", "jsonls", "yamlls",
  -- Go
  "gopls",
  -- Java (nvim-jdtls indítja: ftplugin/java.lua)
  "jdtls",
  -- egyéb
  "bashls", "dockerls", "docker_compose_language_service", "taplo", "marksman",
}

-- Nem-LSP eszközök (mason csomagnevek)
local tools = {
  "prettierd", "prettier", "stylua", "shfmt", "shellcheck", "hadolint",
  "gofumpt", "goimports", "golangci-lint", "delve",
  "java-debug-adapter", "java-test", "google-java-format",
}

return {
  {
    "mason-org/mason.nvim",
    lazy = false,             -- olcsó, és így a mason/bin már induláskor a PATH-ban van (conform, nvim-lint)
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = servers,
      -- a telepített szervereket automatikusan bekapcsolja (vim.lsp.enable), kivéve:
      -- (a stylua-t a conform futtatja, LSP-ként nem kell)
      automatic_enable = { exclude = { "jdtls", "stylua" } },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = { ensure_installed = tools, run_on_start = true, start_delay = 3000 },
  },
}
