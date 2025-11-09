# tmux Configuration

- **Advanced tmux setup** with custom status line and key bindings
- **Plugin management** via TPM (Tmux Plugin Manager)
- **Session persistence** with tmux-resurrect plugin
- **Vim-style navigation** with intuitive pane switching
- **Custom prefix** (Ctrl-a instead of Ctrl-b)
- **Mouse support** and modern terminal features
- **F12 remote mode** for nested tmux sessions
- **Smart SSH detection** with different status colors for remote sessions
- **Complete keymaps reference**: See [tmux/KEYMAPS.md](tmux/KEYMAPS.md)

## Tmux Auto-Launch Configuration

To automatically start/connect to a tmux session called "main" every time you open a terminal, add one of the following to your shell configuration:

### For Zsh users (add to `~/.zshrc`):
```bash
# Auto-start tmux session "main" if not already in tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    tmux has-session -t main 2>/dev/null || tmux new-session -d -s main
    exec tmux attach-session -t main
fi
```

### For Bash users (add to `~/.bashrc`):
```bash
# Auto-start tmux session "main" if not already in tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    tmux has-session -t main 2>/dev/null || tmux new-session -d -s main
    exec tmux attach-session -t main
fi
```

### How It Works
- **Smart Detection**: Only activates in interactive shells, not in tmux sessions
- **Session Persistence**: Creates "main" session if it doesn't exist, connects if it does
- **Multiple Terminals**: All new terminal windows connect to the same tmux session
- **Safe**: Won't create nested tmux sessions or interfere with existing workflows

After adding this configuration:
1. **Reload your shell**: `source ~/.zshrc` or `source ~/.bashrc`
2. **Open a new terminal**: Will automatically connect to tmux "main" session
3. **Persistent workspace**: Your tmux session survives terminal restarts

### Tmux Plugin Management

The tmux configuration includes TPM (Tmux Plugin Manager) for easy plugin management:

**Install plugins**: `Ctrl-a + I` (after starting tmux)
**Update plugins**: `Ctrl-a + U`
**Uninstall plugins**: `Ctrl-a + Alt-u`

**Included plugins**:
- **tmux-resurrect**: Save/restore tmux sessions (`Ctrl-a + S` to save, `Ctrl-a + R` to restore)

**Key bindings**:
- **Prefix**: `Ctrl-a` (instead of default `Ctrl-b`)
- **Split panes**: `Ctrl-a + |` (vertical), `Ctrl-a + -` (horizontal)
- **Navigate panes**: `Ctrl-a + Ctrl-h/j/k/l`
- **Navigate windows**: `Ctrl-a + h/l` (vim-style left/right)
- **Resize panes**: `Ctrl-a + Ctrl-i/u/y/o`
- **Link window**: `Ctrl-a + w` (link from another session)
- **Remote mode**: `F12` (disable local tmux for nested sessions)

For complete tmux keymaps reference, see **[tmux/KEYMAPS.md](tmux/KEYMAPS.md)**.