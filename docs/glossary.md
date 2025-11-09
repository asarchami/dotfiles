# Glossary of Files

This document provides a glossary of the files in this dotfiles repository.

## Root Directory

-   `.gitignore`: Specifies intentionally untracked files to ignore.
-   `install_nvim_deps.sh`: Installation script for Neovim dependencies.
-   `install_tmux_deps.sh`: Installation script for tmux dependencies.
-   `install.sh`: Main installation script for the dotfiles.
-   `README.md`: The main README file for the project.

## `docs` Directory

-   `HYPR.md`: Documentation for Hyprland configuration.
-   `KEYMAPS.md`: Documentation for key mappings.
-   `TMUX_KEYMAPS.md`: Documentation for tmux key mappings.
-   `alacritty.md`: Documentation for Alacritty configuration.
-   `hyprland.md`: Documentation for Hyprland configuration.
-   `neovim.md`: Documentation for Neovim configuration.
-   `pgcli.md`: Documentation for pgcli configuration.
-   `tmux.md`: Documentation for tmux configuration.
-   `waybar.md`: Documentation for Waybar configuration.

## `dot_config` Directory

### `alacritty`

-   `alacritty.toml.tmpl`: Alacritty terminal emulator configuration template.

### `hypr`

-   `animations.conf`: Configuration for Hyprland animations.
-   `autostart.conf`: Configuration for applications to autostart with Hyprland.
-   `environment.conf`: Configuration for environment variables in Hyprland.
-   `foot.ini`: Configuration for the foot terminal emulator.
-   `foot.ini.chezmoi.yaml`: chezmoi configuration for the foot terminal emulator.
-   `hypridle.conf`: Configuration for the Hyprland idle daemon.
-   `hyprland.conf`: Main configuration file for the Hyprland window manager.
-   `hyprlock.conf`: Configuration for the Hyprland screen locker.
-   `keybinds.conf`: Configuration for key bindings in Hyprland.
-   `monitors.conf`: Configuration for monitor setup in Hyprland.
-   `settings.conf`: General settings for Hyprland.
-   `variables.conf`: Variables for Hyprland configuration.
-   `window-rules.conf`: Rules for window management in Hyprland.
-   `scripts/confirm_exit.sh`: Script to confirm exiting Hyprland.
-   `scripts/toggle_monitor.sh`: Script to toggle between monitors.
-   `scripts/workspace_action.sh`: Script for workspace actions in Hyprland.

### `nvim`

-   `init.lua`: Entry point for Neovim configuration.
-   `lua/config/init.lua`: Initialization for configuration.
-   `lua/config/keymaps.lua`: Key mappings for Neovim.
-   `lua/config/options.lua`: Options for Neovim.
-   `lua/plugins/colorscheme.lua`: Configuration for the colorscheme.
-   `lua/plugins/completion.lua`: Configuration for code completion.
-   `lua/plugins/dap.lua`: Configuration for the Debug Adapter Protocol.
-   `lua/plugins/git.lua`: Configuration for Git integration.
-   `lua/plugins/go.lua`: Configuration for Go development.
-   `lua/plugins/init.lua`: Initialization for plugins.
-   `lua/plugins/mason.lua`: Configuration for Mason.
-   `lua/plugins/noice.lua`: Configuration for the Noice UI plugin.
-   `lua/plugins/python.lua`: Configuration for Python development.
-   `lua/plugins/surround.lua`: Configuration for the surround plugin.
-   `lua/plugins/telescope.lua`: Configuration for the Telescope plugin.
-   `lua/plugins/treesitter.lua`: Configuration for the Treesitter plugin.
-   `lua/plugins/which-key.lua`: Configuration for the Which-Key plugin.

### `pgcli`

-   `config`: Configuration for pgcli.

### `tmux`

-   `tmux.conf`: Configuration for tmux.

### `waybar`

-   `config.jsonc`: Configuration for the Waybar status bar.
-   `style.css`: Stylesheet for Waybar.
-   `scripts/bat-pp.sh`: Script for battery percentage in Waybar.
-   `scripts/lock.sh`: Script for locking the screen from Waybar.
-   `scripts/nvidia.sh`: Script for NVIDIA GPU information in Waybar.
-   `scripts/pacman.sh`: Script for Pacman updates in Waybar.
