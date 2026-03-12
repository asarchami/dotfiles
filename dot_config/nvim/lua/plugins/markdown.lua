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

  -- Disable markdownlint via nvim-lint for markdown files
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      if opts.linters_by_ft then
        opts.linters_by_ft["markdown"] = {}
      end
    end,
  },

  -- Disable markdown formatting via conform
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      if opts.formatters_by_ft then
        opts.formatters_by_ft["markdown"] = {}
        opts.formatters_by_ft["markdown.mdx"] = {}
      end
    end,
  },

  -- Disable marksman LSP diagnostics for markdown
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        marksman = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
        },
      },
    },
  },
}
