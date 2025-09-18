# Enhanced Flowy Gum TUI File Manager

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

## Installation

1. Ensure you have the required dependencies installed:
   - [Gum](https://github.com/charmbracelet/gum)
   - [Neovim](https://neovim.io/) (or configure your preferred editor)

2. Clone and install:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   sudo cp t /usr/local/bin/t
   ```

## Usage

```bash
t        # Start the TUI file manager
t -h     # Show help page
t -v     # Show version information
```

## Dependencies

- gum: Terminal UI library
- neovim: Default editor (configurable)

## License

MIT