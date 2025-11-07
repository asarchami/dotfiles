local plugins = {}

vim.list_extend(plugins, require("plugins.colorscheme"))
vim.list_extend(plugins, require("plugins.treesitter"))
vim.list_extend(plugins, require("plugins.mason"))
vim.list_extend(plugins, require("plugins.completion"))
vim.list_extend(plugins, require("plugins.python"))
vim.list_extend(plugins, require("plugins.go"))
vim.list_extend(plugins, require("plugins.dap"))
vim.list_extend(plugins, require("plugins.telescope"))
vim.list_extend(plugins, require("plugins.git"))
vim.list_extend(plugins, require("plugins.which-key"))
vim.list_extend(plugins, require("plugins.noice"))
vim.list_extend(plugins, require("plugins.surround"))

return plugins
