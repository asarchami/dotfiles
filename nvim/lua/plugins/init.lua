-- Load all plugin modules in priority order
-- Essential plugins first, then language-specific, then UI enhancements
local plugins = {}

-- Core functionality (highest priority)
vim.list_extend(plugins, require("plugins.colorscheme"))   -- 1. Colors first for UI
vim.list_extend(plugins, require("plugins.treesitter"))    -- 2. Syntax highlighting
vim.list_extend(plugins, require("plugins.mason"))         -- 3. LSP/tool installer
vim.list_extend(plugins, require("plugins.completion"))    -- 4. Autocompletion

-- Language support (medium priority)
vim.list_extend(plugins, require("plugins.python"))        -- 5. Python tools
vim.list_extend(plugins, require("plugins.go"))            -- 6. Go tools
vim.list_extend(plugins, require("plugins.dap"))           -- 7. Debugging

-- Navigation and productivity (medium priority)
vim.list_extend(plugins, require("plugins.telescope"))     -- 8. Fuzzy finder
vim.list_extend(plugins, require("plugins.git"))           -- 9. Git integration

-- UI enhancements (lower priority - can be loaded last)
vim.list_extend(plugins, require("plugins.bufferline"))    -- 10. Buffer tabs
vim.list_extend(plugins, require("plugins.which-key"))     -- 11. Key hints
vim.list_extend(plugins, require("plugins.noice"))         -- 12. UI improvements

return plugins
