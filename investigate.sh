#!/bin/bash

for dir in */; do
    latest=$(find "$dir" -type f -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -1 | cut -d' ' -f1)
    if [ -n "$latest" ]; then
        date -d "@${latest}" "+%Y-%m-%d %H:%M:%S"
    else
        echo "No files"
    fi
    echo "  $dir"
done | sort -r
