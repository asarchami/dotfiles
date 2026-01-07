-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.del("n", "<leader>wh")
-- vim.keymap.del("n", "<leader>wl")
-- vim.keymap.del("n", "<leader>wk")
-- vim.keymap.del("n", "<leader>wj")

local map = vim.keymap.set
map("n", "<leader>wh", "<cmd>split<cr>", { desc = "Split window horizontally" })
