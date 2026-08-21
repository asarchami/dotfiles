-- Parquet preview: parquet is binary, so opening one normally dumps raw bytes
-- into the buffer. BufReadCmd takes over the read and renders a text table.
--
-- duckdb rather than a plugin: one binary that is useful outside Neovim anyway,
-- reads parquet natively, and keeps the row limit and view modes configurable
-- here instead of hardcoded upstream.

local PREVIEW_ROWS = 500

local QUERIES = {
  data = "SELECT * FROM read_parquet(%s) LIMIT " .. PREVIEW_ROWS,
  schema = "DESCRIBE SELECT * FROM read_parquet(%s)",
  stats = "SUMMARIZE SELECT * FROM read_parquet(%s)",
}

-- Quote as a SQL string literal. shellescape() is the wrong tool: systemlist()
-- is given a list so no shell is involved, and SQL escapes quotes by doubling.
local function sql_literal(path)
  return "'" .. path:gsub("'", "''") .. "'"
end

local function render(buf, path, mode)
  local sql = QUERIES[mode]:format(sql_literal(path))
  local out = vim.fn.systemlist({ "duckdb", "-box", "-c", sql })
  if vim.v.shell_error ~= 0 then
    out = vim.list_extend({ ("duckdb failed (%s):"):format(mode), "" }, out)
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  vim.bo[buf].modifiable = false
  vim.b[buf].parquet_mode = mode
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("parquet_preview", { clear = true }),
  pattern = "*.parquet",
  callback = function(args)
    local buf, path = args.buf, args.match

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "parquet"

    if vim.fn.executable("duckdb") == 0 then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "duckdb not found on PATH - required to preview parquet files.",
        "",
        "  macOS:  brew install duckdb",
        "  Arch:   pacman -S duckdb",
      })
      vim.bo[buf].modifiable = false
      return
    end

    render(buf, path, "data")

    for key, mode in pairs({ gd = "data", gs = "schema", gm = "stats" }) do
      vim.keymap.set("n", key, function()
        render(buf, path, mode)
      end, { buffer = buf, desc = "Parquet: " .. mode })
    end
  end,
})
