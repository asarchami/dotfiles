-- Query input as a floating scratch buffer rather than vim.ui.input: a single
-- line prompt cannot hold a multi-statement or wrapped query, and this is the
-- same "editable float, submit to run" shape as dadbod-ui's query buffer.

local M = {}

--- Open a floating SQL editor seeded with the last query run in this buffer.
--- <CR> submits; q/<Esc> cancels; <C-p>/<C-n> step through this file's query
--- history (older/newer) -- same convention Telescope's prompt uses, so it
--- overrides insert-mode completion on those keys rather than colliding with it.
--- @param buf integer
--- @param on_submit fun(sql: string)
function M.query(buf, on_submit)
  local history = vim.b[buf].dataview_history or {}
  local default = vim.b[buf].dataview_sql or "SELECT * FROM t"
  local lines = vim.split(default, "\n", { trimempty = true })

  local qbuf = vim.api.nvim_create_buf(false, true)
  vim.bo[qbuf].filetype = "sql"
  vim.bo[qbuf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(qbuf, 0, -1, false, lines)

  local width = math.min(math.floor(vim.o.columns * 0.6), 100)
  local height = math.min(math.max(#lines + 2, 6), 20)
  local win = vim.api.nvim_open_win(qbuf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Dataview Query (table: t) ",
    title_pos = "center",
    footer = " <CR> run   q/<Esc> cancel   <C-p>/<C-n> history ",
    footer_pos = "center",
    style = "minimal",
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function submit()
    local sql = table.concat(vim.api.nvim_buf_get_lines(qbuf, 0, -1, false), "\n")
    close()
    if sql:match("%S") then
      on_submit(sql)
    end
  end

  -- nil while editing the live draft; an index into `history` while browsing.
  local hist_idx = nil

  local function show(text)
    vim.api.nvim_buf_set_lines(qbuf, 0, -1, false, vim.split(text, "\n", { trimempty = true }))
    vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(qbuf), 0 })
  end

  local function older()
    if #history == 0 then
      return
    end
    hist_idx = math.max(1, (hist_idx or #history + 1) - 1)
    show(history[hist_idx])
  end

  local function newer()
    if not hist_idx then
      return
    end
    hist_idx = hist_idx + 1
    if hist_idx > #history then
      hist_idx = nil
      show(default)
    else
      show(history[hist_idx])
    end
  end

  local opts = { buffer = qbuf, silent = true }
  for _, mode in ipairs({ "n", "i" }) do
    vim.keymap.set(mode, "<C-p>", older, opts)
    vim.keymap.set(mode, "<C-n>", newer, opts)
  end
  vim.keymap.set("n", "<CR>", submit, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)

  vim.cmd("normal! G$")
  vim.cmd("startinsert!")
end

return M
