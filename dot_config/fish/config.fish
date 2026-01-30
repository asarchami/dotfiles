# Fish shell configuration

# Disable welcome message
set -g fish_greeting

# Fish theme configuration (local or remote)
set -gx FISH_THEME local

# Set default editor
set -x EDITOR nvim

# Set default browser
set -x BROWSER firefox

# pyenv initialization
if command -v pyenv &>/dev/null
    pyenv init - | source
end

# Function to get the latest pyenv version
function _get_latest_pyenv_version
    # Get all installed versions, filter for typical Python version patterns, sort numerically, and take the last one
    pyenv versions --bare | grep -E '^[0-9]' | sort -V | tail -n 1
end

# Set pyenv version dynamically
if command -v pyenv &>/dev/null
    set -x PYENV_VERSION (_get_latest_pyenv_version)
end

# Path to Oh My Fish install.
set -q OMF_PATH; or set -x OMF_PATH "$HOME/.local/share/omf"

# Initialize Oh My Fish
if test -f "$OMF_PATH/init.fish"
    source "$OMF_PATH/init.fish"
end

# Homebrew Setup (cross-platform)
if command -v brew &>/dev/null
    eval (brew shellenv)
end

# Customize the prompt
function fish_prompt
    # Determine colors based on FISH_THEME
    set -l primary_color blue
    set -l accent_color red
    set -l hostname_color yellow
    if test "$FISH_THEME" = remote
        set primary_color magenta
        set accent_color cyan
        set hostname_color yellow
        # Show hostname at the beginning for remote theme
        set_color $hostname_color
        echo -n "($(hostname)) "
        set_color normal
    end

    set_color $primary_color
    echo -n (string replace "$HOME" "~" (pwd))
    set_color normal

    # Git prompt
    if test -d .git; or git rev-parse --git-dir >/dev/null 2>&1
        echo -n " " # Always a space before git info

        # Check if there are any commits
        if git rev-parse --verify HEAD >/dev/null 2>&1
            # Git icon
            set_color $accent_color
            echo -n ""

            # Branch name
            set -l branch_name (git rev-parse --abbrev-ref HEAD 2>/dev/null)
            echo -n " $branch_name" # Space before branch name

            # Git status indicator
            if not git diff-index --quiet HEAD --
                # Dirty
                set_color $accent_color
                echo -n " " # Space before dirty indicator
            else
                # Clean (green for both themes)
                set_color green
                echo -n " " # Space before clean indicator
            end
        else
            # No commits yet
            set_color $accent_color
            echo -n "" # Git icon
            set -l branch_name (git symbolic-ref --short HEAD 2>/dev/null)
            if test -z "$branch_name"
                set branch_name main # Fallback if symbolic-ref fails (e.g., detached HEAD in empty repo)
            end
            echo -n " $branch_name" # Branch name with a space
        end
        set_color normal # Reset color after git prompt
    end

    # Python virtual environment indicator
    if set -q VIRTUAL_ENV
        set_color brgreen # Bright green for venv name
        echo -n " " # Space before icon
        set_color normal
    end

    # Remote theme: show hostname with timestamp on the right
    if test "$FISH_THEME" = remote
        set -l current_time (date +%H:%M:%S)
        set -l hostname_str (hostname)
        echo "" # New line for better visibility
        set_color $primary_color
        echo -n "$current_time ($hostname_str)"
        set_color normal
    end

    set_color $primary_color
    echo -n " ➤ " # Prompt symbol
    set_color normal
end

function hyprshot-gui
    # Use 'env' to override PATH just for this execution
    env PATH="/usr/bin:/bin" /usr/bin/python3 /usr/bin/hyprshot-gui $argv
end

# Source aliases
source "$HOME/.local/share/chezmoi/dot_config/fish/aliases.fish"

# direnv
if command -v direnv &>/dev/null
    direnv hook fish | source
end

# chezmoi
if command -v chezmoi &>/dev/null
    chezmoi completion fish | source
end

# nvm
if test -d "$HOME/.nvm"
    source "$HOME/.nvm/nvm.sh"
end

# pnpm
if command -v pnpm &>/dev/null
    pnpm setup --shell fish | source
end

# starship prompt
if command -v starship &>/dev/null
    starship init fish | source
end

# thefuck
if command -v thefuck &>/dev/null
    eval (thefuck --alias)
end

# zoxide
if command -v zoxide &>/dev/null
    zoxide init fish | source
end

# fzf
if command -v fzf &>/dev/null
    fzf --fish | source
end

# Completions
# fzf_configure_bindings
# zoxide_configure_bindings

# Google Cloud SDK setup
# Source path first to ensure gcloud is in PATH
if test -f "$HOME/.local/google-cloud-sdk/path.fish.inc"
    source "$HOME/.local/google-cloud-sdk/path.fish.inc"
end

# Now check if gcloud is available and set up completion/aliases
if command -v gcloud &>/dev/null
    # Google Cloud SDK completion for fish (suppress errors if not supported)
    gcloud completion fish 2>/dev/null | source

    # gcloud auth alias
    function gauth
        gcloud auth login && gcloud auth application-default login
    end
end

# Add pixi to PATH
set -gx PATH "$HOME/.pixi/bin" $PATH

# Add local bin to PATH (Fish equivalent of ~/.local/bin/env)
if not contains "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

# Add Go bin to PATH
if not contains /home/ali/go/bin $PATH
    set -gx PATH /home/ali/go/bin $PATH
end
