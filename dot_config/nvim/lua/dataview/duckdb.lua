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
local xlsx = {
  reader = "ST_Read",
  prelude = "LOAD spatial;",
  open_options = "open_options => ['HEADERS=FORCE']",
}

M.formats = {
  parquet = { reader = "read_parquet" },
  csv = { reader = "read_csv_auto" },
  gpkg = spatial,
  shp = spatial,
  geojson = spatial,
  fgb = spatial,
  kml = spatial,
  xlsx = xlsx,
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

--- Resolve `path` to a format and the actual path duckdb should read.
--- @return table|nil fmt, string|nil bind_path, string[]|nil err
local function resolve(path)
  local dir = gdb_dir(path)
  if dir then
    local gpkg, err = gdb_to_gpkg(dir)
    if not gpkg then
      return nil, nil, err
    end
    return spatial, gpkg
  end

  local fmt = M.formats[vim.fn.fnamemodify(path, ":e"):lower()]
  if not fmt then
    return nil, nil, { "dataview: no duckdb reader registered for this extension" }
  end
  return fmt, path
end

local function reader_call(fmt, bind_path, layer)
  local args = { sql_literal(bind_path) }
  if layer then
    table.insert(args, ("layer := %s"):format(sql_literal(layer)))
  end
  if fmt.open_options then
    table.insert(args, fmt.open_options)
  end
  return ("%s(%s)"):format(fmt.reader, table.concat(args, ", "))
end

function M.patterns()
  local patterns = vim.tbl_map(function(ext)
    return "*." .. ext
  end, vim.tbl_keys(M.formats))
  table.insert(patterns, "*.gdb/*")
  return patterns
end

--- List the layers/sheets/tables a source exposes, empty for formats with no
--- such concept (parquet, csv) or on any failure reading the metadata.
--- @return { name: string, feature_count: integer }[]
function M.layers(path)
  local fmt, bind_path = resolve(path)
  if not fmt or fmt.reader ~= "ST_Read" then
    return {}
  end

  local sql = fmt.prelude .. " SELECT UNNEST(layers) AS l FROM st_read_meta(" .. sql_literal(bind_path) .. ");"
  local res = vim.system({ "duckdb", "-json", "-c", sql }, { text = true }):wait()
  if res.code ~= 0 then
    return {}
  end

  local ok, rows = pcall(vim.json.decode, res.stdout or "")
  if not ok or type(rows) ~= "table" then
    return {}
  end

  return vim.tbl_map(function(row)
    return { name = row.l.name, feature_count = row.l.feature_count }
  end, rows)
end

--- Run `sql` against `path`, with the file bound to the view `t`.
--- @return boolean ok, string[] lines
function M.run(path, sql, layer)
  local fmt, bind_path, err = resolve(path)
  if not fmt then
    return false, err
  end

  local prelude = table.concat({
    fmt.prelude or "",
    ("CREATE VIEW t AS SELECT * FROM %s;"):format(reader_call(fmt, bind_path, layer)),
  }, " ")

  local res = vim.system({ "duckdb", "-box", "-c", prelude .. " " .. sql }, { text = true }):wait()

  -- duckdb reports query errors on stderr with an empty stdout, so rendering
  -- stdout alone would leave a blank buffer with no explanation.
  local body = res.code == 0 and res.stdout or res.stderr
  return res.code == 0, vim.split(body or "", "\n", { trimempty = true })
end

return M
