# Fish shell configuration

# Disable welcome message
set -g fish_greeting

# Set default editor
set -x EDITOR nvim

# Set default browser
set -x BROWSER firefox

# pyenv initialization
if command -v pyenv &> /dev/null
    pyenv init - | source
end

# Function to get the latest pyenv version
function _get_latest_pyenv_version
    # Get all installed versions, filter for typical Python version patterns, sort numerically, and take the last one
    pyenv versions --bare | \
        grep -E '^[0-9]' | \
        sort -V | \
        tail -n 1
end

# Set pyenv version dynamically
if command -v pyenv &> /dev/null
    set -x PYENV_VERSION (_get_latest_pyenv_version)
end

# Path to Oh My Fish install.
set -q OMF_PATH; or set -x OMF_PATH "$HOME/.local/share/omf"

# Initialize Oh My Fish
if test -f "$OMF_PATH/init.fish"
    source "$OMF_PATH/init.fish"
end

# Homebrew Setup
set -l brew_path
if test -f /home/linuxbrew/.linuxbrew/bin/brew # Linuxbrew
    set brew_path /home/linuxbrew/.linuxbrew/bin/brew
else if test -f /opt/homebrew/bin/brew # Apple Silicon
    set brew_path /opt/homebrew/bin/brew
else if test -f /usr/local/bin/brew # Intel Macs
    set brew_path /usr/local/bin/brew
end

if set -q brew_path
    eval ($brew_path shellenv)
end

# Customize the prompt
function fish_prompt
    set_color blue
    echo -n (string replace "$HOME" "~" (pwd))
    set_color normal

    # Git prompt
    if test -d .git; or git rev-parse --git-dir > /dev/null 2>&1
        echo -n " " # Always a space before git info

        # Check if there are any commits
        if git rev-parse --verify HEAD >/dev/null 2>&1
            # Git icon (red)
            set_color red
            echo -n ""

            # Branch name (red)
            set -l branch_name (git rev-parse --abbrev-ref HEAD 2>/dev/null)
            echo -n " $branch_name" # Space before branch name

            # Git status indicator
            if not git diff-index --quiet HEAD --
                # Dirty (red)
                set_color red
                echo -n " " # Space before dirty indicator
            else
                # Clean (green)
                set_color green
                echo -n " " # Space before clean indicator
            end
        else
            # No commits yet (red)
            set_color red
            echo -n "" # Git icon
            set -l branch_name (git symbolic-ref --short HEAD 2>/dev/null)
            if test -z "$branch_name"
                set branch_name "main" # Fallback if symbolic-ref fails (e.g., detached HEAD in empty repo)
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

    set_color blue
    echo -n " ➤ " # Prompt symbol
    set_color normal
end

# Source aliases
source "$HOME/.local/share/chezmoi/dot_config/fish/aliases.fish"

# direnv
if command -v direnv &> /dev/null
direnv hook fish | source
end

# chezmoi
if command -v chezmoi &> /dev/null
    chezmoi completion fish | source
end

# nvm
if test -d "$HOME/.nvm"
    source "$HOME/.nvm/nvm.sh"
end

# pnpm
if command -v pnpm &> /dev/null
    pnpm setup --shell fish | source
end

# starship prompt
if command -v starship &> /dev/null
    starship init fish | source
end

# thefuck
if command -v thefuck &> /dev/null
    eval (thefuck --alias)
end

# zoxide
if command -v zoxide &> /dev/null
    zoxide init fish | source
end

# fzf
if command -v fzf &> /dev/null
    fzf --fish | source
end

# Completions
# fzf_configure_bindings
# zoxide_configure_bindings

# Google Cloud SDK setup
if command -v gcloud &> /dev/null
    # Google Cloud SDK path setup
    if test -f "$HOME/.local/google-cloud-sdk/path.fish.inc"
        source "$HOME/.local/google-cloud-sdk/path.fish.inc"
    end
    
    # Google Cloud SDK completion for fish
    gcloud completion fish | source
    
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

