local group = vim.api.nvim_create_augroup("tamasmarton", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Másolt szöveg rövid kiemelése
autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Fájl újranyitásakor a kurzor az utolsó pozícióra ugrik
autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[args.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Splitek kiegyenlítése, ha a terminál ablak mérete változik
autocmd("VimResized", {
  group = group,
  command = "tabdo wincmd =",
})

-- Go és Java: tabok / 4 szóköz a nyelvi konvenció szerint
autocmd("FileType", {
  group = group,
  pattern = { "go" },
  callback = function() vim.opt_local.expandtab = false; vim.opt_local.tabstop = 4; vim.opt_local.shiftwidth = 4 end,
})
autocmd("FileType", {
  group = group,
  pattern = { "java" },
  callback = function() vim.opt_local.tabstop = 4; vim.opt_local.shiftwidth = 4 end,
})

-- Commit üzenetnél helyesírás és sortörés
autocmd("FileType", {
  group = group,
  pattern = { "gitcommit", "markdown" },
  callback = function() vim.opt_local.wrap = true; vim.opt_local.spell = true end,
})
