# Fish shell configuration

# Set default editor
set -x EDITOR nvim

# Set default browser
set -x BROWSER firefox

# Path to Oh My Fish install.
set -q OMF_PATH; or set -x OMF_PATH "$HOME/.local/share/omf"

# Customize the prompt
function fish_prompt
    set_color green
    echo -n (prompt_pwd)
    set_color normal
    echo -n " "
    set_color blue
    echo -n "\$ "
    set_color normal
end

# Aliases
abbr g git
abbr gs 'git status'
abbr ga 'git add'
abbr gc 'git commit -m'
abbr gp 'git push'
abbr gl 'git pull'
abbr gd 'git diff'
abbr c clear
alias vim nvim

# direnv
direnv hook fish | source

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


