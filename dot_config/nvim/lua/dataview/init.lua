-- Preview data files as text tables instead of raw bytes.
--
-- Formats like parquet are binary, so opening one normally dumps bytes into the
-- buffer. A BufReadCmd autocmd takes over the read and renders a duckdb table.
--
-- duckdb rather than a plugin: one binary that is useful outside Neovim anyway,
-- reads these formats natively, and since it is a query engine the built-in
-- views and ad-hoc SQL share a single code path.

local duckdb = require("dataview.duckdb")
local ui = require("dataview.ui")

local M = {}

M.config = {
  rows = 500,
  -- Buffer-local, so these shadow LazyVim's <leader>c* mappings only inside a
  -- preview buffer -- where code actions, rename and Mason have nothing to act
  -- on anyway.
  keys = {
    data = "<leader>cd",
    schema = "<leader>cs",
    stats = "<leader>cm",
    query = "<leader>cq",
    layer = "<leader>cl",
  },
}

-- schema and stats wrap DESCRIBE/SUMMARIZE rather than calling them directly:
-- for spatial sources duckdb reports a GEOMETRY column's type as the full
-- PROJJSON CRS definition, ~500 characters, which stretches the table far past
-- readable. Truncating there is harmless for non-spatial formats.
local function views()
  return {
    data = "SELECT * FROM t LIMIT " .. M.config.rows,
    schema = [[SELECT column_name, left(column_type, 30) AS column_type, "null" AS nullable ]]
      .. "FROM (DESCRIBE SELECT * FROM t)",
    stats = "SELECT * EXCLUDE (column_type) FROM (SUMMARIZE SELECT * FROM t)",
  }
end

local function write(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function choose_layer(layers, on_choice)
  vim.ui.select(layers, {
    prompt = "Select layer/sheet to view",
    format_item = function(layer)
      return ("%s (%d features)"):format(layer.name, layer.feature_count)
    end,
  }, on_choice)
end

local function render(buf, path, sql, label)
  local ok, lines = duckdb.run(path, sql, vim.b[buf].dataview_layer)
  -- which-key surfaces the mappings now, so the header only has to say which
  -- view you are looking at.
  local header = ("-- %s%s"):format(label, ok and "" or " [error]")

  write(buf, vim.list_extend({ header, "" }, lines))
  -- Only remember queries that ran, so gq does not seed a broken statement.
  if ok then
    vim.b[buf].dataview_sql = sql

    if label == "query" then
      local history = vim.b[buf].dataview_history or {}
      if history[#history] ~= sql then
        table.insert(history, sql)
        if #history > 50 then
          table.remove(history, 1)
        end
      end
      vim.b[buf].dataview_history = history
    end
  end
end

function M.open(buf, path)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "dataview"

  if not duckdb.available() then
    write(buf, {
      "duckdb not found on PATH - required to preview data files.",
      "",
      "  macOS:  brew install duckdb",
      "  Arch:   pacman -S duckdb",
    })
    return
  end

  local function run(sql, label)
    render(buf, path, sql, label)
  end

  for name, key in pairs(M.config.keys) do
    if name ~= "query" and name ~= "layer" then
      vim.keymap.set("n", key, function()
        run(views()[name], name)
      end, { buffer = buf, desc = "Dataview: " .. name })
    end
  end

  local function prompt()
    ui.query(buf, function(sql)
      run(sql, "query")
    end)
  end

  vim.keymap.set("n", M.config.keys.query, prompt, { buffer = buf, desc = "Dataview: query" })
  vim.api.nvim_buf_create_user_command(buf, "DataviewQuery", function(cmd)
    run(cmd.args, "query")
  end, { nargs = "+", desc = "Query this file (table: t)" })

  local function switch_layer()
    local layers = duckdb.layers(path)
    if #layers == 0 then
      vim.notify("Dataview: this format has no layers/sheets", vim.log.levels.INFO)
      return
    end
    if #layers == 1 then
      vim.notify("Dataview: only one layer (" .. layers[1].name .. ")", vim.log.levels.INFO)
      return
    end
    choose_layer(layers, function(choice)
      if not choice then
        return
      end
      vim.b[buf].dataview_layer = choice.name
      run(views().data, "data")
    end)
  end

  vim.keymap.set("n", M.config.keys.layer, switch_layer, { buffer = buf, desc = "Dataview: layer" })

  local layers = duckdb.layers(path)
  if #layers <= 1 then
    if layers[1] then
      vim.b[buf].dataview_layer = layers[1].name
    end
    run(views().data, "data")
    return
  end

  choose_layer(layers, function(choice)
    vim.b[buf].dataview_layer = (choice or layers[1]).name
    run(views().data, "data")
  end)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = vim.api.nvim_create_augroup("dataview", { clear = true }),
    pattern = duckdb.patterns(),
    callback = function(args)
      M.open(args.buf, args.match)
    end,
  })
end

return M
