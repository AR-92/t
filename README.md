# T - Terminal File Manager

A powerful terminal-based file manager with intuitive keyboard navigation and visual styling using Gum.

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

1. Ensure you have the required dependencies installed:
   - [Gum](https://github.com/charmbracelet/gum)
   - [Neovim](https://neovim.io/) (or configure your preferred editor)

2. Clone and install:
   ```bash
   git clone https://github.com/AR-92/t.git
   cd t
   sudo cp t /usr/local/bin/t
   ```

## Usage

```bash
t        # Start the TUI file manager
t -h     # Show help page
t -v     # Show version information
```

## Modular Structure

This project uses a modular design for easier maintenance:

- `t-modules/config/` - Configuration and global variables
- `t-modules/core/` - Core functionality (navigation, file operations, search)
- `t-modules/ui/` - User interface components (file listing, operations menus)
- `t-modules/utils/` - Utility functions (logging)
- `t-modules/commands/` - Command execution (external and custom commands)

## Dependencies

- gum: Terminal UI library
- neovim: Default editor (configurable)

## License

MIT