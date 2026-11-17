-- Fájlfa (josean kiosztás: <leader>e…)
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle" },
  keys = {
    { "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "Fájlfa ki/be" },
    { "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", desc = "Fájlfa az aktuális fájlnál" },
    { "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "Fájlfa összecsukása" },
    { "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Fájlfa frissítése" },
  },
  opts = {
    view = { width = 35, relativenumber = true },
    renderer = {
      root_folder_label = ":t",
      indent_markers = { enable = true },
      icons = { glyphs = { folder = { arrow_closed = "", arrow_open = "" } } },
    },
    actions = { open_file = { window_picker = { enable = false } } },
    filters = { custom = { "^.DS_Store$", "^.git$" } },
    git = { ignore = false },
    update_focused_file = { enable = true },
  },
}
