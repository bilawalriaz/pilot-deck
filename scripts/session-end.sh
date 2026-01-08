#!/bin/bash
# Session end script for Pilot Deck
# Run this at the end of a work session
# Logs what was done and updates pilot-deck

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-lib.sh"

PILOT_DECK="$HOME/pilot-deck"
SESSION_LOG="$PILOT_DECK/logs/session.log"

# Check if session summary exists
if [ -f "$SESSION_LOG" ]; then
    LAST_SESSION=$(tail -1 "$SESSION_LOG" 2>/dev/null)
else
    LAST_SESSION=""
fi

echo "=== Session Summary ==="
echo ""
echo "What did we do today?"
echo "Enter each item, then press Enter (empty line to finish):"
echo ""

SUMMARY_ITEMS=()
while read -r item; do
    if [ -z "$item" ]; then
        break
    fi
    SUMMARY_ITEMS+=("$item")
done

if [ ${#SUMMARY_ITEMS[@]} -eq 0 ]; then
    echo "No items to log. Session ended."
    exit 0
fi

echo ""
echo "What's next for next time?"
read -r NEXT_STEP

# Create formatted summary
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
cat >> "$SESSION_LOG" <<EOF
[$TIMESTAMP] Session Summary:
$(printf '  - %s\n' "${SUMMARY_ITEMS[@]}")
Next: $NEXT_STEP

EOF

# Display summary
echo ""
echo "Session logged:"
printf '  - %s\n' "${SUMMARY_ITEMS[@]}"
echo "Next: $NEXT_STEP"

# Log to Discord
if [ ${#SUMMARY_ITEMS[@]} -gt 0 ]; then
    SUMMARY_TEXT=$(printf '%s; ' "${SUMMARY_ITEMS[@]}" | sed 's/; $//')
    pilot_log "Session ended: $SUMMARY_TEXT. Next: $NEXT_STEP" activity
fi

echo ""
echo "Logged to pilot-deck ✓"
