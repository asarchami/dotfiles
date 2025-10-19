return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `toggle()`.
    { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
    }
    -- Required for `vim.g.opencode_opts.auto_reload`
    vim.opt.autoread = true

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask about this" })
    vim.keymap.set({ "n", "x" }, "os", function() require("opencode").select() end, { desc = "Select prompt" })
    vim.keymap.set({ "n", "x" }, "o+", function() require("opencode").prompt("@this") end, { desc = "Add this" })
    vim.keymap.set("n", "ot", function() require("opencode").toggle() end, { desc = "Toggle embedded" })
    vim.keymap.set("n", "oc", function() require("opencode").command() end, { desc = "Select command" })
    vim.keymap.set("n", "on", function() require("opencode").command("session_new") end, { desc = "New session" })
    vim.keymap.set("n", "oi", function() require("opencode").command("session_interrupt") end, { desc = "Interrupt session" })
    vim.keymap.set("n", "oA", function() require("opencode").command("agent_cycle") end, { desc = "Cycle selected agent" })
    vim.keymap.set("n", "<c-j>", function() require("opencode").command("messages_half_page_up") end, { desc = "Messages half page up" })
    vim.keymap.set("n", "<c-k>", function() require("opencode").command("messages_half_page_down") end, { desc = "Messages half page down" })
  end,
}
