-- Git jelölések a margón + hunk műveletek (josean kiosztás: <leader>h…, ]h / [h)
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function() gs.nav_hunk("next") end, "Következő hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Előző hunk")

      map("n", "<leader>hs", gs.stage_hunk, "Hunk stage / unstage")
      map("n", "<leader>hr", gs.reset_hunk, "Hunk visszaállítása")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Kijelölés stage")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Kijelölés visszaállítása")
      map("n", "<leader>hS", gs.stage_buffer, "Buffer stage")
      map("n", "<leader>hR", gs.reset_buffer, "Buffer visszaállítása")
      map("n", "<leader>hp", gs.preview_hunk_inline, "Hunk előnézet")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Sor blame")
      map("n", "<leader>hB", gs.toggle_current_line_blame, "Sor blame ki/be")
      map("n", "<leader>hd", gs.diffthis, "Diff")
      map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff az előző commithoz")

      map({ "o", "x" }, "ih", gs.select_hunk, "Hunk kijelölése")
    end,
  },
}
