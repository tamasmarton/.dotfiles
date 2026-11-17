-- Kisebb szerkesztő pluginok (josean kiosztással)
return {
  -- Ctrl-h/j/k/l: mozgás nvim splitek és tmux panelek között (a tmux oldali párja a tmux.conf-ban)
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>" },
    },
  },

  -- Zárójelek automatikus párosítása
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = { check_ts = true } },

  -- Körülvevő karakterek: ys{motion}{char}, cs{régi}{új}, ds{char}
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Csere a vágólap tartalmával (josean: s / ss / S)
  {
    "gbprod/substitute.nvim",
    keys = {
      { "s", function() require("substitute").operator() end, desc = "Csere mozgással" },
      { "ss", function() require("substitute").line() end, desc = "Sor cseréje" },
      { "S", function() require("substitute").eol() end, desc = "Csere a sor végéig" },
      { "s", function() require("substitute").visual() end, mode = "x", desc = "Kijelölés cseréje" },
    },
    opts = {},
  },

  -- TODO / FIXME / NOTE kiemelés (josean: ]t / [t)
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Következő TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Előző TODO" },
    },
    opts = {},
  },

  -- Diagnosztika lista (josean: <leader>x…)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Projekt diagnosztikák" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Fájl diagnosztikák" },
      { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Quickfix lista" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location lista" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODO-k" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Szimbólumok" },
    },
  },

  -- Session mappánként (josean: <leader>wr / <leader>ws); automatikus visszaállítás nincs
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      { "<leader>wr", "<cmd>AutoSession restore<CR>", desc = "Session visszaállítása" },
      { "<leader>ws", "<cmd>AutoSession save<CR>", desc = "Session mentése" },
      { "<leader>wf", "<cmd>AutoSession search<CR>", desc = "Session keresése" },
    },
    opts = {
      auto_restore = false,
      suppressed_dirs = { "~/", "~/Developer", "~/Downloads", "~/Desktop", "/" },
    },
  },
}
