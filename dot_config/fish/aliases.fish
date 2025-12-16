# Aliases
abbr g git
abbr gst 'git status'
abbr ga 'git add'
abbr gaa 'git add --all'
abbr gc 'git commit -v'
abbr gcm 'git commit -m'
abbr gco 'git checkout'
abbr gb 'git branch'
abbr gp 'git push'
abbr gl 'git pull'
abbr gd 'git diff'
abbr glog 'git log --oneline --decorate --graph'
abbr c clear
abbr vim nvim

# eza aliases (modern ls replacement)
if command -v eza > /dev/null
    alias ls 'eza --icons'
    alias ll 'eza --long --icons'
    alias la 'eza --all --icons'
    alias lla 'eza --long --all --icons'
    alias lt 'eza --tree --icons'
    alias lta 'eza --tree --all --icons'
    alias ltl 'eza --tree --long --icons'
end

# Common directory navigation aliases
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .... 'cd ../../..'

# File operations
abbr cp 'cp -i'
abbr mv 'mv -i'
abbr rm 'rm -i'

# System aliases
abbr df 'df -h'
abbr du 'du -h'
abbr free 'free -h'
abbr ps 'ps aux'
abbr grep 'grep --color=auto'