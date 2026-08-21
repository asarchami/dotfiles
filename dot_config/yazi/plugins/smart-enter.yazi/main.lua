--- @since 25.5.31
--- @sync entry

-- Enter directories instead of "opening" them.
--
-- yazi.nvim launches yazi with --chooser-file. In chooser mode `open` writes
-- the hovered path and exits, and it does that for directories too; yazi.nvim's
-- default opener then runs :edit on the result, dropping you into a directory
-- buffer in Neovim. (Its split/tab openers guard with isdirectory(); the plain
-- one does not.)
--
-- Dispatching to `enter` for directories means they are never emitted at all,
-- so there is nothing for the integration to misinterpret. Standalone yazi
-- behaves the same as before.
return {
  entry = function()
    local h = cx.active.current.hovered
    ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
  end,
}
