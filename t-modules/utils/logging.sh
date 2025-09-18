#!/usr/bin/env bash
# Logging utility module for TUI File Manager

# Import configuration
source "$(dirname "$0")/../config/config.sh"

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
      if [[ "$log_line" == \\[*\\]* ]]; then
        local timestamp=$(echo "$log_line" | cut -d'[' -f2 | cut -d']' -f1)
        local message=$(echo "$log_line" | cut -d']' -f2 | sed 's/^ //')
        echo -e "\\033[38;5;212m[$timestamp]\\033[0m \\033[38;5;255m$message\\033[0m"
      else
        # Fallback for lines that don't match the expected format
        echo -e "\\033[38;5;255m$log_line\\033[0m"
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