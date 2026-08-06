-- HTML: live browser preview (no external runtime deps, unlike markdown-preview.nvim).
local function toggle_live_preview()
  if vim.g.live_preview_running then
    vim.cmd("LivePreview close")
    vim.g.live_preview_running = false
  else
    vim.cmd("LivePreview start")
    vim.g.live_preview_running = true
  end
end

return {
  {
    "brianhuster/live-preview.nvim",
    cmd = "LivePreview",
    keys = {
      { "<leader>cp", toggle_live_preview, ft = "html", desc = "Live Preview (HTML)" },
    },
  },
}
