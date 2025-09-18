#!/usr/bin/env bash
# Commands module for TUI File Manager

# Import configuration and logging
source "$(dirname "$(dirname "$0")")/config/config.sh"
source "$(dirname "$(dirname "$0")")/utils/logging.sh"

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