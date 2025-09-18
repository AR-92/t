#!/usr/bin/env bash
# Navigation module for TUI File Manager

# Import configuration and logging
source "$(dirname "$0")/../config/config.sh"
source "$(dirname "$0")/../utils/logging.sh"

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