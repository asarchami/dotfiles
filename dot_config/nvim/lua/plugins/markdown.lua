-- Markdown: use render-markdown.nvim for display, suppress lint/format noise.

return {
  -- Override render-markdown.nvim defaults from the LazyVim extra
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
      },
    },
  },

  -- LazyVim markdown extra uses markdownlint-cli2 here (not "markdownlint")
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        linters_by_ft = {
          markdown = {},
          ["markdown.mdx"] = {},
        },
      })
    end,
  },

  -- LazyVim adds markdownlint_cli2 diagnostics via none-ls
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local ok, nls = pcall(require, "null-ls")
      if ok and opts.sources then
        local md = nls.builtins.diagnostics.markdownlint_cli2
        opts.sources = vim.tbl_filter(function(s)
          return s ~= md
        end, opts.sources)
      end
      return opts
    end,
  },

  -- Disable markdown formatting via conform
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        formatters_by_ft = {
          markdown = {},
          ["markdown.mdx"] = {},
        },
      })
    end,
  },

  -- Turn off marksman so its diagnostics do not show (links/refs features go too)
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        marksman = {
          enabled = false,
        },
      },
    },
  },
}
