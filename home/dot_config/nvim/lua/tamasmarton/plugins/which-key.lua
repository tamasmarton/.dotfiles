-- Billentyű-súgó: <leader> után megmutatja a lehetőségeket
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 400,
    spec = {
      { "<leader>b", group = "debug / buffer" },
      { "<leader>c", group = "kód" },
      { "<leader>e", group = "fájlfa" },
      { "<leader>f", group = "keresés" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "git hunk" },
      { "<leader>j", group = "java" },
      { "<leader>s", group = "split" },
      { "<leader>t", group = "tab" },
      { "<leader>w", group = "session" },
      { "<leader>x", group = "trouble" },
    },
  },
  keys = {
    { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer billentyűi" },
  },
}
