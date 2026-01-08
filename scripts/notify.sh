#!/bin/bash
# Simple CLI tool for sending Discord notifications
# Usage: notify.sh <channel> "message"
# Channels: activity, alert, success, project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-lib.sh"

# Parse arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <channel> <message>"
    echo ""
    echo "Channels:"
    echo "  activity  - Real-time actions and status"
    echo "  alert     - System problems, urgent items"
    echo "  success   - Completed tasks, milestones"
    echo "  project   - Project stage completions"
    echo ""
    echo "Examples:"
    echo "  $0 activity 'Starting daily backup'"
    echo "  $0 alert 'Docker container down: caddy'"
    echo "  $0 success 'Backup completed: 2.3GB'"
    echo "  $0 project 'Pilot Deck reached Stage 1: MVP'"
    exit 1
fi

CHANNEL="$1"
MESSAGE="${@:2}"

case "$CHANNEL" in
    activity)
        discord_activity "$MESSAGE"
        ;;
    alert|alerts)
        discord_alert "$MESSAGE"
        ;;
    success)
        discord_success "$MESSAGE"
        ;;
    project|projects)
        discord_project "$MESSAGE"
        ;;
    *)
        echo "Error: Unknown channel '$CHANNEL'"
        echo "Valid channels: activity, alert, success, project"
        exit 1
        ;;
esac
