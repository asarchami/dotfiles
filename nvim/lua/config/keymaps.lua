-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local Util = require("lazyvim.util")
local map = vim.keymap.set
local lazyterm = function()
  Util.terminal(nil, { cwd = Util.root(), border = "single" })
end

local function switch_case()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local word = vim.fn.expand("<cword>")
  local word_start = vim.fn.matchstrpos(vim.fn.getline("."), "\\k*\\%" .. (col + 1) .. "c\\k*")[2]

  -- Detect camelCase
  if word:find("[a-z][A-Z]") then
    -- Convert camelCase to snake_case
    local snake_case_word = word:gsub("([a-z])([A-Z])", "%1_%2"):lower()
    -- snake_case_word = snake_case_word:gsub("^%l", string.upper)
    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, { snake_case_word })
  -- Detect snake_case
  elseif word:find("_[a-z]") then
    -- Convert snake_case to camelCase
    local camel_case_word = word:gsub("(_)([a-z])", function(_, l)
      return l:upper()
    end)
    camel_case_word = camel_case_word:gsub("^%l", string.upper)
    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, { camel_case_word })
  else
    print("Not a snake_case or camelCase word")
  end
end

-- return { switch_case = switch_case }
map("v", "<leader>cs", switch_case, { desc = "CamelCase<->SnakeCase" })
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
map("n", "gC", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Go to context" })
