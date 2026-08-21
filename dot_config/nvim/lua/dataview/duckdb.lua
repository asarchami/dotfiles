-- Everything that knows about duckdb lives here: which formats map to which
-- reader function, how a file is bound to a queryable name, and how a query is
-- run. The rest of dataview only deals in buffers and keymaps.

local M = {}

-- Each entry binds a file to the view `t`, so every view and every user query
-- is written against one stable name regardless of format. Adding a format is
-- an entry here plus nothing else -- init.lua derives its autocmd patterns from
-- these keys.
-- ST_Read reaches GDAL, so one entry covers every vector format duckdb's
-- spatial extension can open. It needs `INSTALL spatial` once; until then
-- duckdb's own error tells the user exactly that.
local spatial = { reader = "ST_Read", prelude = "LOAD spatial;" }

M.formats = {
  parquet = { reader = "read_parquet" },
  gpkg = spatial,
  shp = spatial,
  geojson = spatial,
  fgb = spatial,
  kml = spatial,
}

-- Quote as a SQL string literal. shellescape() is the wrong tool: vim.system()
-- is given a list so no shell is involved, and SQL escapes quotes by doubling.
local function sql_literal(path)
  return "'" .. path:gsub("'", "''") .. "'"
end

function M.available()
  return vim.fn.executable("duckdb") == 1
end

function M.format_for(path)
  return M.formats[vim.fn.fnamemodify(path, ":e"):lower()]
end

function M.patterns()
  return vim.tbl_map(function(ext)
    return "*." .. ext
  end, vim.tbl_keys(M.formats))
end

--- Run `sql` against `path`, with the file bound to the view `t`.
--- @return boolean ok, string[] lines
function M.run(path, sql)
  local fmt = M.format_for(path)
  if not fmt then
    return false, { "dataview: no duckdb reader registered for this extension" }
  end

  local prelude = table.concat({
    fmt.prelude or "",
    ("CREATE VIEW t AS SELECT * FROM %s(%s);"):format(fmt.reader, sql_literal(path)),
  }, " ")

  local res = vim.system({ "duckdb", "-box", "-c", prelude .. " " .. sql }, { text = true }):wait()

  -- duckdb reports query errors on stderr with an empty stdout, so rendering
  -- stdout alone would leave a blank buffer with no explanation.
  local body = res.code == 0 and res.stdout or res.stderr
  return res.code == 0, vim.split(body or "", "\n", { trimempty = true })
end

return M
