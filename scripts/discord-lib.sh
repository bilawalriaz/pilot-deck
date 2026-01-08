#!/bin/bash
# Discord Notification Library for Pilot Deck
# Source this file to use notification functions
# Usage: source ~/scripts/pilot-deck/discord-lib.sh

# Configuration
DISCORD_CONFIG="$HOME/.config/pilot-deck/discord.env"

# Colors for console output (when not sending to Discord)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load Discord webhooks from config
_load_discord_config() {
    if [ -f "$DISCORD_CONFIG" ]; then
        source "$DISCORD_CONFIG"
    else
        echo "Warning: Discord config not found at $DISCORD_CONFIG" >&2
        return 1
    fi
}

# Send notification to Discord
# Args: webhook_url, message, [color], [footer]
# Color values: 15158332 (red), 3066993 (green), 16776960 (yellow), 3447003 (blue)
_discord_send() {
    local webhook_url="$1"
    local message="$2"
    local color="${3:-3447003}"  # Default blue
    local footer="${4:-Hyperflash Agent}"

    # Skip if webhook is not configured
    if [ -z "$webhook_url" ] || [ "$webhook_url" = "" ]; then
        echo "Webhook not configured, skipping Discord notification" >&2
        return 0
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local hostname=$(hostname)

    curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "{
            \"embeds\": [{
                \"description\": \"$message\",
                \"color\": $color,
                \"footer\": {
                    \"text\": \"$footer • $hostname\"
                },
                \"timestamp\": \"$timestamp\"
            }]
        }" > /dev/null 2>&1
}

# Send plain text message (no embed)
_discord_send_plain() {
    local webhook_url="$1"
    local message="$2"

    if [ -z "$webhook_url" ] || [ "$webhook_url" = "" ]; then
        echo "Webhook not configured, skipping Discord notification" >&2
        return 0
    fi

    curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$message\"}" > /dev/null 2>&1
}

# Public API Functions

# Send activity notification
discord_activity() {
    _load_discord_config
    local message="$*"
    echo -e "${BLUE}[Activity]${NC} $message"
    _discord_send "$DISCORD_WEBHOOK_ACTIVITY" "$message" 3447003 "Hyperflash Agent"
}

# Send alert notification
discord_alert() {
    _load_discord_config
    local message="$*"
    echo -e "${RED}[Alert]${NC} $message" >&2
    _discord_send "$DISCORD_WEBHOOK_ALERTS" "$message" 15158332 "Hyperflash Agent"
}

# Send success notification
discord_success() {
    _load_discord_config
    local message="$*"
    echo -e "${GREEN}[Success]${NC} $message"
    _discord_send "$DISCORD_WEBHOOK_ACTIVITY" "$message" 3066993 "Hyperflash Agent"
}

# Send project update notification
discord_project() {
    _load_discord_config
    local message="$*"
    echo -e "${GREEN}[Project]${NC} $message"
    _discord_send "$DISCORD_WEBHOOK_PROJECTS" "$message" 3066993 "Hyperflash Agent"
}

# Send daily digest
discord_daily() {
    _load_discord_config
    local message="$*"
    _discord_send_plain "$DISCORD_WEBHOOK_DAILY" "$message"
}

# Log to pilot-deck and optionally notify Discord
# Usage: pilot_log "message" [activity|alert|success|project]
pilot_log() {
    local message="$1"
    local type="${2:-activity}"
    local date=$(date +%Y-%m-%d)
    local log_file="$HOME/pilot-deck/logs/daily/$date.md"

    # Ensure log directory exists
    mkdir -p "$(dirname "$log_file")"

    # Create log file with header if it doesn't exist
    if [ ! -f "$log_file" ]; then
        cat > "$log_file" <<EOF
# Activity Log: $date

EOF
    fi

    # Append log entry
    local timestamp=$(date +"%H:%M:%S")
    echo "[$timestamp] $message" >> "$log_file"

    # Also send to Discord
    case "$type" in
        activity)
            discord_activity "$message"
            ;;
        alert)
            discord_alert "$message"
            ;;
        success)
            discord_success "$message"
            ;;
        project)
            discord_project "$message"
            ;;
    esac
}

# Export functions for use in subshells
export -f _load_discord_config
export -f _discord_send
export -f _discord_send_plain
export -f discord_activity
export -f discord_alert
export -f discord_success
export -f discord_project
export -f discord_daily
export -f pilot_log
