-- Python development support (only loads if Python is available)

-- Check if Python is available
local function is_python_available()
  return vim.fn.executable("python3") == 1 or vim.fn.executable("python") == 1
end

-- Only return Python plugins if Python is installed
if not is_python_available() then
  return {}
end

-- Shared utility function for finding Python executable
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

return {
  -- Neotest: Modern testing framework
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",  -- Python adapter
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG" },
            runner = "pytest",
            python = find_python_executable,
          }),
        },
        discovery = {
          enabled = true,
          concurrent = 1,
        },
        running = {
          concurrent = true,
        },
        summary = {
          enabled = true,
          animated = true,
          follow = true,
          expand_errors = true,
        },
        icons = {
          child_indent = "│",
          child_prefix = "├",
          collapsed = "─",
          expanded = "╮",
          failed = "",
          final_child_indent = " ",
          final_child_prefix = "╰",
          non_collapsible = "─",
          passed = "",
          running = "",
          running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
          skipped = "",
          unknown = "",
        },
        floating = {
          border = "rounded",
          max_height = 0.6,
          max_width = 0.6,
          options = {},
        },
        strategies = {
          integrated = {
            height = 40,
            width = 120,
          },
        },
      })
    end,
  },

  -- Python virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      require("venv-selector").setup({
        settings = {
          search = {
            -- Local project venv directories (most common)
            local_venv = {
              command = "fd python$ ./venv ./env ./.venv ./.env --type file --max-depth 3",
            },
            -- Poetry environments
            poetry = {
              command = "fd pyvenv.cfg ./venv -t f",
            },
            -- Pipenv environments
            pipenv = {
              command = "fd pyvenv.cfg . --type file --max-depth 4",
            },
            -- Personal virtualenvs
            my_venvs = {
              command = "fd python$ ~/.virtualenvs",
            },
            -- Conda environments
            anaconda_envs = {
              command = "fd python$ ~/anaconda3/envs ~/miniconda3/envs ~/.conda/envs",
            },
            -- Pyenv environments
            pyenv = {
              command = "fd pyvenv.cfg ~/.pyenv/versions -t f --max-depth 3",
            },
          },
          options = {
            notify_user_on_venv_activation = true,
            enable_default_searches = true,
            enable_cached_venvs = true,
            -- Set working directory to project root
            set_environment_variables = true,
          },
        },
      })
    end,
  },

  -- Python REPL integration
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")
      
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            python = {
              command = function()
                return { find_python_executable() }
              end,
              format = require("iron.fts.common").bracketed_paste,
            },
          },
          repl_open_cmd = require("iron.view").split.vertical.botright(0.4),
        },
        keymaps = {
          send_motion = "<space>cpr",
          visual_send = "<space>cpr",
          send_file = "<space>cpf",
          send_line = "<space>cpl",
          send_until_cursor = "<space>cpu",
          send_mark = "<space>cpm",
          mark_motion = "<space>cpm",
          mark_visual = "<space>cpm",
          remove_mark = "<space>cpd",
          cr = "<space>cp<cr>",
          interrupt = "<space>cp<space>",
          exit = "<space>cpq",
          clear = "<space>cpc",
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true,
      })
    end,
  },

  -- Enhanced Python syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
        },
      })
    end,
  },

  -- Python docstring generation
  {
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("neogen").setup({
        enabled = true,
        languages = {
          python = {
            template = {
              annotation_convention = "google_docstrings",
            },
          },
        },
      })
    end,
  },

  -- Python-specific which-key mappings (loaded only for Python files)
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function()
      -- Only add these mappings when editing Python files
              vim.api.nvim_create_autocmd("FileType", {
          pattern = "python",
          callback = function()
            local wk = require("which-key")
            wk.add({
              -- ===================================================================
              -- TESTING OPERATIONS (<leader>t) - Python-specific, overrides tabs
              -- ===================================================================
              { "<leader>t", group = " Test - Python" },
              { "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", desc = " Run nearest test" },
              { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = " Run file tests" },
              { "<leader>ta", "<cmd>lua require('neotest').run.run(vim.fn.getcwd())<cr>", desc = " Run all tests" },
              { "<leader>to", "<cmd>lua require('neotest').output.open({ enter = true })<cr>", desc = " Test output" },
              { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = " Test summary" },
              { "<leader>tc", "<cmd>lua require('neotest').run.stop()<cr>", desc = " Cancel test" },
              { "<leader>tl", "<cmd>lua require('neotest').run.run_last()<cr>", desc = " Run last test" },
              { "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = " Debug nearest test" },
              
              -- Python test-specific operations
              { "<leader>tm", "<cmd>lua require('dap-python').test_method()<cr>", desc = " Debug test method" },
              { "<leader>tC", "<cmd>lua require('dap-python').test_class()<cr>", desc = " Debug test class" },

              -- ===================================================================
              -- DEBUG OPERATIONS (<leader>d) - Python-specific
              -- ===================================================================
              { "<leader>d", group = " Debug - Python" },
              { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = " Toggle breakpoint" },
              { "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", desc = " Conditional breakpoint" },
              { "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = " Continue" },
              { "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = " Step into" },
              { "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = " Step over" },
              { "<leader>dO", "<cmd>lua require'dap'.step_out()<cr>", desc = " Step out" },
              { "<leader>dr", "<cmd>lua require'dap'.repl.open()<cr>", desc = " Open REPL" },
              { "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", desc = " Run last" },
              { "<leader>du", "<cmd>lua require'dapui'.toggle()<cr>", desc = " Toggle UI" },
              { "<leader>dt", "<cmd>lua require'dap'.terminate()<cr>", desc = " Terminate" },
              { "<leader>dh", "<cmd>lua require'dap.ui.widgets'.hover()<cr>", desc = " Hover" },
              { "<leader>dv", "<cmd>lua require'dap.ui.widgets'.preview()<cr>", desc = " Preview" },
              
              -- Python debug-specific operations
              { "<leader>ds", "<cmd>lua require('dap-python').debug_selection()<cr>", desc = " Debug selection" },
              { "<leader>df", "<cmd>lua require('dap-python').debug_file()<cr>", desc = " Debug current file" },

              -- ===================================================================
              -- PYTHON-SPECIFIC OPERATIONS (<leader>cp) - Much cleaner now!
              -- ===================================================================
              { "<leader>cp", group = " Python" },
              
              -- Environment management
              { "<leader>cps", "<cmd>VenvSelect<cr>", desc = " Select venv" },
              { "<leader>cpi", "<cmd>VenvSelectCached<cr>", desc = " Select cached venv" },
              { "<leader>cpe", "<cmd>VenvSelectCurrent<cr>", desc = " Show current venv" },
              
              -- REPL operations
              { "<leader>cpr", "<cmd>IronRepl<cr>", desc = " Toggle REPL" },
              { "<leader>cpR", "<cmd>IronFocus<cr>", desc = " Focus REPL" },
              { "<leader>cpz", "<cmd>IronRestart<cr>", desc = " Restart REPL" },
              { "<leader>cph", "<cmd>IronHide<cr>", desc = " Hide REPL" },
              
              -- Documentation
              { "<leader>cpg", "<cmd>lua require('neogen').generate()<cr>", desc = " Generate docstring" },
            }, { buffer = vim.api.nvim_get_current_buf() })
          end,
        })
    end,
  },
} 