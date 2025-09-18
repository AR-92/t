#!/usr/bin/env bash
# Search module for TUI File Manager

# Import configuration and logging
source "$(dirname "$0")/../config/config.sh"
source "$(dirname "$0")/../utils/logging.sh"

# Search files by name
search_files_by_name() {
  local search_term=$(gum input --placeholder "Enter search term")
  if [ -n "$search_term" ]; then
    gum style --foreground 12 --bold "Search results for: $search_term"
    echo
    # Search in current directory and subdirectories
    find "$current_dir" -name "*$search_term*" -type f 2>/dev/null | while read -r file; do
      echo "📄 $file"
    done | gum pager
    log_action "Searched files by name: $search_term"
    echo
    gum style --foreground 240 "Press any key to continue..."
    read -rsn1
  fi
}

# Search files by content
search_files_by_content() {
  local search_term=$(gum input --placeholder "Enter search term")
  if [ -n "$search_term" ]; then
    gum style --foreground 12 --bold "Files containing: $search_term"
    echo
    # Search in current directory and subdirectories
    grep -r -l "$search_term" "$current_dir" 2>/dev/null | while read -r file; do
      echo "📄 $file"
    done | gum pager
    log_action "Searched files by content: $search_term"
    echo
    gum style --foreground 240 "Press any key to continue..."
    read -rsn1
  fi
}