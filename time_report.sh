#!/bin/bash
# Work time report - shows daily work hours for last 7 days

LOG_FILE="$HOME/.worktime/worklog.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "No work time data found. Tracker may not be running yet."
    exit 1
fi

echo "Work Hours Summary (Last 7 Days)"
echo "=================================="
echo ""

# Process last 7 days
for i in {0..6}; do
    DATE=$(date -d "$i days ago" '+%Y-%m-%d')
    DAY_NAME=$(date -d "$i days ago" '+%A')
    
    # Get all timestamps for this date
    TIMES=$(grep "^$DATE" "$LOG_FILE" | sort -u)
    
    if [ -z "$TIMES" ]; then
        printf "%-10s (%s): No activity\n" "$DATE" "$DAY_NAME"
        continue
    fi
    
    # Extract start and end times
    START=$(echo "$TIMES" | head -1 | cut -d' ' -f2)
    END=$(echo "$TIMES" | tail -1 | cut -d' ' -f2)
    
    # Calculate actual hours from time span
    START_MINS=$(echo "$START" | awk -F: '{print $1 * 60 + $2}')
    END_MINS=$(echo "$END" | awk -F: '{print $1 * 60 + $2}')
    DIFF_MINS=$((END_MINS - START_MINS))
    
    # Add 10 minutes to account for the last interval
    TOTAL_MINS=$((DIFF_MINS + 10))
    HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_MINS / 60}")
    
    printf "%-10s (%s): %s - %s  [%.1f hours]\n" "$DATE" "$DAY_NAME" "$START" "$END" "$HOURS"
done

echo ""
echo "Total Hours Last 7 Days:"

TOTAL_MINS=0
for i in {0..6}; do
    DATE=$(date -d "$i days ago" '+%Y-%m-%d')
    TIMES=$(grep "^$DATE" "$LOG_FILE" | sort -u)
    
    if [ -n "$TIMES" ]; then
        START=$(echo "$TIMES" | head -1 | cut -d' ' -f2)
        END=$(echo "$TIMES" | tail -1 | cut -d' ' -f2)
        
        START_MINS=$(echo "$START" | awk -F: '{print $1 * 60 + $2}')
        END_MINS=$(echo "$END" | awk -F: '{print $1 * 60 + $2}')
        DAY_MINS=$((END_MINS - START_MINS + 10))
        TOTAL_MINS=$((TOTAL_MINS + DAY_MINS))
    fi
done

TOTAL_HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_MINS / 60}")
echo "  $TOTAL_HOURS hours"
echo ""
echo "Tip: Use 'time-history.sh 30' to see last 30 days (including archives)"
