#!/bin/bash
# Backup notification wrapper for Pilot Deck
# Wraps existing backup scripts with Discord notifications
# Usage: backup-wrapper.sh <script_name> <backup_type>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-lib.sh"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <script_path> [backup_type]"
    echo ""
    echo "Examples:"
    echo "  $0 ~/scripts/backups/backup-daily.sh daily"
    echo "  $0 ~/scripts/backups/backup-weekly.sh weekly"
    echo "  $0 ~/scripts/backups/sync-to-github.sh github"
    exit 1
fi

BACKUP_SCRIPT="$1"
BACKUP_TYPE="${2:-backup}"
SCRIPT_NAME=$(basename "$BACKUP_SCRIPT")

# Start notification
discord_activity "Starting ${BACKUP_TYPE} backup (${SCRIPT_NAME})..."

# Run backup script and capture exit status
if bash "$BACKUP_SCRIPT"; then
    # Success
    BACKUP_SIZE=""
    if [ "$BACKUP_TYPE" = "daily" ]; then
        LATEST_BACKUP=$(find "$HOME/backups/daily" -maxdepth 1 -type d -name "20*" | sort -r | head -1)
        if [ -n "$LATEST_BACKUP" ]; then
            BACKUP_SIZE=$(du -sh "$LATEST_BACKUP" | cut -f1)
        fi
    fi

    if [ -n "$BACKUP_SIZE" ]; then
        discord_success "${BACKUP_TYPE} backup completed: ${BACKUP_SIZE}"
    else
        discord_success "${BACKUP_TYPE} backup completed"
    fi

    pilot_log "Backup successful: ${SCRIPT_NAME}" activity
    exit 0
else
    # Failure
    EXIT_CODE=$?
    discord_alert "${BACKUP_TYPE} backup FAILED (${SCRIPT_NAME}) - Exit code: ${EXIT_CODE}"
    pilot_log "Backup failed: ${SCRIPT_NAME} (exit ${EXIT_CODE})" alert
    exit $EXIT_CODE
fi
