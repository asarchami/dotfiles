# Dotfiles Configuration

This repository contains a comprehensive, modular dotfiles setup for various applications, managed by [chezmoi](https://www.chezmoi.io/).

## Overview

This setup is designed to be modular and easy to manage. Each application's configuration is documented in its own file, providing a clear and organized structure. The configurations are optimized for a development workflow, with a focus on performance and usability.

## Applications

The following applications are configured in this repository:

-   [Alacritty](./docs/alacritty.md)
-   [Hyprland](./docs/hyprland.md)
-   [Neovim](./docs/neovim.md)
-   [pgcli](./docs/pgcli.md)
-   [tmux](./docs/tmux.md)
-   [Waybar](./docs/waybar.md)

For a detailed list of all configuration files and their purposes, please see the [Glossary of Files](./docs/glossary.md).

## Installation

This entire dotfiles configuration is managed by [chezmoi](https://www.chezmoi.io/), a powerful and flexible dotfile manager that helps you manage your dotfiles across multiple machines.

### Prerequisites

-   `git`
-   [Homebrew](https://brew.sh/) (for package management)
-   `chezmoi` (will be installed by the setup script)

### Installation Steps

To get started, run the following command in your terminal. It will download and run the installation script, which will:

1.  Install Homebrew (if not already installed).
2.  Install `chezmoi` (if not already installed).
3.  Clone this dotfiles repository to `~/.local/share/chezmoi`.
4.  Initialize `chezmoi`.

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asarchami/dotfiles/chezmoi/install.sh)"
```

After the script completes, your dotfiles will be ready to manage with `chezmoi`. You can then apply the configurations you want. For example:

```sh
# Apply all dotfiles
chezmoi apply

# Apply only the tmux configuration
chezmoi apply ~/.config/tmux
```

### Conditional Configuration Application

This dotfiles repository includes configurations for multiple operating systems and applications. Configurations are automatically applied only when relevant:

**Automatic OS-based filtering:**
- Linux-specific configs (Hyprland, Waybar, Wofi, Foot) are automatically ignored on macOS
- This is handled via `.chezmoiignore` templates in the root directory

**Automatic software detection:**
- Each module directory (hypr, waybar, wofi, foot, yazi) contains a `.chezmoiignore` file
- These files use chezmoi templates with `lookPath` to check if the software is installed
- If the software is not installed, the entire module directory is ignored
- No manual steps needed - just run `chezmoi apply` and it will only apply configs for installed software

### Updating Your Dotfiles

To get the latest changes from this repository, simply run:

```sh
git pull
chezmoi apply
```

The `chezmoi apply` command ensures that your dotfiles are in the correct state and applies any new changes.

## Why chezmoi?

`chezmoi` is used to manage these dotfiles for several key reasons:

-   **Declarative Management**: Define the desired state of your dotfiles, and `chezmoi` makes it so.
-   **Idempotent**: Apply your dotfiles multiple times without unexpected side effects.
-   **Cross-Platform**: Works seamlessly across different operating systems (Linux, macOS).
-   **Templating**: Use Go templates to customize dotfiles for different machines or environments.
-   **Security**: Manage sensitive information securely with integration with password managers.
-   **Simplicity**: Keeps your dotfiles organized and easy to deploy.