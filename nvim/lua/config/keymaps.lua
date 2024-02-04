-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local map = vim.keymap.set
local lazyterm = function()
  Util.terminal(nil, { cwd = Util.root(), border = "single" })
end
map("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<leader>fT", function()
  Util.terminal()
end, { desc = "Terminal (cwd)" })
map("n", "<c-/>", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<c-_>", lazyterm, { desc = "which_key_ignore" })
map("n", "<leader>wda", function()
  vim.cmd([[bufdo bw!]])
  vim.cmd([[only]])
end, { desc = "Delete all buffers and windows" })
map("n", "<leader>wdd", "<cmd>q<CR>", { desc = "Delete current windows" })
-- map("n", "gC", function()
--   require("treesitter-context").go_to_context(vim.v.count1)
-- end, { silent = true, desc = "Go to context" })
