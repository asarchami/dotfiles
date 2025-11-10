return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  ft = { 'markdown' },
  opts = {
    latex = { enabled = false },
    renderer = {
      term = {
        enabled = true,
      },
    },
  },
  keys = {
    { '<leader>cm', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle Markdown preview' },
  },
}