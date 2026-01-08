#!/bin/bash
# Health check script for Pilot Deck
# Monitors: Docker containers, Cloudflared tunnel, disk space, recent backups
# Sends alerts to Discord if issues detected

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-lib.sh"

# Configuration
DISK_WARNING_THRESHOLD=20  # Percentage
BACKUP_MAX_AGE_HOURS=26     # Backups older than this trigger warning

# Counters
ISSUES=0
WARNINGS=0

echo "=== Pilot Deck Health Check ==="
echo "Started: $(date)"
echo ""

# Function: Check if Docker container is running
check_container() {
    local container="$1"
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        echo "✓ Container: $container running"
        return 0
    else
        echo "✗ Container: $container NOT RUNNING"
        ((ISSUES++))
        return 1
    fi
}

# Function: Check systemd service
check_service() {
    local service="$1"
    if systemctl is-active --quiet "$service"; then
        echo "✓ Service: $service active"
        return 0
    else
        echo "✗ Service: $service NOT ACTIVE"
        ((ISSUES++))
        return 1
    fi
}

# Function: Check disk space
check_disk() {
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    local free=$((100 - usage))

    if [ "$free" -lt "$DISK_WARNING_THRESHOLD" ]; then
        echo "✗ Disk: Only ${free}% free (${usage}% used)"
        ((ISSUES++))
        return 1
    else
        echo "✓ Disk: ${free}% free"
        return 0
    fi
}

# Function: Check backup age
check_backup() {
    local backup_dir="$1"
    local name="$2"

    if [ ! -d "$backup_dir" ]; then
        echo "⚠ Backup: $name directory not found"
        ((WARNINGS++))
        return 1
    fi

    # Find most recent backup
    local latest=$(find "$backup_dir" -maxdepth 1 -type d -name "20*" | sort -r | head -1)

    if [ -z "$latest" ]; then
        echo "✗ Backup: $name no backups found"
        ((ISSUES++))
        return 1
    fi

    # Check age in hours
    local age_hours=$((( $(date +%s) - $(stat -c %Y "$latest") ) / 3600))

    if [ "$age_hours" -gt "$BACKUP_MAX_AGE_HOURS" ]; then
        echo "✗ Backup: $name last backup ${age_hours}h old (at $(basename "$latest"))"
        ((ISSUES++))
        return 1
    else
        echo "✓ Backup: $name last backup ${age_hours}h old"
        return 0
    fi
}

# Run checks
echo "--- Docker Containers ---"
check_container "caddy" || discord_alert "Docker container down: caddy"
check_container "umami" || discord_alert "Docker container down: umami"
check_container "umami-db" || discord_alert "Docker container down: umami-db"
check_container "netdata" || discord_alert "Docker container down: netdata"

echo ""
echo "--- Services ---"
check_service "cloudflared" || discord_alert "Service down: cloudflared"

echo ""
echo "--- Disk Space ---"
check_disk || discord_alert "Disk space low: $(df / | tail -1 | awk '{print $5}') used on root"

echo ""
echo "--- Backups ---"
check_backup "$HOME/backups/daily" "Daily"

# Summary
echo ""
echo "=== Summary ==="
echo "Issues: $ISSUES"
echo "Warnings: $WARNINGS"

# Send summary if there are issues
if [ $ISSUES -gt 0 ]; then
    discord_alert "Health check completed with $ISSUES issue(s) and $WARNINGS warning(s). Check VPS for details."
    exit 1
else
    echo "✓ All checks passed"
    exit 0
fi
