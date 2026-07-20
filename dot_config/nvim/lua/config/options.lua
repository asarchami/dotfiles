-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Disable tabline at the top
vim.opt.showtabline = 0

-- SSH / headless clipboard: yank → local OS via OSC 52.
-- Paste ← local OS cannot go through tmux reliably; use the terminal's paste
-- (Cmd/Ctrl-Shift-V) in insert mode instead of `p`.
local no_x11_clipboard = os.getenv("DISPLAY") == nil or os.getenv("DISPLAY") == ""
local is_ssh = os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil
if is_ssh and no_x11_clipboard then
  local osc52_copy = require("vim.ui.clipboard.osc52").copy("+")
  -- Match LazyVim: leave clipboard empty on SSH so `p` uses the last yank.
  vim.opt.clipboard = ""
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("Osc52Yank", { clear = true }),
    callback = function()
      if vim.v.event.operator ~= "y" then
        return
      end
      local reg = vim.v.event.regname
      if reg ~= "" and reg ~= "+" and reg ~= "*" then
        return
      end
      local contents = vim.v.event.regcontents
      if contents and #contents > 0 then
        osc52_copy(contents)
      end
    end,
  })
else
  -- Local, or SSH with X11 forwarding (DISPLAY set): a real bidirectional
  -- clipboard tool is available (pbcopy locally, xclip via forwarded DISPLAY),
  -- so let unnamedplus and Nvim's provider auto-detection handle both y and p.
  vim.opt.clipboard = "unnamedplus"
end

-- Auto-reload files when they change outside of Neovim
vim.opt.autoread = true

-- Treat .bqsql files as SQL files
vim.filetype.add({
  extension = {
    bqsql = "sql",
  },
})
