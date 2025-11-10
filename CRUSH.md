# CRUSH.md - Agent Instructions for Dotfiles Repository

This document provides essential information for AI agents working within this dotfiles repository.

## Project Overview

This is a dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). It contains modular configurations for various applications, optimized for a development workflow across Linux and macOS. The primary goal is to maintain a consistent and easily deployable personal development environment.

## Key Tools and Technologies

*   **chezmoi**: The declarative dotfile manager used to manage and deploy configurations.
*   **git**: For version control of the dotfiles.
*   **Homebrew (Linuxbrew)**: Used for package management to install necessary tools like `chezmoi`, `direnv`, and `git`.
*   **direnv**: Manages environment variables per directory.

## Essential Commands

The core commands for interacting with this repository revolve around `chezmoi` and `git`.

### Installation

The initial setup is handled by the `install.sh` script. This script performs the following actions:
1.  Installs Homebrew (if not already installed).
2.  Installs `chezmoi` (if not already installed).
3.  Installs `direnv` (if not already installed).
4.  Installs `git` (if not already installed).
5.  Clones this dotfiles repository to `~/.local/share/chezmoi`.
6.  Initializes `chezmoi`.

To run the installation script:
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asarchami/dotfiles/chezmoi/install.sh)"
```

### Applying Dotfiles

To apply the dotfiles managed by chezmoi:
*   **Apply all dotfiles**:
    ```sh
    chezmoi apply
    ```
*   **Apply a specific application's dotfiles**:
    ```sh
    chezmoi apply ~/.config/APP_NAME
    ```
    (Replace `APP_NAME` with the actual application directory, e.g., `tmux`, `nvim`, `alacritty`).

### Updating Dotfiles

To get the latest changes from the repository and apply them:
```sh
git pull
chezmoi apply
```

### Other Useful `chezmoi` Commands

*   `chezmoi diff`: Show the differences between the target state and the source state.
*   `chezmoi edit APP_NAME`: Edit the source dotfile for a specific application.
*   `chezmoi add PATH`: Add a new dotfile to the source state.

## Code Organization and Structure

The repository has a clear structure:

*   **`dot_config/`**: This directory holds the source dotfiles that `chezmoi` manages. Each application's configuration is typically found in its own subdirectory (e.g., `dot_config/nvim`, `dot_config/tmux`).
*   **`docs/`**: Contains documentation files, including specific application configurations (e.g., `docs/alacritty.md`, `docs/hyprland.md`) and a `glossary.md` for a detailed list of configuration files.
*   **`install.sh`**: The main script for bootstrapping the dotfiles setup.
*   **`README.md`**: Provides a high-level overview and initial installation instructions.

## Naming Conventions and Style Patterns

*   **File Naming**: Dotfiles within `dot_config/` generally reflect the actual path they will be deployed to, often using `.` prefixes for hidden files (e.g., `dot_bashrc` for `.bashrc`).
*   **Application-Specific Configuration**: Configurations are grouped by application in their respective directories within `dot_config/`.

## Testing Approach and Patterns

Given this is a dotfiles repository, formal unit/integration testing frameworks are not typically used. The "testing" primarily involves:

*   **`chezmoi diff`**: Used to preview changes before applying them, ensuring the desired state matches expectations.
*   **Manual Verification**: After `chezmoi apply`, manually checking that applications behave as configured.
*   **Idempotency**: `chezmoi` ensures that applying configurations multiple times yields the same result without unintended side effects.

## Important Gotchas or Non-Obvious Patterns

*   **chezmoi Templating**: `chezmoi` supports Go templating. Many dotfiles might contain `{{ .os }}` or `{{ if .isWorkPC }}` like constructs for conditional configuration based on the operating system or custom variables. When modifying these files, be aware of the templating syntax and how it affects the final deployed file.
*   **Cross-Platform Considerations**: The setup aims for cross-platform compatibility (Linux/macOS), particularly in `install.sh` and potentially within some templated dotfiles. Changes should ideally maintain this compatibility.
*   **Shell Integration**: The `install.sh` script attempts to configure Homebrew for `bash`, `zsh`, and `fish` shells. If working with shell configurations, ensure changes are compatible with these environments.
*   **Idempotency**: Always consider the idempotent nature of `chezmoi` commands. Changes should be designed so that `chezmoi apply` can be run repeatedly without issues.
*   **Path Management**: Be mindful of absolute and relative paths within dotfiles, especially when dealing with executables installed via Homebrew or other package managers.
