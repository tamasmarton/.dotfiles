-- snacks.nvim: dashboard, fuzzy picker, lazygit, indent vonalak, értesítések, zoom.
-- Kiváltja: alpha, telescope, lazygit.nvim, indent-blankline, dressing, vim-maximizer.
-- A picker billentyűk a josean-féle telescope kiosztást követik (<leader>f…); a listában Ctrl-j/k mozog.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    indent = { enabled = true, animate = { enabled = false } },
    scope = { enabled = true },
    words = { enabled = true },
    lazygit = { configure = false },  -- a saját ~/.config/lazygit témát használja
    picker = {
      layout = { preset = "telescope" },
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        explorer = { hidden = true },
      },
    },
    dashboard = {
      preset = {
        header = [[
  ███╗   ██╗██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██║   ██║██║████╗ ████║
  ██╔██╗ ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        keys = {
          { icon = " ", key = "f", desc = "Fájl keresése", action = ":lua Snacks.picker.files()" },
          { icon = " ", key = "s", desc = "Szöveg keresése", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Legutóbbi fájlok", action = ":lua Snacks.picker.recent()" },
          { icon = " ", key = "e", desc = "Fájlfa", action = ":NvimTreeToggle" },
          { icon = "󰁯 ", key = "w", desc = "Session visszaállítása", action = ":AutoSession restore" },
          { icon = " ", key = "g", desc = "Lazygit", action = ":lua Snacks.lazygit()" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "q", desc = "Kilépés", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
  },
  keys = {
    -- Keresés (josean: telescope)
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Fájlok keresése" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Legutóbbi fájlok" },
    { "<leader>fs", function() Snacks.picker.grep() end, desc = "Szöveg keresése" },
    { "<leader>fc", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Kurzor alatti szó keresése" },
    { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "TODO-k keresése" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Bufferek" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Súgó" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Billentyűk" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnosztikák (projekt)" },
    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Értesítések" },
    { "<leader><leader>", function() Snacks.picker.smart() end, desc = "Okos keresés" },
    -- Git
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log_file() end, desc = "Fájl git története" },
    { "<leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Megnyitás GitHubon" },
    -- Ablak (josean: vim-maximizer)
    { "<leader>sm", function() Snacks.zen.zoom() end, desc = "Split maximalizálása / vissza" },
    -- Egyéb
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Buffer bezárása" },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Következő előfordulás" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Előző előfordulás" },
  },
}
