#!/usr/bin/env bash
# Configuration module for TUI File Manager

# Global variables
declare -g current_dir="$(pwd)"
declare -g dir_history=("$current_dir")
declare -g history_index=0
declare -g bookmarks_file="$HOME/.tui_bookmarks"
declare -g clipboard=()
declare -g clipboard_action=""  # "copy" or "cut"
declare -g log_file="$HOME/.tui_logs"
declare -g session_logs=()
declare -g custom_commands_file="$HOME/.tui_custom_commands"

# Ensure required files exist
touch "$bookmarks_file"
touch "$custom_commands_file"
touch "$log_file"

# Version information
declare -g APP_NAME="Enhanced Flowy Gum TUI File Manager"
declare -g APP_VERSION="1.0"