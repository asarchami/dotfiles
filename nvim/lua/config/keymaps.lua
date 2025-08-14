-- Keymaps configuration
-- NON-LEADER key mappings only
-- All leader-based mappings are handled by which-key.lua

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ===================================================================
-- Non-leader keymaps (Ctrl, Alt, Shift combinations)
-- ===================================================================

-- Better escape
keymap("i", "jk", "<Esc>", opts)

-- Better window navigation (Ctrl + hjkl)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows with arrows (Ctrl + arrows)
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers (Shift + hl) - Uses BufferLine for better integration
keymap("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", opts)
keymap("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", opts)

-- Move text up and down (Alt + jk)
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)

-- Better paste in visual mode (don't overwrite register)
keymap("v", "p", '"_dP', opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Diagnostic navigation (without leader)
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- Quick save (without leader)
keymap("n", "<C-s>", ":w<CR>", opts)
keymap("i", "<C-s>", "<Esc>:w<CR>", opts)

-- ===================================================================
-- NOTE: All leader-based mappings are defined in which-key.lua
-- This includes <leader>f, <leader>g, <leader>b, etc.
-- =================================================================== 