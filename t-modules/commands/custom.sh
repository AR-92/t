#!/usr/bin/env bash
# Custom commands module for TUI File Manager

# Import configuration and logging
source "$(dirname "$(dirname "$0")")/config/config.sh"
source "$(dirname "$(dirname "$0")")/utils/logging.sh"

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