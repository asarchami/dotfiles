-- Debug Adapter Protocol (DAP) configuration for debugging
return {
  -- Core DAP plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- DAP UI setup
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        element_mappings = {},
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "□",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- Virtual text setup
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = "<module",
        virt_text_pos = "eol",
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- DAP signs
      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "",
        texthl = "DiagnosticSignWarn",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = ".>",
        texthl = "DiagnosticSignInfo",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "→",
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "DiagnosticSignHint",
        linehl = "",
        numhl = "",
      })
    end,
  },

  -- Python DAP adapter
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap_python = require("dap-python")
      
      -- Function to find the best Python executable
      local function find_python_executable()
        -- First, check if there's an active virtual environment
        local venv_path = vim.fn.getenv("VIRTUAL_ENV")
        if venv_path and venv_path ~= vim.NIL then
          local venv_python = venv_path .. "/bin/python"
          if vim.fn.executable(venv_python) == 1 then
            return venv_python
          end
        end
        
        -- Check for local project virtual environments
        local project_root = vim.fn.getcwd()
        local venv_candidates = {
          project_root .. "/venv/bin/python",
          project_root .. "/env/bin/python", 
          project_root .. "/.venv/bin/python",
          project_root .. "/.env/bin/python",
        }
        
        for _, python_path in ipairs(venv_candidates) do
          if vim.fn.executable(python_path) == 1 then
            return python_path
          end
        end
        
        -- Fallback to system Python
        return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
      end
      
      local python_path = find_python_executable()
      dap_python.setup(python_path)
      
      -- Notify which Python is being used for debugging
      vim.notify("DAP-Python using: " .. python_path, vim.log.levels.INFO)

      -- Custom configurations for different Python scenarios
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch file with arguments",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " ")
        end,
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
      })

      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch Django",
        program = "${workspaceFolder}/manage.py",
        args = { "runserver", "--noreload" },
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
        django = true,
      })

      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Launch Flask",
        program = "${workspaceFolder}/app.py",
        env = { FLASK_ENV = "development" },
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
      })
    end,
  },

  -- Go DAP adapter
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
        },
      })
    end,
  },
} 