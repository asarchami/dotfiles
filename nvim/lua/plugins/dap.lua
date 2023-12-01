return {
  {
    "mfussenegger/nvim-dap",
    opts = function()
      if vim.fn.filereadable(".vscode/launch.json") then
        require("dap.ext.vscode").load_launchjs()
      end
      if vim.fn.filereadable("venv/bin/python") then
        require("dap-python").setup(vim.fn.getcwd() .. "/venv/bin/python")
      end
    end,
    -- stylua: ignore
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Continue' },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F9>", function() require("dap").step_out() end, desc = "Step Out" },
    },
  },
}
