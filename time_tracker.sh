#!/bin/bash
# Work time tracker - logs machine activity every 10 minutes

LOG_DIR="$HOME/.worktime"
LOG_FILE="$LOG_DIR/worklog.txt"
ARCHIVE_DIR="$LOG_DIR/archive"

# Create directories if they don't exist
mkdir -p "$LOG_DIR"
mkdir -p "$ARCHIVE_DIR"

# Append current timestamp
echo "$(date '+%Y-%m-%d %H:%M')" >> "$LOG_FILE"

# Archive data older than 8 days (keeping 7 day rolling window in main log)
if [ -f "$LOG_FILE" ]; then
    CUTOFF_DATE=$(date -d '8 days ago' '+%Y-%m-%d')
    
    # Extract old data and append to monthly archive file
    OLD_DATA=$(grep "^$CUTOFF_DATE" "$LOG_FILE" || true)
    if [ -n "$OLD_DATA" ]; then
        ARCHIVE_MONTH=$(date -d "$CUTOFF_DATE" '+%Y-%m')
        echo "$OLD_DATA" >> "$ARCHIVE_DIR/$ARCHIVE_MONTH.txt"
    fi
    
    # Remove old data from main log
    grep -v "^$CUTOFF_DATE" "$LOG_FILE" > "$LOG_FILE.tmp" || true
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
