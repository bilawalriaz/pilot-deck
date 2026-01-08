#!/bin/bash
# Daily digest script for Pilot Deck
# Runs at 08:00 daily to send system health summary and project nudges

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-lib.sh"

# Configuration
PILOT_DECK="$HOME/pilot-deck"
BACKUP_DIR="$HOME/backups/daily"

echo "=== Daily Digest Generation ==="
echo "Started: $(date)"
echo ""

# Build digest message
DIGEST="## Morning Report - $(date +%Y-%m-%d)%0A%0A"

# --- System Health ---
DIGEST+="**System Health**%0A"

# Docker containers
DOCKER_RUNNING=$(docker ps --format '{{.Names}}' | wc -l)
DOCKER_TOTAL=$(docker ps -a --format '{{.Names}}' | wc -l)
DIGEST+="- Docker: $DOCKER_RUNNING/$DOCKER_TOTAL containers running%0A"

# Cloudflared
if systemctl is-active --quiet cloudflared; then
    DIGEST+="- Cloudflared: ✓ Active%0A"
else
    DIGEST+="- Cloudflared: ✗ INACTIVE%0A"
fi

# Disk space
DISK_FREE=$(df / | tail -1 | awk '{print $4}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}')
DIGEST+="- Disk: $DISK_USAGE used ($DISK_FREE free)%0A"

# Last backup
LATEST_BACKUP=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" | sort -r | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    BACKUP_AGE_HOURS=$((( $(date +%s) - $(stat -c %Y "$LATEST_BACKUP") ) / 3600))
    BACKUP_SIZE=$(du -sh "$LATEST_BACKUP" | cut -f1)
    DIGEST+="- Last backup: ${BACKUP_AGE_HOURS}h ago (${BACKUP_SIZE})%0A"
else
    DIGEST+="- Last backup: NOT FOUND%0A"
fi

DIGEST+="%0A"

# --- Project Nudges ---
DIGEST+="**Project Nudges**%0A"

# Find projects by category
for category in infrastructure ml-ai career learning side-projects; do
    PROJECT_DIR="$PILOT_DECK/projects/$category"
    if [ -d "$PROJECT_DIR" ]; then
        # Find most recently touched project in this category
        latest_project=$(find "$PROJECT_DIR" -maxdepth 1 -type f -name "*.md" -not -name "_*" -exec stat -c "%Y %n" {} \; | sort -rn | head -1 | cut -d' ' -f2-)

        if [ -n "$latest_project" ]; then
            project_name=$(basename "$latest_project" .md)
            last_touched=$(git -C "$PILOT_DECK" log -1 --format="%ci" -- "$latest_project" 2>/dev/null | cut -d' ' -f1-2 || echo "unknown")
            days_since=$(( ($(date +%s) - $(stat -c %Y "$latest_project")) / 86400 ))

            # Extract stage and next step from project file
            stage=$(grep "^**Stage:**" "$latest_project" | sed 's/\*\*Stage:\*\* //' || echo "unknown")
            next_step=$(grep "^## Next Step" -A 1 "$latest_project" | tail -1 | sed 's/## Next Step//' || echo "not specified")

            if [ "$days_since" -gt 3 ]; then
                DIGEST+="• **$project_name** ($category) - Stage $stage, last touched ${days_since}d ago%0A  Next: $next_step%0A%0A"
            fi
        fi
    fi
done

if [[ "$DIGEST" != *"•"* ]]; then
    DIGEST+="No stale projects. Good momentum!%0A"
fi

DIGEST+="%0A"

# --- Suggested Focus ---
DIGEST+="**Suggested Focus**%0A"

# Check for pending PRs
if gh pr list --repo bilawalriaz/vps-config --state open --limit 1 | grep -q .; then
    PR_COUNT=$(gh pr list --repo bilawalriaz/vps-config --state open --limit 100 | wc -l)
    DIGEST+="• You have $PR_COUNT pending PR(s) awaiting review%0A"
fi

# Check for incomplete todos
if grep -q "\- \[ \]" "$PILOT_DECK/todos/today.md" 2>/dev/null; then
    TODO_COUNT=$(grep -c "\- \[ \]" "$PILOT_DECK/todos/today.md")
    DIGEST+="• $TODO_COUNT items in today.md backlog%0A"
fi

DIGEST+="%0A_Have a great day!_"

# Send to Discord
echo "Sending daily digest..."
discord_daily "$DIGEST"

# Also log to pilot-deck
pilot_log "Daily digest sent: ${DOCKER_RUNNING}/${DOCKER_TOTAL} containers, ${DISK_USAGE} disk used"

echo "✓ Daily digest sent"
exit 0
