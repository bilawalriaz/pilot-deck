#!/bin/bash
# Session start script for Pilot Deck
# Run this when you connect via SSH or Claude Code
# Provides system health summary and recent activity

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-lib.sh"

PILOT_DECK="$HOME/pilot-deck"

echo "=== Bilawal's Pilot Deck ==="
echo ""

# System health
echo "System Health:"
echo -n "  Docker: "
DOCKER_RUNNING=$(docker ps --format '{{.Names}}' | wc -l)
echo "$DOCKER_RUNNING containers running"

echo -n "  Cloudflared: "
if systemctl is-active --quiet cloudflared; then
    echo "active ✓"
else
    echo "INACTIVE ✗"
fi

echo -n "  Disk: "
df / | tail -1 | awk '{print $4 " free (" $5 " used)"}'

# Last backup
echo -n "  Last backup: "
LATEST_BACKUP=$(find "$HOME/backups/daily" -maxdepth 1 -type d -name "20*" 2>/dev/null | sort -r | head -1)
if [ -n "$LATEST_BACKUP" ]; then
    BACKUP_AGE_HOURS=$((( $(date +%s) - $(stat -c %Y "$LATEST_BACKUP") ) / 3600))
    echo "${BACKUP_AGE_HOURS}h ago ($(basename "$LATEST_BACKUP"))"
else
    echo "not found"
fi

echo ""

# Pending PRs
echo "Pending Items:"
PR_COUNT=$(gh pr list --repo bilawalriaz/vps-config --state open --limit 100 2>/dev/null | wc -l)
if [ "$PR_COUNT" -gt 0 ]; then
    echo "  $PR_COUNT pending PR(s) on vps-config"
    gh pr list --repo bilawalriaz/vps-config --state open --limit 5 2>/dev/null | head -6
else
    echo "  No pending PRs"
fi

echo ""

# Recent activity from pilot-deck
echo "Recent Activity:"
if [ -f "$PILOT_DECK/journal/$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d).md" ]; then
    echo "  Today's journal entry exists"
else
    echo "  No journal entry yet today"
fi

# Project nudges
echo ""
echo "Project Nudges:"
find "$PILOT_DECK/projects" -type f -name "*.md" -not -name "_*" -exec stat -c "%Y %n" {} \; | \
    sort -rn | head -3 | while read -r timestamp file; do
    project=$(basename "$file" .md)
    category=$(basename "$(dirname "$file")")
    days_since=$(( ($(date +%s) - timestamp) / 86400 ))
    stage=$(grep "^**Stage:**" "$file" 2>/dev/null | sed 's/\*\*Stage:\*\* //' || echo "?")
    echo "  • $project ($category) - Stage $stage, touched ${days_since}d ago"
done

echo ""
echo "What would you like to work on?"
