-- Fish: skip fish_indent on chezmoi .tmpl files (its brace expansion
-- rewriting turns `{{` / `}}` into `{ {` / `} }`, breaking template syntax).

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        formatters_by_ft = {
          fish = function(bufnr)
            if vim.api.nvim_buf_get_name(bufnr):match("%.tmpl$") then
              return {}
            end
            return { "fish_indent" }
          end,
        },
      })
    end,
  },
}