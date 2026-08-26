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
  csv = { reader = "read_csv_auto" },
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

local function gdb_dir(path)
  local dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.fnamemodify(dir, ":e"):lower() == "gdb" then
    return dir
  end
end

local gdb_cache = {}

local function gdb_to_gpkg(dir)
  if gdb_cache[dir] then
    return gdb_cache[dir]
  end
  if vim.fn.executable("ogr2ogr") == 0 then
    return nil, { "dataview: ogr2ogr not found on PATH -- required to read this geodatabase." }
  end

  local tmp = vim.fn.tempname() .. ".gpkg"
  local res = vim.system({ "ogr2ogr", "-f", "GPKG", tmp, dir }, { text = true }):wait()
  if res.code ~= 0 then
    return nil, vim.split(res.stderr or "ogr2ogr: conversion failed", "\n", { trimempty = true })
  end

  gdb_cache[dir] = tmp
  return tmp
end

function M.patterns()
  local patterns = vim.tbl_map(function(ext)
    return "*." .. ext
  end, vim.tbl_keys(M.formats))
  table.insert(patterns, "*.gdb/*")
  return patterns
end

--- Run `sql` against `path`, with the file bound to the view `t`.
--- @return boolean ok, string[] lines
function M.run(path, sql)
  local fmt, bind_path = spatial, path
  local dir = gdb_dir(path)

  if dir then
    local gpkg, err = gdb_to_gpkg(dir)
    if not gpkg then
      return false, err
    end
    bind_path = gpkg
  else
    fmt = M.formats[vim.fn.fnamemodify(path, ":e"):lower()]
    if not fmt then
      return false, { "dataview: no duckdb reader registered for this extension" }
    end
  end

  local prelude = table.concat({
    fmt.prelude or "",
    ("CREATE VIEW t AS SELECT * FROM %s(%s);"):format(fmt.reader, sql_literal(bind_path)),
  }, " ")

  local res = vim.system({ "duckdb", "-box", "-c", prelude .. " " .. sql }, { text = true }):wait()

  -- duckdb reports query errors on stderr with an empty stdout, so rendering
  -- stdout alone would leave a blank buffer with no explanation.
  local body = res.code == 0 and res.stdout or res.stderr
  return res.code == 0, vim.split(body or "", "\n", { trimempty = true })
end

return M
