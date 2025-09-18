#!/usr/bin/env bash
# File listing module for TUI File Manager

# Import configuration
source "$(dirname "$(dirname "$0")")/config/config.sh"

# List files/folders (names only, append / for directories)
list_files() {
  # Add parent directory option at the top (except at filesystem root)
  if [ "$current_dir" != "/" ]; then
    echo "📁 .. (Parent Directory)"
  fi
  
  files=()
  # Include both regular and hidden files
  for f in "$current_dir"/* "$current_dir"/.*; do
    # Skip if no files match the pattern
    [ ! -e "$f" ] && continue
    # Skip current and parent directory references
    [ "$(basename "$f")" = "." ] || [ "$(basename "$f")" = ".." ] && continue
    [ -d "$f" ] && files+=("📁 $(basename "$f")") || files+=("📄 $(basename "$f")")
  done
  # If empty
  [ ${#files[@]} -eq 0 ] && files=()
  printf "%s\n" "${files[@]}"
}

# List bookmarks
list_bookmarks() {
  if [ -s "$bookmarks_file" ]; then
    while IFS= read -r line; do
      echo "📍 $(basename "$line")"
    done < "$bookmarks_file"
  fi
}

# List custom commands
list_custom_commands() {
  if [ -s "$custom_commands_file" ] && [ "$(wc -l < "$custom_commands_file")" -gt 0 ]; then
    # Check if there are actual commands (not just whitespace)
    if grep -q "^[^[:space:]]" "$custom_commands_file"; then
      while IFS='|' read -r name command; do
        echo "⚡ $name"
      done < "$custom_commands_file"
    fi
  fi
}