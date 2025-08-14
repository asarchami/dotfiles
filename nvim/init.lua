
require("config.init")

-- Color setup is now handled in config/options.lua

-- Plugin manager bootstrap (lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from lua/plugins/init.lua with throttled downloads
require("lazy").setup(require("plugins.init"), {
  -- Performance settings for remote systems
  concurrency = 2,  -- Limit concurrent downloads (default is 8)
  
  -- UI configuration
  ui = {
    -- Reduce UI refresh rate to lower resource usage
    throttle = 100,  -- milliseconds between updates (default is 20)
    
    -- Show progress for downloads
    size = { width = 0.8, height = 0.8 },
    wrap = true,
  },
  
  -- Git configuration for better reliability
  git = {
    -- Reduce timeout for git operations
    timeout = 300,  -- 5 minutes (default is 120)
    
    -- Use shallow clones for faster downloads
    clone_timeout = 120,  -- 2 minutes for cloning
    
    -- Throttle git operations
    throttle = {
      enabled = true,
      -- Minimum time between git operations
      rate = 2,  -- operations per second (default is no limit)
      -- Maximum concurrent git operations
      duration = 1000,  -- milliseconds
    },
  },
  
  -- Performance optimizations
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      -- Add additional paths if needed
      paths = {},
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen", 
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  
  -- Installation configuration
  install = {
    -- Show installation progress
    missing = true,
    
    -- Use a colorscheme during installation
    colorscheme = { "tokyonight", "default" },
  },
  
  -- Checker configuration (for updates)
  checker = {
    enabled = false,  -- Disable automatic checking on startup
    concurrency = 1,  -- Only check one plugin at a time when enabled
    notify = false,   -- Don't show notifications
    frequency = 3600, -- Check every hour when enabled
  },
  
  -- Change detection (disable for better performance)
  change_detection = {
    enabled = false,
    notify = false,
  },
})
