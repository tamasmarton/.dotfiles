-- Treesitter (main ág): parserek telepítése + kiemelés és behúzás FileType-ra.
-- A parserek fordításához a tree-sitter-cli kell (Brewfile).
local parsers = {
  -- web
  "javascript", "typescript", "tsx", "html", "css", "scss", "json", "graphql", "vue", "svelte",
  -- backend
  "go", "gomod", "gosum", "gowork", "java", "kotlin", "groovy", "sql", "rust", "python",
  -- config / egyéb
  "lua", "luadoc", "vim", "vimdoc", "query", "bash", "dockerfile", "yaml", "toml", "xml",
  "markdown", "markdown_inline", "regex", "diff", "git_config", "gitcommit", "gitignore", "make",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- CI-ban (GitHub Actions) nem fordít parsereket, ott csak a config betöltését ellenőrizzük
      if not vim.env.CI then
        require("nvim-treesitter").install(parsers)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("tamasmarton_treesitter", { clear = true }),
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  -- HTML / JSX tagek automatikus zárása és átnevezése
  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, opts = {} },
  -- Helyes kommentjel JSX-ben, Vue-ban stb. a beépített `gc`-hez
  { "folke/ts-comments.nvim", event = "VeryLazy", opts = {} },
}
