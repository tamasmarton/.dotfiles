local opt = vim.opt

-- A leader billentyűt a pluginok előtt kell beállítani
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- nvim-tree miatt a netrw ki van kapcsolva
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Sorszámok
opt.number = true
opt.relativenumber = true

-- Behúzás (prettier alapértelmezés)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Megjelenés
opt.wrap = false
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false            -- a lualine mutatja
opt.laststatus = 3              -- egy globális státuszsor
opt.winborder = "rounded"       -- lebegő ablakok kerete (nvim 0.11+)
opt.pumheight = 12
opt.fillchars = { eob = " " }
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Keresés
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"        -- :s előnézet

-- Szerkesztés
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.mouse = "a"
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400

-- Fájlok
opt.swapfile = false
opt.undofile = true             -- visszavonás újraindítás után is
