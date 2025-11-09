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

# lf icons
set -gx LF_ICONS "di=:fi=:ln=:or=:ex=:*.tar=:*.tgz=:*.arc=:*.arj=:*.taz=:*.lha=:*.lz4=:*.lzh=:*.lzma=:*.tlz=:*.txz=:*.tzo=:*.t7z=:*.zip=:*.z=:*.dz=:*.gz=:*.lrz=:*.lz=:*.lzo=:*.xz=:*.zst=:*.tzst=:*.bz2=:*.bz=:*.tbz=:*.tbz2=:*.tz=:*.deb=:*.rpm=:*.jar=:*.war=:*.ear=:*.sar=:*.rar=:*.alz=:*.ace=:*.zoo=:*.cpio=:*.7z=:*.rz=:*.cab=:*.wim=:*.swm=:*.dwm=:*.esd=:*.jpg=:*.jpeg=:*.mjpg=:*.mjpeg=:*.gif=:*.bmp=:*.pbm=:*.pgm=:*.ppm=:*.tga=:*.xbm=:*.xpm=:*.tif=:*.tiff=:*.png=:*.svg=:*.svgz=:*.mng=:*.pcx=:*.mov=:*.mpg=:*.mpeg=:*.m2v=:*.mkv=:*.webm=:*.ogm=:*.mp4=:*.m4v=:*.mp4v=:*.vob=:*.qt=:*.nuv=:*.wmv=:*.asf=:*.rm=:*.rmvb=:*.flc=:*.avi=:*.fli=:*.flv=:*.gl=:*.dl=:*.xcf=:*.xwd=:*.yuv=:*.cgm=:*.emf=:*.ogv=:*.ogx=:*.aac=:*.au=:*.flac=:*.m4a=:*.mid=:*.midi=:*.mka=:*.mp3=:*.mpc=:*.ogg=:*.ra=:*.wav=:*.oga=:*.opus=:*.spx=:*.xspf=:*.pdf=:*.styl=:*.sass=:*.scss=:*.htm=:*.html=:*.slim=:*.haml=:*.ejs=:*.css=:*.less=:*.md=:*.mdx=:*.markdown=:*.rmd=:*.json=:*.webmanifest=:*.js=:*.mjs=:*.jsx=:*.rb=:*.gemspec=:*.rake=:*.php=:*.py=:*.pyc=:*.pyo=:*.pyd=:*.coffee=:*.mustache=:*.hbs=:*.conf=:*.ini=:*.yml=:*.yaml=:*.toml=:*.bat=:*.mk=:*.jpg=:*.jpeg=:*.bmp=:*.png=:*.webp=:*.gif=:*.ico=:*.twig=:*.cpp=:*.c++=:*.cxx=:*.cc=:*.cp=:*.c=:*.cs=󰌛:*.h=:*.hh=:*.hpp=:*.hxx=:*.hs=:*.lhs=:*.nix=:*.lua=:*.java=:*.sh=:*.fish=:*.bash=:*.zsh=:*.ksh=:*.csh=:*.awk=:*.ps1=:*.ml=λ:*.mli=λ:*.diff=:*.db=:*.sql=:*.dump=:*.clj=:*.cljc=:*.cljs=:*.edn=:*.scala=:*.go=:*.dart=:*.xul=:*.sln=:*.suo=:*.pl=:*.pm=:*.t=:*.rss=:*.f#=:*.fsscript=:*.fsx=:*.fs=:*.fsi=:*.rs=:*.rlib=:*.d=:*.erl=:*.hrl=:*.ex=:*.exs=:*.eex=:*.leex=:*.heex=:*.vim=:*.ai=:*.psd=:*.psb=:*.ts=:*.tsx=:*.jl=:*.pp=:*.vue=:*.elm=:*.swift=:*.xcplayground=:*.tex=󰙩:*.r=󰟔:*.rproj=󰗆:*.sol=󰡪:*.pem=:*gruntfile.coffee=:*gruntfile.js=:*gruntfile.ls=:*gulpfile.coffee=:*gulpfile.js=:*gulpfile.ls=:*mix.lock=:*dropbox=:*.ds_store=:*.gitconfig=:*.gitignore=:*.gitattributes=:*.gitlab-ci.yml=:*.bashrc=:*.zshrc=:*.zshenv=:*.zprofile=:*.vimrc=:*.gvimrc=:*_vimrc=:*_gvimrc=:*.bashprofile=:*favicon.ico=:*license=:*node_modules=:*react.jsx=:*procfile=:*dockerfile=:*docker-compose.yml=:*docker-compose.yaml=:*compose.yml=:*compose.yaml=:*rakefile=:*config.ru=:*gemfile=:*makefile=:*cmakelists.txt=:*robots.txt=󰚩:*Gruntfile.coffee=:*Gruntfile.js=:*Gruntfile.ls=:*Gulpfile.coffee=:*Gulpfile.js=:*Gulpfile.ls=:*Dropbox=:*.DS_Store=:*LICENSE=:*React.jsx=:*Procfile=:*Dockerfile=:*Docker-compose.yml=:*Docker-compose.yaml=:*Rakefile=:*Gemfile=:*Makefile=:*CMakeLists.txt=:*jquery.min.js=:*angular.min.js=:*backbone.min.js=:*require.min.js=:*materialize.min.js=:*materialize.min.css=:*mootools.min.js=:*vimrc=:Vagrantfile="
