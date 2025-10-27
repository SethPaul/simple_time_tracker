#!/bin/bash
# Work time history - shows work hours for any date range including archives

LOG_DIR="$HOME/.worktime"
LOG_FILE="$LOG_DIR/worklog.txt"
ARCHIVE_DIR="$LOG_DIR/archive"

# Function to calculate hours from timestamps
calculate_hours() {
    local DATE=$1
    local DATA=$2
    
    if [ -z "$DATA" ]; then
        return
    fi
    
    # Extract times for this date
    TIMES=$(echo "$DATA" | grep "^$DATE" | sort -u)
    
    if [ -z "$TIMES" ]; then
        return
    fi
    
    # Get start and end times
    START=$(echo "$TIMES" | head -1 | cut -d' ' -f2)
    END=$(echo "$TIMES" | tail -1 | cut -d' ' -f2)
    
    # Count intervals
    COUNT=$(echo "$TIMES" | wc -l)
    HOURS=$(awk "BEGIN {printf \"%.1f\", $COUNT * 10 / 60}")
    
    DAY_NAME=$(date -d "$DATE" '+%A' 2>/dev/null || echo "")
    
    printf "%-10s (%s): %s - %s  [~%.1f hours]\n" "$DATE" "$DAY_NAME" "$START" "$END" "$HOURS"
    
    echo "$COUNT"
}

# Parse arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: worktime-history.sh [days_back]"
    echo ""
    echo "Examples:"
    echo "  worktime-history.sh           # Last 7 days (default)"
    echo "  worktime-history.sh 14        # Last 14 days"
    echo "  worktime-history.sh 30        # Last 30 days"
    echo "  worktime-history.sh 90        # Last 90 days"
    echo ""
    echo "Data location: $LOG_DIR"
    echo "Archives: $ARCHIVE_DIR"
    exit 0
fi

DAYS_BACK=${1:-7}

if ! [[ "$DAYS_BACK" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a number of days"
    exit 1
fi

echo "Work Hours Summary (Last $DAYS_BACK Days)"
echo "=================================="
echo ""

# Collect all data from current log and archives
ALL_DATA=""

if [ -f "$LOG_FILE" ]; then
    ALL_DATA=$(cat "$LOG_FILE")
fi

if [ -d "$ARCHIVE_DIR" ]; then
    for archive in "$ARCHIVE_DIR"/*.txt; do
        if [ -f "$archive" ]; then
            ALL_DATA="$ALL_DATA"$'\n'"$(cat "$archive")"
        fi
    done
fi

if [ -z "$ALL_DATA" ]; then
    echo "No work time data found. Tracker may not be running yet."
    exit 1
fi

# Process each day
TOTAL_COUNT=0
for i in $(seq 0 $((DAYS_BACK - 1))); do
    DATE=$(date -d "$i days ago" '+%Y-%m-%d')
    COUNT=$(calculate_hours "$DATE" "$ALL_DATA")
    if [ -n "$COUNT" ]; then
        TOTAL_COUNT=$((TOTAL_COUNT + COUNT))
    fi
done

echo ""
echo "Total Hours Last $DAYS_BACK Days:"
TOTAL_HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_COUNT * 10 / 60}")
echo "  $TOTAL_HOURS hours"
echo "  $(awk "BEGIN {printf \"%.1f\", $TOTAL_HOURS / 5}") hours/day (5-day average)"
