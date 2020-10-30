# dotfiles

Autimatically install __vim__ and __tmux__ configfiles. 
Tmux config  are based on [This](https://github.com/samoshkin/tmux-config).


# Requirements
* node
* python3
* pynvim
* ag(silver search bar)

# Install
```
wget -O - https://raw.githubusercontent.com/asarchami/dotfiles/master/install.sh | bash
```
# Install node (required for coc):
```
curl -sL install-node.now.sh/lts | bash -s -- --prefix=$HOME/.local
```
