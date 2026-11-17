-- Általános billentyűk (a josean-féle kiosztás). A pluginok saját billentyűi a plugin fájlokban vannak.
local map = vim.keymap.set

-- Insert módból kilépés
map("i", "jk", "<Esc>", { desc = "Kilépés insert módból" })

-- Keresés kiemelésének törlése
map("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Keresés kiemelés törlése" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Számok növelése / csökkentése
map("n", "<leader>+", "<C-a>", { desc = "Szám növelése" })
map("n", "<leader>-", "<C-x>", { desc = "Szám csökkentése" })

-- Ablakok (splitek)
map("n", "<leader>sv", "<C-w>v", { desc = "Split függőlegesen" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split vízszintesen" })
map("n", "<leader>se", "<C-w>=", { desc = "Splitek egyforma méretre" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Split bezárása" })

-- Tabok
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Új tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Tab bezárása" })
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Következő tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Előző tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Buffer megnyitása új tabon" })

-- Kijelölt sorok mozgatása
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Sorok le", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Sorok fel", silent = true })

-- Behúzás után a kijelölés megmarad
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Fél képernyős görgetés középre igazítva
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Diagnosztika
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Sor diagnosztikája" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Előző diagnosztika" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Következő diagnosztika" })
