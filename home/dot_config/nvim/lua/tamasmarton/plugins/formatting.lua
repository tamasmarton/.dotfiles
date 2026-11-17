-- Formázás mentéskor (conform) — josean: <leader>mp kézi formázás.
-- Web: ha a projektben van biome.json, biome; különben prettierd / prettier.
-- Ki/bekapcsolás: :FormatToggle (globális) · :FormatToggle! (csak ez a buffer)

local function web(bufnr)
  if vim.fs.root(bufnr, { "biome.json", "biome.jsonc" }) then
    return { "biome" }
  end
  return { "prettierd", "prettier", stop_after_first = true }
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>mp",
      function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
      mode = { "n", "v" },
      desc = "Fájl / kijelölés formázása",
    },
  },
  opts = {
    formatters_by_ft = {
      javascript = web, typescript = web, javascriptreact = web, typescriptreact = web,
      vue = web, svelte = web, css = web, scss = web, html = web,
      json = web, jsonc = web, graphql = web,
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      lua = { "stylua" },
      go = { "goimports", "gofumpt" },
      java = { lsp_format = "prefer" },   -- jdtls (projekt formázási szabályai); kézzel: google-java-format
      sh = { "shfmt" },
      bash = { "shfmt" },
      ["_"] = { "trim_whitespace" },
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 1500 }
    end,
  },
  init = function()
    vim.api.nvim_create_user_command("FormatToggle", function(args)
      if args.bang then
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify("Formázás mentéskor (buffer): " .. (vim.b.disable_autoformat and "ki" or "be"))
      else
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        vim.notify("Formázás mentéskor: " .. (vim.g.disable_autoformat and "ki" or "be"))
      end
    end, { bang = true, desc = "Formázás mentéskor ki/be" })
  end,
}
