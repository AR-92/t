#!/usr/bin/env bash
# -----------------------------
# Enhanced Flowy Gum TUI File Manager with Power Features
# -----------------------------

# Check for help or version flags
case "$1" in
  -h|--help)
    echo -e "\033[1;36mEnhanced Flowy Gum TUI File Manager\033[0m"
    echo -e "\033[36m===================================\033[0m"
    echo
    echo -e "\033[1;37mUsage:\033[0m"
    echo -e "  \033[32mt\033[0m           Start the TUI file manager"
    echo -e "  \033[32mt -h\033[0m       Show this help page"
    echo -e "  \033[32mt --help\033[0m   Show this help page"
    echo -e "  \033[32mt -v\033[0m       Show version information"
    echo -e "  \033[32mt --version\033[0m Show version information"
    echo
    echo -e "\033[1;37mDescription:\033[0m"
    echo -e "  A powerful terminal-based file manager with intuitive keyboard navigation"
    echo -e "  and visual styling using Gum. Navigate directories, manage files, and"
    echo -e "  execute custom commands with ease."
    echo
    echo -e "\033[1;37mNavigation:\033[0m"
    echo -e "  \033[33m↑/↓ Arrows\033[0m     Navigate through files and directories"
    echo -e "  \033[33mEnter\033[0m          Select a file or directory"
    echo -e "  \033[33mType\033[0m           Filter files in real-time"
    echo -e "  \033[33mH\033[0m              Quick history navigation menu"
    echo -e "  \033[33mG\033[0m              Global operations menu"
    echo -e "  \033[33mTab\033[0m            Multi-select (planned feature)"
    echo -e "  \033[33mCtrl+G\033[0m         Global menu"
    echo -e "  \033[33mEsc\033[0m            Return to file list or exit"
    echo
    echo -e "\033[1;37mFile Operations:\033[0m"
    echo -e "  \033[32mOpen/Edit\033[0m      Open files in editor or enter directories"
    echo -e "  \033[31mDelete\033[0m         Remove files or directories (with confirmation)"
    echo -e "  \033[33mRename\033[0m         Rename files or directories"
    echo -e "  \033[36mCopy/Move\033[0m      Copy files to clipboard or move with cut"
    echo -e "  \033[35mPreview\033[0m        View file contents without opening editor"
    echo -e "  \033[34mProperties\033[0m     Show detailed file/directory information"
    echo
    echo -e "\033[1;37mGlobal Operations:\033[0m"
    echo -e "  \033[32mCreate\033[0m         Create new files or directories"
    echo -e "  \033[36mPaste\033[0m          Paste clipboard contents"
    echo -e "  \033[35mBookmarks\033[0m      Add directories to bookmarks or view saved locations"
    echo -e "  \033[33mHistory\033[0m        Navigate through directory history"
    echo -e "  \033[34mSearch\033[0m         Find files by name or content"
    echo -e "  \033[31mCommands\033[0m       Execute custom shell commands"
    echo
    echo -e "\033[1;37mCustom Commands:\033[0m"
    echo -e "  Add your own frequently used commands for quick access"
    echo -e "  Supports placeholders: \$FILE (selected file), \$DIR (current directory)"
    echo
    echo -e "\033[1;37mFiles:\033[0m"
    echo -e "  \033[36m\$HOME/.tui_bookmarks\033[0m     Bookmarked directories"
    echo -e "  \033[36m\$HOME/.tui_custom_commands\033[0m Custom user commands"
    echo -e "  \033[36m\$HOME/.tui_logs\033[0m          Activity logs (last 1000 entries)"
    echo
    echo -e "\033[1;37mDependencies:\033[0m"
    echo -e "  \033[32mgum\033[0m            Terminal UI library (https://github.com/charmbracelet/gum)"
    echo -e "  \033[32mneovim\033[0m         Default editor (configurable)"
    echo
    echo -e "\033[1;37mExit Codes:\033[0m"
    echo -e "  \033[32m0\033[0m              Success"
    echo -e "  \033[31m1\033[0m              General error"
    echo
    echo -e "\033[1;37mAuthor:\033[0m Enhanced Flowy Gum TUI File Manager"
    echo -e "\033[1;37mLicense:\033[0m MIT"
    exit 0
    ;;
  -v|--version)
    echo "TUI File Manager v1.0"
    exit 0
    ;;
esac

set -e

# Global variables
current_dir="$(pwd)"
dir_history=("$current_dir")
history_index=0
bookmarks_file="$HOME/.tui_bookmarks"
clipboard=()
clipboard_action=""  # "copy" or "cut"
log_file="$HOME/.tui_logs"
session_logs=()
custom_commands_file="$HOME/.tui_custom_commands"

# Ensure bookmarks file exists
touch "$bookmarks_file"

# Ensure custom commands file exists
touch "$custom_commands_file"

# Initialize log file
touch "$log_file"

# Log function using gum log with styling
log_action() {
  local message="$1"
  local timestamp=$(date '+%H:%M:%S')
  local log_entry="[$timestamp] $message"
  
  # Add to session logs
  session_logs+=("$log_entry")
  
  # Use gum log to display the action with styling
  gum log --level info \
    --level.foreground=12 \
    --time.foreground=240 \
    --prefix.foreground=212 \
    --message.foreground=255 \
    --prefix="TUI" \
    --time="$timestamp" \
    "$message"
  
  # Maintain only last 1000 logs in file
  if [ $(wc -l < "$log_file") -ge 1000 ]; then
    # Keep only last 999 lines and add new entry
    tail -n 999 "$log_file" > "$log_file.tmp" && mv "$log_file.tmp" "$log_file"
  fi
  
  # Append to log file
  echo "$log_entry" >> "$log_file"
}

# Show session summary
show_session_summary() {
  clear
  gum style --foreground 12 --bold "Session Summary"
  echo
  gum style --foreground 240 "Operations performed in this session:"
  echo
  
  if [ ${#session_logs[@]} -eq 0 ]; then
    gum style --foreground 240 "No operations performed in this session"
  else
    # Show last 10 operations with better styling
    local start_index=0
    if [ ${#session_logs[@]} -gt 10 ]; then
      start_index=$((${#session_logs[@]} - 10))
    fi
    
    for ((i=start_index; i<${#session_logs[@]}; i++)); do
      # Extract timestamp and message
      local log_line="${session_logs[i]}"
      # Handle the case where the log line might contain special characters
      if [[ "$log_line" == \[*\]* ]]; then
        local timestamp=$(echo "$log_line" | cut -d'[' -f2 | cut -d']' -f1)
        local message=$(echo "$log_line" | cut -d']' -f2 | sed 's/^ //')
        echo -e "\033[38;5;212m[$timestamp]\033[0m \033[38;5;255m$message\033[0m"
      else
        # Fallback for lines that don't match the expected format
        echo -e "\033[38;5;255m$log_line\033[0m"
      fi
    done
  fi
  
  echo
  gum style --foreground 10 --bold "Thank you for using TUI File Manager! 👋"
  echo
  gum style --foreground 240 "All actions are logged to: $log_file"
  echo
  gum style --foreground 240 "Press any key to exit..."
  read -rsn1
}

# List files/folders (names only, append / for directories)\nlist_files() {\n  # Add parent directory option at the top (except at filesystem root)\n  if [ \"$current_dir\" != \"/\" ]; then\n    echo \"📁 .. (Parent Directory)\"\n  fi\n  \n  files=()\n  # Include both regular and hidden files\n  for f in \"$current_dir\"/* \"$current_dir\"/.*; do\n    # Skip if no files match the pattern\n    [ ! -e \"$f\" ] && continue\n    # Skip current and parent directory references\n    [ \"$(basename \"$f\")\" = \".\" ] || [ \"$(basename \"$f\")\" = \"..\" ] && continue\n    [ -d \"$f\" ] && files+=(\"📁 $(basename \"$f\")\") || files+=(\"📄 $(basename \"$f\")\")\n  done\n  # If empty\n  [ ${#files[@]} -eq 0 ] && files=()\n  printf \"%s\\n\" \"${files[@]}\"\n}

# List bookmarks
list_bookmarks() {
  if [ -s "$bookmarks_file" ]; then
    while IFS= read -r line; do
      echo "📍 $(basename "$line")"
    done < "$bookmarks_file"
  fi
}

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

# List custom commands
list_custom_commands() {
  if [ -s "$custom_commands_file" ]; then
    while IFS='|' read -r name command; do
      echo "⚡ $name"
    done < "$custom_commands_file"
  fi
}

# Add custom command
add_custom_command() {
  local name=$(gum input --placeholder "Command name (e.g., 'Git Status')")
  if [ -n "$name" ]; then
    local command=$(gum input --placeholder "Command to execute (e.g., 'git status')")
    if [ -n "$command" ]; then
      # Check if command name already exists
      if grep -q "^$name|" "$custom_commands_file"; then
        gum style --foreground 212 "Command '$name' already exists!"
        if gum confirm "Do you want to replace it?"; then
          # Remove the existing command
          grep -v "^$name|" "$custom_commands_file" > "$custom_commands_file.tmp" && mv "$custom_commands_file.tmp" "$custom_commands_file"
          # Add the new command
          echo "$name|$command" >> "$custom_commands_file"
          gum style --foreground 10 "Command '$name' updated successfully!"
          log_action "Updated custom command: $name"
        fi
      else
        echo "$name|$command" >> "$custom_commands_file"
        gum style --foreground 10 "Command '$name' added successfully!"
        log_action "Added custom command: $name"
      fi
      sleep 1
    fi
  fi
}

# Rename custom command
rename_custom_command() {
  if [ ! -s "$custom_commands_file" ]; then
    gum style --foreground 212 "No custom commands found!"
    sleep 1
    return
  fi
  
  # Create a temporary file with numbered options
  local temp_file=$(mktemp)
  local i=1
  while IFS='|' read -r name command; do
    echo "$i. $name" >> "$temp_file"
    i=$((i+1))
  done < "$custom_commands_file"
  
  local selection=$(gum filter --height 10 --placeholder "Select command to rename" < "$temp_file")
  rm "$temp_file"
  
  if [ -n "$selection" ]; then
    # Extract the command name (everything after the number and period)
    local old_name=$(echo "$selection" | sed 's/^[0-9]*\. //')
    
    # Get the current command
    local current_command=$(grep "^$old_name|" "$custom_commands_file" | cut -d'|' -f2)
    
    if [ -n "$current_command" ]; then
      local new_name=$(gum input --placeholder "New name for '$old_name'" --value="$old_name")
      if [ -n "$new_name" ] && [ "$new_name" != "$old_name" ]; then
        # Remove the old entry
        grep -v "^$old_name|" "$custom_commands_file" > "$custom_commands_file.tmp" && mv "$custom_commands_file.tmp" "$custom_commands_file"
        # Add the new entry
        echo "$new_name|$current_command" >> "$custom_commands_file"
        gum style --foreground 10 "Command renamed successfully!"
        log_action "Renamed custom command: $old_name -> $new_name"
        sleep 1
      fi
    fi
  fi
}

# Remove custom command
remove_custom_command() {
  if [ ! -s "$custom_commands_file" ]; then
    gum style --foreground 212 "No custom commands found!"
    sleep 1
    return
  fi
  
  # Create a temporary file with numbered options
  local temp_file=$(mktemp)
  local i=1
  while IFS='|' read -r name command; do
    echo "$i. $name" >> "$temp_file"
    i=$((i+1))
  done < "$custom_commands_file"
  
  local selection=$(gum filter --height 10 --placeholder "Select command to remove" < "$temp_file")
  rm "$temp_file"
  
  if [ -n "$selection" ]; then
    # Extract the command name (everything after the number and period)
    local name=$(echo "$selection" | sed 's/^[0-9]*\. //')
    
    if gum confirm "Remove command '$name'?"; then
      # Remove the entry by filtering out the line that starts with the name followed by |
      grep -v "^$name|" "$custom_commands_file" > "$custom_commands_file.tmp" && mv "$custom_commands_file.tmp" "$custom_commands_file"
      gum style --foreground 10 "Command removed successfully!"
      log_action "Removed custom command: $name"
      sleep 1
    fi
  fi
}

# Execute custom command
execute_custom_command() {
  local name="$1"
  # The name is already clean (without emoji prefix)
  local command=$(grep "^$name|" "$custom_commands_file" | cut -d'|' -f2)
  
  if [ -n "$command" ]; then
    gum style --foreground 12 --bold "Executing: $name"
    echo
    # Replace $FILE or $DIR with the current file/directory
    command=${command//\$FILE/"$current_dir/$real_name"}
    command=${command//\$DIR/"$current_dir"}
    
    eval "$command" | gum pager
    log_action "Executed custom command: $name"
    echo
    gum style --foreground 240 "Press any key to continue..."
    read -rsn1
  else
    gum style --foreground 212 "Command not found: $name"
    sleep 1
  fi
}

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

# Multi-select operations
get_multi_operations() {
  printf "%s\n" \
    "🗑️  Delete selected" \
    "📋 Copy selected" \
    "✂️  Cut selected" \
    "⭐ Add selected to bookmarks" \
    "🔙 Go back to files" \
    "❌ Quit"
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

# Update directory history
update_history() {
  local new_dir="$1"
  # If we're not at the end of history, truncate it
  if [ $history_index -lt $((${#dir_history[@]} - 1)) ]; then
    dir_history=("${dir_history[@]:0:$(($history_index + 1))}")
  fi
  # Add new directory to history
  dir_history+=("$new_dir")
  history_index=$((${#dir_history[@]} - 1))
  log_action "Navigated to directory: $new_dir"
}

# Go back in history
go_back_history() {
  if [ $history_index -gt 0 ]; then
    history_index=$(($history_index - 1))
    current_dir="${dir_history[$history_index]}"
    log_action "Went back to directory: $current_dir"
  else
    gum style --foreground 212 "No more history to go back to"
    log_action "Attempted to go back but no history available"
    sleep 1
  fi
}

# Go forward in history
go_forward_history() {
  if [ $history_index -lt $((${#dir_history[@]} - 1)) ]; then
    history_index=$(($history_index + 1))
    current_dir="${dir_history[$history_index]}"
    log_action "Went forward to directory: $current_dir"
  else
    gum style --foreground 212 "No more history to go forward to"
    log_action "Attempted to go forward but no history available"
    sleep 1
  fi
}

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

# Run external command
run_command() {
  local cmd=$(gum input --placeholder "Enter command to run")
  if [ -n "$cmd" ]; then
    gum style --foreground 12 --bold "Running: $cmd"
    echo
    eval "$cmd" | gum pager
    log_action "Executed command: $cmd"
    echo
    gum style --foreground 240 "Press any key to continue..."
    read -rsn1
  fi
}

# Trap to show session summary on exit
trap show_session_summary EXIT

# Main loop
while true; do
  clear
  # Styled header
  gum style --foreground 12 --bold "📂 $current_dir"
  echo
  
  # Show clipboard status if not empty
  if [ ${#clipboard[@]} -gt 0 ]; then
    gum style --foreground 212 --italic "📋 Clipboard: ${#clipboard[@]} items (${clipboard_action})"
    echo
  fi
  
  # Show the filter with navigation hints in placeholder
  selected=$(list_files | gum filter --height 15 --show-help=false --placeholder "↑/↓ Navigate • Type to filter • Enter to select • H: History Menu • Tab for multi-select • Ctrl+G for global menu")
  
  # Check for special keys
  if [ "$selected" = "" ]; then
    # When gum filter returns empty, it's typically because of Escape key
    # Offer quick access to history navigation
    clear
    gum style --foreground 12 --bold "📂 $current_dir"
    echo
    gum style --foreground 240 "Quick Actions:"
    echo "H. History Navigation Menu"
    echo "G. Global Operations Menu"
    echo "R. Refresh File List"
    echo "Q. Quit"
    echo
    read -p "Select action (H/G/R/Q): " -n 1 action
    echo
    
    case "$action" in
      [Hh])
        # Show history navigation options
        clear
        gum style --foreground 12 --bold "📂 $current_dir"
        echo
        gum style --foreground 212 --bold "History Navigation"
        echo
        echo "1. ← Go back (previous directory)"
        echo "2. → Go forward (next directory)"
        echo "3. Return to file list"
        echo
        read -p "Select option (1/2/3): " -n 1 hist_action
        echo
        
        case "$hist_action" in
          1)
            go_back_history
            continue
            ;;
          2)
            go_forward_history
            continue
            ;;
          *)
            # Return to file list
            continue
            ;;
        esac
        ;;
      [Gg])
        # Continue to global menu handling below
        ;;
      [Rr])
        log_action "Refreshed file list"
        continue
        ;;
      [Qq])
        log_action "Exiting TUI File Manager"
        exit 0
        ;;
      *)
        # Any other key, go back to file list
        continue
        ;;
    esac
    
    # Check if user pressed Ctrl+G for global menu
    # Note: gum filter doesn't directly support Ctrl+G, so we'll add it as an option
    clear
    gum style --foreground 12 --bold "📂 $current_dir"
    echo
    gum style --foreground 212 --bold "Global Operations Menu"
    echo
    
    action=$(get_global_operations | gum filter --height 15 --placeholder "Select global operation")
    
    case "$action" in
      "📁 Create new folder")
        folder_name=$(gum input --placeholder "Folder name" --value="new-folder")
        if [ -n "$folder_name" ]; then
          mkdir -p "$current_dir/$folder_name"
          gum style --foreground 10 "Folder created successfully"
          log_action "Created folder: $current_dir/$folder_name"
          sleep 1
        fi
        ;;
      "📄 Create new file")
        file_name=$(gum input --placeholder "File name" --value="new-file.txt")
        if [ -n "$file_name" ]; then
          touch "$current_dir/$file_name"
          gum style --foreground 10 "File created successfully"
          log_action "Created file: $current_dir/$file_name"
          sleep 1
        fi
        ;;
      "📋 Paste clipboard here")
        if [ ${#clipboard[@]} -gt 0 ]; then
          for item in "${clipboard[@]}"; do
            if [ "$clipboard_action" = "cut" ]; then
              mv "$item" "$current_dir/"
              log_action "Moved item: $item to $current_dir/"
            else
              cp -r "$item" "$current_dir/"
              log_action "Copied item: $item to $current_dir/"
            fi
          done
          if [ "$clipboard_action" = "cut" ]; then
            clipboard=()
            clipboard_action=""
            gum style --foreground 10 "Moved items successfully"
          else
            gum style --foreground 10 "Copied items successfully"
          fi
          sleep 1
        else
          gum style --foreground 212 "Clipboard is empty"
          log_action "Attempted to paste but clipboard is empty"
          sleep 1
        fi
        ;;
      "👀 Preview file")
        file_to_preview=$(list_files | gum filter --height 10 --placeholder "Select file to preview")
        if [ -n "$file_to_preview" ]; then
          real_name=$(echo "$file_to_preview" | sed 's/^[📁📄 ]*//')
          preview_file "$current_dir/$real_name"
        fi
        ;;
      "📊 Show directory properties")
        show_properties "$current_dir"
        ;;
      "⭐ Add current directory to bookmarks")
        add_bookmark
        ;;
      "🔖 View bookmarks")
        clear
        gum style --foreground 12 --bold "🔖 Bookmarks"
        echo
        if [ -s "$bookmarks_file" ]; then
          bookmark_selected=$(list_bookmarks | gum filter --height 10 --placeholder "Select bookmark to open")
          if [ -n "$bookmark_selected" ]; then
            real_name=$(echo "$bookmark_selected" | sed 's/^[📍 ]*//')
            # Find the full path from bookmarks file
            bookmark_path=$(grep -F "$real_name" "$bookmarks_file" | head -n1)
            if [ -n "$bookmark_path" ] && [ -d "$bookmark_path" ]; then
              current_dir="$bookmark_path"
              update_history "$current_dir"
            else
              gum style --foreground 212 "Bookmark not found or invalid"
              log_action "Failed to open bookmark: $real_name"
              sleep 1
            fi
          fi
        else
          gum style --foreground 240 "No bookmarks yet"
          log_action "Viewed bookmarks but none found"
          echo
          gum style --foreground 240 "Press any key to continue..."
          read -rsn1
        fi
        ;;
      "⬅️  Go back (history)")
        go_back_history
        ;;
      "➡️  Go forward (history)")
        go_forward_history
        ;;
      "🔍 Search files by name")
        search_files_by_name
        ;;
      "🔎 Search files by content")
        search_files_by_content
        ;;
      "⚡ Run command")
        run_command
        ;;
      "🔄 Refresh file list")
        # Do nothing, just refresh
        log_action "Refreshed file list"
        ;;
      "➕ Add custom command")
        add_custom_command
        ;;
      "✏️  Rename custom command")
        rename_custom_command
        ;;
      "❌ Remove custom command")
        remove_custom_command
        ;;
      "🔙 Go back to files")
        # Just go back to file list
        continue
        ;;
      "❌ Quit")
        log_action "Exiting TUI File Manager"
        exit 0
        ;;
    esac
    continue
  fi

  # Check if user selected parent directory
  if [ "$selected" = "📁 .. (Parent Directory)" ]; then
    # Go to parent directory
    current_dir=$(dirname "$current_dir")
    update_history "$current_dir"
    continue
  fi

  # Check for multi-select (using a special marker)
  # Since gum filter doesn't support multi-select natively, we'll simulate it
  # by allowing users to select "Multi-select mode" as an option
  
  # For now, let's check if user wants to enter multi-select mode
  if [ "$selected" = "Multi-select mode" ]; then
    # This would be implemented with a custom solution
    # For now, we'll just show a message
    gum style --foreground 212 "Multi-select mode not yet implemented"
    log_action "Attempted to use multi-select mode"
    sleep 1
    continue
  fi

  # Remove emoji prefix to get real name
  real_name=$(echo "$selected" | sed 's/^[📁📄 ]*//')
  
  # Determine if selected item is directory
  is_directory=false
  if [ -d "$current_dir/$real_name" ]; then
    is_directory=true
  fi
  
  # Get context-aware operations
  operations=$(get_file_operations "$real_name" "$is_directory")
  
  # Show operations using filter for consistency
  clear
  gum style --foreground 12 --bold "📂 $current_dir"
  echo
  gum style --foreground 212 --bold "Selected: $real_name"
  echo
  
  # Show quick action keys as help text
  gum style --foreground 240 "Quick Keys: O=Open, D=Delete, R=Rename, C=Copy, V=Cut, P=Preview, B=Back, Q=Quit"
  echo
  
  # Use filter for operations instead of choose for consistency
  action=$(echo "$operations" | gum filter --height 15 --placeholder "Select an operation or press key shortcut")
  
  # Handle the action
  case "$action" in
    "📁 Open directory")
      current_dir="$current_dir/$real_name"
      update_history "$current_dir"
      ;;
    "✏️  Open/Edit file")
      nvim "$current_dir/$real_name"
      log_action "Opened file in editor: $current_dir/$real_name"
      ;;
    "🗑️  Delete "*)
      if gum confirm "Delete '$real_name'?"; then
        if [ -d "$current_dir/$real_name" ]; then
          rm -rf "$current_dir/$real_name"
          log_action "Deleted directory: $current_dir/$real_name"
        else
          rm "$current_dir/$real_name"
          log_action "Deleted file: $current_dir/$real_name"
        fi
        gum style --foreground 10 "Deleted successfully"
        sleep 1
      fi
      ;;
    "✏️  Rename "*)
      new_name=$(gum input --placeholder "New name" --value="$real_name")
      if [ -n "$new_name" ] && [ "$new_name" != "$real_name" ]; then
        mv "$current_dir/$real_name" "$current_dir/$new_name"
        gum style --foreground 10 "Renamed successfully"
        log_action "Renamed '$real_name' to '$new_name'"
        sleep 1
      fi
      ;;
    "📄 Create "*)
      file_name=$(gum input --placeholder "File name" --value="new-file.txt")
      if [ -n "$file_name" ]; then
        touch "$current_dir/$file_name"
        gum style --foreground 10 "File created successfully"
        log_action "Created file: $current_dir/$file_name"
        sleep 1
      fi
      ;;
    "📁 Create "*)
      folder_name=$(gum input --placeholder "Folder name" --value="new-folder")
      if [ -n "$folder_name" ]; then
        mkdir -p "$current_dir/$folder_name"
        gum style --foreground 10 "Folder created successfully"
        log_action "Created folder: $current_dir/$folder_name"
        sleep 1
      fi
      ;;
    "📋 Copy "*)
      clipboard=("$current_dir/$real_name")
      clipboard_action="copy"
      gum style --foreground 10 "Copied to clipboard"
      log_action "Copied to clipboard: $current_dir/$real_name"
      sleep 1
      ;;
    "👀 Preview"*)
      preview_file "$current_dir/$real_name"
      ;;
    "📊 Show "*)
      show_properties "$current_dir/$real_name"
      ;;
    "⭐ Add to bookmarks")
      # For single files/dirs, we'll bookmark the parent directory
      if gum confirm "Bookmark current directory '$current_dir'?"; then
        add_bookmark
      fi
      ;;
    "➕ Add custom command")
      add_custom_command
      ;;
    "✏️  Rename custom command")
      rename_custom_command
      ;;
    "❌ Remove custom command")
      remove_custom_command
      ;;
    "🔙 Go back to files")
      # Just go back to file list
      continue
      ;;
    "❌ Quit")
      log_action "Exiting TUI File Manager"
      exit 0
      ;;
    "⚡ "*)
      # Handle custom commands
      # The action is in the format "⚡ command_name"
      custom_name=$(echo "$action" | sed 's/^⚡ //')
      execute_custom_command "$custom_name"
      ;;
  esac
done