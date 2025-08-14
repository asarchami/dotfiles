# Tmux Keymaps Reference

A comprehensive reference for all tmux key bindings configured in this dotfiles setup.

## Prefix Key

**Prefix**: `Ctrl-a` (instead of default `Ctrl-b`)

All tmux commands start with the prefix key `Ctrl-a`, followed by the command key.

## Core Navigation & Management

### Session Management
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + s` | Choose session/window | Visual tree for choosing sessions/windows |
| `Ctrl-a + N` | Rename session | Rename current session interactively |
| `Ctrl-a + Q` | Kill session | Kill current session (with confirmation) |

### Window Management
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + c` | Create window | Create new window (default tmux behavior) |
| `Ctrl-a + n` | Rename window | Rename current window interactively |
| `Ctrl-a + X` | Kill window | Kill current window |
| `Ctrl-a + Ctrl-x` | Kill other windows | Kill all other windows (with confirmation) |
| `Ctrl-a + h` | Previous window | Navigate to previous window |
| `Ctrl-a + l` | Next window | Navigate to next window |
| `Alt-H` | Move window left | Swap current window with previous |
| `Alt-L` | Move window right | Swap current window with next |
| `Ctrl-a + H` | Move window left | Swap current window with previous (with prefix) |
| `Ctrl-a + L` | Move window right | Swap current window with next (with prefix) |

### Pane Management
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + \|` | Split vertical | Split pane vertically (right) |
| `Ctrl-a + -` | Split horizontal | Split pane horizontally (down) |
| `Ctrl-a + x` | Kill pane | Kill current pane |
| `Ctrl-a + +` | Zoom pane | Toggle pane zoom (maximize/restore) |
| `Ctrl-a + y` | Sync panes | Toggle synchronized typing to all panes |

### Pane Navigation
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + Ctrl-h` | Navigate left | Select pane to the left |
| `Ctrl-a + Ctrl-j` | Navigate down | Select pane below |
| `Ctrl-a + Ctrl-k` | Navigate up | Select pane above |
| `Ctrl-a + Ctrl-l` | Navigate right | Select pane to the right |

### Pane Resizing
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + Ctrl-i` | Resize up | Resize pane up by 5 lines |
| `Ctrl-a + Ctrl-u` | Resize down | Resize pane down by 5 lines |
| `Ctrl-a + Ctrl-y` | Resize left | Resize pane left by 5 columns |
| `Ctrl-a + Ctrl-o` | Resize right | Resize pane right by 5 columns |

## Copy Mode & Selection

### Copy Mode
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + v` | Enter copy mode | Enter vi-style copy mode |
| `Ctrl-a + P` | Paste buffer | Paste from tmux buffer |

### Copy Mode Navigation (Vi-style)
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `v` | Begin selection | Start visual selection (in copy mode) |
| `y` | Copy selection | Copy selection to clipboard and exit copy mode |
| `h/j/k/l` | Navigate | Vi-style movement in copy mode |
| `Escape` | Exit copy mode | Exit copy mode without copying |

### Mouse Support
| Action | Result | Description |
|--------|--------|-------------|
| Mouse drag | Copy selection | Automatically copies to clipboard |
| Mouse click | Select pane | Click to focus pane |
| Mouse wheel | Scroll | Scroll through pane content |

## Configuration & Utilities

### Configuration Management
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + r` | Reload config | Reload tmux configuration file |

### Advanced Features
| Key Binding | Action | Description |
|-------------|--------|-------------|

## Plugin Management (TPM)

### Plugin Commands
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + I` | Install plugins | Install/update all plugins |
| `Ctrl-a + U` | Update plugins | Update all plugins |
| `Ctrl-a + Alt-u` | Uninstall plugins | Remove plugins not in config |

## Session Persistence (tmux-resurrect)

### Save/Restore Sessions
| Key Binding | Action | Description |
|-------------|--------|-------------|
| `Ctrl-a + S` | Save session | Save current tmux session state |
| `Ctrl-a + R` | Restore session | Restore previously saved session |

## Remote Work Support

### Terminal Features
The configuration includes:
- **True color support**: Enhanced color rendering with RGB
- **Improved responsiveness**: Faster escape time for vim compatibility  
- **System clipboard integration**: Seamless copy/paste

## Status Line Features

The custom status line displays:
- **Left side**: Host, session name, prefix indicator, zoom indicator
- **Right side**: Date and time
- **Color changes**: Different colors for local vs remote sessions
- **Visual indicators**: Shows when prefix is active or pane is zoomed

## Mouse Integration

Mouse support is enabled for:
- **Pane selection**: Click to focus
- **Pane resizing**: Drag borders
- **Copy selection**: Click and drag to select text
- **Scrolling**: Mouse wheel for history

## Custom Features

### Enhanced Navigation
- **Vi-style keys**: Use hjkl for pane navigation
- **Smart window swapping**: Move windows left/right easily
- **Session tree view**: Visual chooser for sessions and windows

### Improved Splitting
- **Current path awareness**: New panes open in current directory
- **Intuitive keys**: `|` for vertical, `-` for horizontal splits
- **Quick access**: No need to remember quotes and percentages

### Session Management
- **Interactive renaming**: Easy session and window renaming
- **Safe killing**: Confirmation prompts for destructive actions
- **Visual chooser**: Tree view for navigating sessions and windows
- **Synchronized panes**: Type to multiple panes simultaneously

## Integration with Other Tools

### Neovim Integration
This tmux configuration is designed to work seamlessly with the Neovim setup:
- **Shared navigation**: Same hjkl keys work in both
- **Color consistency**: Matching status line themes
- **Clipboard sharing**: Copy/paste works across tools

### Terminal Integration
- **Alacritty keybindings**: Terminal shortcuts that complement tmux
- **Shell integration**: Works with auto-launch scripts
- **Plugin ecosystem**: TPM for extending functionality

## Tips & Workflows

### Daily Usage
1. **Start with auto-launch**: Configure shell to auto-start tmux "main" session
2. **Use window tabs**: Organize projects in separate windows
3. **Split for context**: Use panes for related tasks (editor, terminal, logs)
4. **Save sessions**: Use `Ctrl-a + S` to persist your workspace

### Remote Development
1. **Color indicators**: Different status bar colors for local vs SSH sessions
2. **Nested sessions**: Run tmux inside tmux for complex workflows  
3. **Session sharing**: Multiple users can attach to same session

### Project Organization
1. **Window per project**: Each project gets its own window
2. **Consistent layouts**: Use tmux-resurrect to save project layouts
3. **Quick switching**: Ctrl-a + h/l for rapid window navigation

## Troubleshooting

### Common Issues
- **Copy not working**: Ensure system clipboard tools are installed
- **Plugins not loading**: Run `Ctrl-a + I` to install plugins
- **Status line broken**: Check color variable definitions
- **Colors not working**: Verify terminal supports true color

### Debugging
- **Show key bindings**: `tmux list-keys`
- **Check config**: `tmux show-options -g`
- **View plugins**: `ls ~/.config/tmux/plugins/`

For more details about the tmux configuration, see the main [README.md](../README.md).
