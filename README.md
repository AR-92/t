# T - Terminal File Manager

A powerful modular terminal file manager with custom commands, bookmarks, history navigation, and visual styling using [Gum](https://github.com/charmbracelet/gum).

[![GitHub](https://img.shields.io/github/license/AR-92/t)](https://github.com/AR-92/t/blob/main/LICENSE)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/AR-92/t)](https://github.com/AR-92/t/releases)

## Features

- **Intuitive Navigation**: Arrow keys, filtering, and quick actions
- **File Operations**: Create, delete, rename, copy, and move files and directories
- **Preview**: View file contents without opening an external editor
- **Custom Commands**: Add your own frequently used commands for quick access
- **Bookmarks**: Save and quickly access your favorite directories
- **History**: Navigate through your directory browsing history
- **Search**: Find files by name or content
- **Logging**: All actions are logged for review
- **Modular Design**: Easy to maintain and extend

## Installation

### Prerequisites

- [Gum](https://github.com/charmbracelet/gum) - Terminal UI library
- [Neovim](https://neovim.io/) or your preferred editor (configurable)

### Install Gum

```bash
# macOS
brew install gum

# Debian/Ubuntu
sudo apt install gum

# Other systems: see https://github.com/charmbracelet/gum#installation
```

### Install T

```bash
# Clone the repository
git clone https://github.com/AR-92/t.git
cd t

# Make executable and copy to PATH
chmod +x t
sudo cp t /usr/local/bin/t
# OR copy to your local bin directory
cp t ~/bin/t
```

## Usage

```bash
t        # Start the TUI file manager
t -h     # Show help page
t -v     # Show version information
```

## Key Features

### File Navigation
- **Arrow Keys**: Navigate through files and directories
- **Enter**: Select a file or directory
- **Type**: Filter files in real-time
- **Parent Directory**: Quickly go to parent directory with `..`
- **Hidden Files**: Automatically shows hidden files and directories

### File Operations
- **Open/Edit**: Open files in editor or enter directories
- **Delete**: Remove files or directories (with confirmation)
- **Rename**: Rename files or directories
- **Copy/Move**: Copy files to clipboard or move with cut
- **Preview**: View file contents without opening editor
- **Properties**: Show detailed file/directory information

### Global Operations
- **Create**: Create new files or directories
- **Paste**: Paste clipboard contents
- **Bookmarks**: Add directories to bookmarks or view saved locations
- **History**: Navigate through directory history (← → keys)
- **Search**: Find files by name or content
- **Commands**: Execute custom shell commands

## Custom Commands

One of the most powerful features of T is the ability to create custom commands for frequently used operations.

### Adding Custom Commands

1. In the file operations menu, select **"➕ Add custom command"**
2. Enter a name for your command (e.g., "Git Status")
3. Enter the actual command to execute (e.g., "git status")

### Using Placeholders

Custom commands support placeholders for dynamic values:
- **`$FILE`**: Replaced with the selected file path
- **`$DIR`**: Replaced with the current directory path

Examples:
- `wc -l $FILE` - Count lines in selected file
- `ls -la $DIR` - List contents of current directory

### Managing Custom Commands

- **Rename**: Change the name of existing custom commands
- **Remove**: Delete custom commands you no longer need
- **Execute**: Run custom commands directly from the file menu

### Example Custom Commands

1. **Count Lines**: 
   - Name: "Count Lines"
   - Command: `wc -l $FILE`

2. **Git Status**:
   - Name: "Git Status"
   - Command: `git status`

3. **List Directory**:
   - Name: "List Directory"
   - Command: `ls -la $DIR`

4. **Make Executable**:
   - Name: "Make Executable"
   - Command: `chmod +x $FILE`

## Keyboard Shortcuts

### Navigation
| Key | Action |
|-----|--------|
| ↑/↓ | Navigate through files |
| Enter | Select file/directory |
| ←/→ | History navigation |
| Type | Filter files |
| Esc | Return to file list |
| H | Quick history menu |
| G | Global operations menu |

### Quick Actions
| Key | Action |
|-----|--------|
| O | Open file/directory |
| D | Delete file/directory |
| R | Rename file/directory |
| C | Copy to clipboard |
| V | Cut to clipboard |
| P | Preview file |
| B | Back to file list |
| Q | Quit |

## Configuration Files

T stores user data in the following files:
- **`~/.tui_bookmarks`**: Saved bookmarked directories
- **`~/.tui_custom_commands`**: User-defined custom commands
- **`~/.tui_logs`**: Activity logs (last 1000 entries)

## Modular Structure

This project uses a modular design for easier maintenance:

```
t-modules/
├── config/           # Configuration and global variables
├── core/             # Core functionality (navigation, file operations, search)
├── ui/               # User interface components (file listing, operations menus)
├── utils/            # Utility functions (logging)
└── commands/         # Command execution (external and custom commands)
```

## Dependencies

- [gum](https://github.com/charmbracelet/gum) - Terminal UI library
- [neovim](https://neovim.io/) - Default editor (configurable)

## License

MIT © AR-92

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests.