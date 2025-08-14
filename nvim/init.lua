
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

-- Detect if running on a remote machine (SSH session)
local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION")

-- Base configuration for Lazy.nvim
local lazy_config = {
  -- UI configuration
  ui = {
    -- Show progress for downloads
    size = { width = 0.8, height = 0.8 },
    wrap = true,
  },
  
  -- Performance optimizations (always enabled)
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
    notify = false,   -- Don't show notifications
    frequency = 3600, -- Check every hour when enabled
  },
  
  -- Change detection (disable for better performance)
  change_detection = {
    enabled = false,
    notify = false,
  },
}

-- Apply remote-specific optimizations if running over SSH
if is_remote then
  -- Performance settings for remote systems
  lazy_config.concurrency = 2  -- Limit concurrent downloads (default is 8)
  
  -- Reduce UI refresh rate to lower resource usage
  lazy_config.ui.throttle = 100  -- milliseconds between updates (default is 20)
  
  -- Git configuration for better reliability on remote systems
  lazy_config.git = {
    -- Reduce timeout for git operations
    timeout = 300,  -- 5 minutes (default is 120)
    
    -- Use shallow clones for faster downloads
    clone_timeout = 120,  -- 2 minutes for cloning
    
    -- Throttle git operations
    throttle = {
      enabled = true,
      -- Minimum time between git operations
      rate = 1,  -- operations per second (default is no limit)
      -- Maximum concurrent git operations
      duration = 1000,  -- milliseconds
    },
  }
  
  -- Additional remote optimizations
  lazy_config.checker.concurrency = 1  -- Only check one plugin at a time when enabled
end

-- Load plugins from lua/plugins/init.lua
require("lazy").setup(require("plugins.init"), lazy_config)
