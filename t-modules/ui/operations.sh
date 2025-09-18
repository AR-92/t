#!/usr/bin/env bash
# UI operations module for TUI File Manager

# Import configuration and other modules
source "$(dirname "$(dirname "$0")")/config/config.sh"
source "$(dirname "$(dirname "$0")")/ui/file_listing.sh"
source "$(dirname "$(dirname "$0")")/core/file_operations.sh"
source "$(dirname "$(dirname "$0")")/commands/custom.sh"

# Context-aware operations based on file type
get_file_operations() {
  local file_name="$1"
  local is_dir="$2"
  
  if [ "$is_dir" = true ]; then
    # Operations for directories
    printf "%s\n" \
      "📁 Open directory" \
      "🗑️  Delete directory" \
      "✏️  Rename directory" \
      "📄 Create file here" \
      "📁 Create folder here" \
      "📋 Copy directory path" \
      "👀 Preview directory contents" \
      "📊 Show directory properties" \
      "⭐ Add to bookmarks"
  else
    # Operations for files
    printf "%s\n" \
      "✏️  Open/Edit file" \
      "🗑️  Delete file" \
      "✏️  Rename file" \
      "📋 Copy file path" \
      "👀 Preview file contents" \
      "📊 Show file properties" \
      "⭐ Add to bookmarks"
  fi
  
  # Add custom commands
  if [ -s "$custom_commands_file" ] && [ "$(wc -l < "$custom_commands_file")" -gt 0 ]; then
    # Check if there are actual commands (not just whitespace)
    if grep -q "^[^[:space:]]" "$custom_commands_file"; then
      echo "⚡ Custom commands:"
      list_custom_commands
    fi
  fi
  
  # Always add these at the end
  printf "%s\n" \
    "➕ Add custom command" \
    "✏️  Rename custom command" \
    "❌ Remove custom command" \
    "🔙 Go back to files" \
    "❌ Quit"
}

# Global operations
get_global_operations() {
  printf "%s\n" \
    "📁 Create new folder" \
    "📄 Create new file" \
    "📋 Paste clipboard here" \
    "👀 Preview file" \
    "📊 Show directory properties" \
    "⭐ Add current directory to bookmarks" \
    "🔖 View bookmarks" \
    "⬅️  Go back (history)" \
    "➡️  Go forward (history)" \
    "🔍 Search files by name" \
    "🔎 Search files by content" \
    "⚡ Run command" \
    "🔄 Refresh file list" \
    "➕ Add custom command" \
    "✏️  Rename custom command" \
    "❌ Remove custom command" \
    "🔙 Go back to files" \
    "❌ Quit"
}