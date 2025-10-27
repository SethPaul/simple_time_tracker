#!/bin/bash
# Work time history - shows work hours for any date range including archives

LOG_DIR="$HOME/.worktime"
LOG_FILE="$LOG_DIR/worklog.txt"
ARCHIVE_DIR="$LOG_DIR/archive"

# Function to calculate minutes for a date
get_minutes() {
    local DATE=$1
    local DATA=$2
    
    # Extract times for this date
    TIMES=$(echo "$DATA" | grep "^$DATE" | sort -u)
    
    if [ -z "$TIMES" ]; then
        echo "0"
        return
    fi
    
    # Get start and end times
    START=$(echo "$TIMES" | head -1 | cut -d' ' -f2)
    END=$(echo "$TIMES" | tail -1 | cut -d' ' -f2)
    
    # Calculate actual minutes from time span
    START_MINS=$(echo "$START" | awk -F: '{print $1 * 60 + $2}')
    END_MINS=$(echo "$END" | awk -F: '{print $1 * 60 + $2}')
    DIFF_MINS=$((END_MINS - START_MINS))
    
    # Add 10 minutes to account for the last interval
    TOTAL_MINS=$((DIFF_MINS + 10))
    
    echo "$TOTAL_MINS"
}

# Function to display a day
display_day() {
    local DATE=$1
    local DATA=$2
    
    # Extract times for this date
    TIMES=$(echo "$DATA" | grep "^$DATE" | sort -u)
    
    if [ -z "$TIMES" ]; then
        return
    fi
    
    # Get start and end times
    START=$(echo "$TIMES" | head -1 | cut -d' ' -f2)
    END=$(echo "$TIMES" | tail -1 | cut -d' ' -f2)
    
    # Get minutes
    TOTAL_MINS=$(get_minutes "$DATE" "$DATA")
    HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_MINS / 60}")
    
    DAY_NAME=$(date -d "$DATE" '+%A' 2>/dev/null || echo "")
    
    printf "%-10s (%s): %s - %s  [%.1f hours]\n" "$DATE" "$DAY_NAME" "$START" "$END" "$HOURS"
}

# Parse arguments
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: time_history.sh [days_back]"
    echo ""
    echo "Examples:"
    echo "  time_history.sh           # Last 7 days (default)"
    echo "  time_history.sh 14        # Last 14 days"
    echo "  time_history.sh 30        # Last 30 days"
    echo "  time_history.sh 90        # Last 90 days"
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
TOTAL_MINS=0
for i in $(seq 0 $((DAYS_BACK - 1))); do
    DATE=$(date -d "$i days ago" '+%Y-%m-%d')
    display_day "$DATE" "$ALL_DATA"
    MINS=$(get_minutes "$DATE" "$ALL_DATA")
    TOTAL_MINS=$((TOTAL_MINS + MINS))
done

echo ""
echo "Total Hours Last $DAYS_BACK Days:"
TOTAL_HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_MINS / 60}")
echo "  $TOTAL_HOURS hours"
AVG_HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_HOURS / 5}")
echo "  $AVG_HOURS hours/day (5-day work week average)"
