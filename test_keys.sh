#!/bin/bash

echo "Testing arrow key detection"
echo "Press Left Arrow, Right Arrow, or Escape (Ctrl+C to exit)"

while true; do
    read -rsn1 key
    
    # Check for escape sequence
    if [[ $key == $'\e' ]]; then
        read -rsn2 key
        case $key in
            '[D') echo "Left arrow detected" ;;
            '[C') echo "Right arrow detected" ;;
            *) echo "Other escape sequence: $key" ;;
        esac
    else
        case $key in
            $'\e') echo "Escape detected" ;;
            *) echo "Regular key: $key" ;;
        esac
    fi
done