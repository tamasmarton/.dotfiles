-- Linterek, amikhez nincs LSP (josean: <leader>l kézi futtatás).
-- JS/TS: az eslint LSP-ként fut (lsp/mason.lua), az eslint_d nem kell.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      go = { "golangcilint" },
      dockerfile = { "hadolint" },
    }

    local function try_lint()
      -- csak azokat futtatja, amik telepítve vannak
      local names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        if type(linter) == "function" then linter = linter() end
        local cmd = linter and linter.cmd
        if type(cmd) == "function" then cmd = cmd() end
        return cmd ~= nil and vim.fn.executable(cmd) == 1
      end, lint.linters_by_ft[vim.bo.filetype] or {})
      if #names > 0 then lint.try_lint(names) end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("tamasmarton_lint", { clear = true }),
      callback = try_lint,
    })
    vim.keymap.set("n", "<leader>l", try_lint, { desc = "Lint futtatása" })
  end,
}
