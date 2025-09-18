#!/usr/bin/env bash
# -----------------------------
# Enhanced Flowy Gum TUI File Manager (Modular Version)
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

# Define the base directory for modules
MODULES_DIR="$(dirname "$0")/t-modules"

# Import all required modules
source "$MODULES_DIR/config/config.sh"
source "$MODULES_DIR/utils/logging.sh"
source "$MODULES_DIR/ui/file_listing.sh"
source "$MODULES_DIR/core/navigation.sh"
source "$MODULES_DIR/core/file_operations.sh"
source "$MODULES_DIR/core/search.sh"
source "$MODULES_DIR/commands/external.sh"
source "$MODULES_DIR/commands/custom.sh"
source "$MODULES_DIR/ui/operations.sh"

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