-- Tabok a képernyő tetején (josean: tabs mód)
return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "thin",
      always_show_bufferline = false,
      diagnostics = "nvim_lsp",
      offsets = {
        { filetype = "NvimTree", text = "Fájlok", highlight = "Directory", separator = true },
      },
    },
  },
}
