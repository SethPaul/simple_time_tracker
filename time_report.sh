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

# Process last 14 days
for i in {0..13}; do
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
    
    # Count number of 10-minute intervals (approximates hours)
    COUNT=$(echo "$TIMES" | wc -l)
    HOURS=$(awk "BEGIN {printf \"%.1f\", $COUNT * 10 / 60}")
    
    printf "%-10s (%s): %s - %s  [~%.1f hours]\n" "$DATE" "$DAY_NAME" "$START" "$END" "$HOURS"
done

echo ""
echo "Total Hours Last 14 Days:"
TOTAL_COUNT=$(grep "^$(date -d '13 days ago' '+%Y-%m-%d')" "$LOG_FILE" | wc -l)
for i in {0..5}; do
    DATE=$(date -d "$i days ago" '+%Y-%m-%d')
    COUNT=$(grep "^$DATE" "$LOG_FILE" | wc -l)
    TOTAL_COUNT=$((TOTAL_COUNT + COUNT))
done
TOTAL_HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_COUNT * 10 / 60}")
echo "  $TOTAL_HOURS hours"
echo ""
echo "Tip: Use 'time_history.sh 30' to see last 30 days (including archives)"
