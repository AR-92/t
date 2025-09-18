#!/usr/bin/env bash
# File operations module for TUI File Manager

# Import configuration and logging
source "$(dirname "$(dirname "$0")")/config/config.sh"
source "$(dirname "$(dirname "$0")")/utils/logging.sh"
source "$(dirname "$(dirname "$0")")/core/navigation.sh"

# Add bookmark
add_bookmark() {
  # Check if already bookmarked
  if grep -Fxq "$current_dir" "$bookmarks_file"; then
    gum style --foreground 212 "Already bookmarked!"
    log_action "Attempted to bookmark already bookmarked directory: $current_dir"
  else
    echo "$current_dir" >> "$bookmarks_file"
    gum style --foreground 10 "Bookmarked successfully!"
    log_action "Bookmarked directory: $current_dir"
  fi
  sleep 1
}

# Preview file contents
preview_file() {
  local file_path="$1"
  if [ -d "$file_path" ]; then
    # For directories, show contents
    gum style --foreground 12 --bold "Directory contents: $file_path"
    echo
    ls -la "$file_path" | gum pager
    log_action "Previewed directory contents: $file_path"
  elif [ -f "$file_path" ]; then
    # For files, show contents
    if [[ "$file_path" == *.md ]] || [[ "$file_path" == *.txt ]] || [[ "$file_path" == *.sh ]] || [[ "$file_path" == *.py ]] || [[ "$file_path" == *.js ]] || [[ "$file_path" == *.json ]] || [[ "$file_path" == *.yml ]] || [[ "$file_path" == *.yaml ]]; then
      gum style --foreground 12 --bold "File preview: $file_path"
      echo
      cat "$file_path" | gum pager
      log_action "Previewed file: $file_path"
    else
      gum style --foreground 212 "Preview not available for this file type"
      log_action "Preview not available for file: $file_path"
      sleep 1
    fi
  fi
}

# Show file/directory properties
show_properties() {
  local path="$1"
  gum style --foreground 12 --bold "Properties: $path"
  echo
  stat "$path" | gum pager
  log_action "Viewed properties: $path"
}