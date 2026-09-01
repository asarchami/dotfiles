return {
  {
    "asarchami/dataview.nvim",
    url = "git@github-personal:asarchami/dataview.nvim.git",
    dependencies = { "folke/snacks.nvim" },
    lazy = false,
    config = function()
      require("dataview").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>db", group = "BigQuery" },
        { "<leader>dD", group = "DuckDB" },
        { "<leader>dL", group = "SQLite" },
        { "<leader>dp", group = "Postgres" },
      },
    },
  },
}
