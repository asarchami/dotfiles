-- Query input. vim.ui.input is deliberate rather than a hand-rolled float:
-- LazyVim routes it through snacks/dressing, so this inherits whatever input
-- UI is already configured instead of introducing a second look.

local M = {}

--- Prompt for SQL, seeded with the last query run in this buffer.
--- @param buf integer
--- @param on_submit fun(sql: string)
function M.query(buf, on_submit)
  vim.ui.input({
    prompt = "SQL (table: t) ",
    default = vim.b[buf].dataview_sql or "SELECT * FROM t ",
    completion = "sql",
  }, function(sql)
    -- nil when cancelled; blank when the user submitted an empty line.
    if sql and sql:match("%S") then
      on_submit(sql)
    end
  end)
end

return M
