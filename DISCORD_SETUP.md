# Discord Setup Guide for Pilot Deck

This guide walks you through setting up the Discord server and webhooks for Pilot Deck notifications.

## Step 1: Create Discord Server

1. Open Discord and click the **+** icon next to your servers
2. Click **Create My Own** > **For me and my friends**
3. Name it: **Bilawal's Pilot Deck**
4. Choose a custom region if needed
5. Click Create

## Step 2: Create Channels

Create the following **text channels** (all private/restricted to you):

| Channel | Purpose |
|---------|---------|
| #agent-activity | Real-time agent actions and status |
| #alerts | System alerts, failures, urgent items |
| #project-updates | Stage completions, milestones |
| #daily-digest | Morning summary of health + nudges |
| #commands | For you to send commands (future bot) |

### Channel Creation Steps:
1. Right-click server name > **Create Channel**
2. Select **Text Channel**
3. Enter channel name (e.g., `agent-activity`)
4. Set to **Private** (only you can see)
5. Click Create Channel

## Step 3: Create Webhooks

For each channel, create a webhook:

### Webhook Creation Steps:
1. Click the **gear** next to the channel name
2. Go to **Integrations** > **Webhooks**
3. Click **New Webhook**
4. Name it: `Pilot Deck - [Channel Name]`
5. Copy the **Webhook URL** (looks like: `https://discord.com/api/webhooks/...`)
6. Click **Save**

### Create Webhooks For:
- `#agent-activity` → Copy webhook URL
- `#alerts` → Copy webhook URL
- `#project-updates` → Copy webhook URL
- `#daily-digest` → Copy webhook URL

## Step 4: Configure Webhooks on VPS

Once you have all four webhook URLs, SSH into your VPS and edit the config:

```bash
nano ~/.config/pilot-deck/discord.env
```

Add your webhook URLs:

```bash
# Agent Activity Channel - Real-time actions and status
export DISCORD_WEBHOOK_ACTIVITY="https://discord.com/api/webhooks/YOUR_ACTIVITY_WEBHOOK_URL"

# Alerts Channel - System problems, urgent items
export DISCORD_WEBHOOK_ALERTS="https://discord.com/api/webhooks/YOUR_ALERTS_WEBHOOK_URL"

# Project Updates Channel - Stage completions, milestones
export DISCORD_WEBHOOK_PROJECTS="https://discord.com/api/webhooks/YOUR_PROJECTS_WEBHOOK_URL"

# Daily Digest Channel - Morning health summary + nudges
export DISCORD_WEBHOOK_DAILY="https://discord.com/api/webhooks/YOUR_DAILY_WEBHOOK_URL"
```

Save and exit (Ctrl+X, Y, Enter).

## Step 5: Test Notifications

Test that webhooks are working:

```bash
# Test activity channel
~/scripts/pilot-deck/notify.sh activity "Test notification from Pilot Deck"

# Test alert channel
~/scripts/pilot-deck/notify.sh alert "Test alert from Pilot Deck"

# Test project channel
~/scripts/pilot-deck/notify.sh project "Test project update from Pilot Deck"
```

You should see notifications appear in your Discord server.

## Step 6: Run Health Check

Run the health check script to verify everything works:

```bash
~/scripts/pilot-deck/health-check.sh
```

If there are any issues, you'll see alerts in `#alerts`.

## Step 7: Set Up Discord Bot (Optional - For Two-Way Communication)

The bot allows you to run commands and get responses directly in Discord.

### Create Bot Application

1. Go to https://discord.com/developers/applications
2. Click **New Application** → Name it "Pilot Deck Bot"
3. Go to **Bot** section → Click **Add Bot**
4. Copy the **Bot Token** (you'll need this)

### Configure Bot Permissions

1. In the bot settings, go to **Privileged Gateway Intents**
2. Enable:
   - **Message Content Intent**
   - **Server Members Intent**
3. Save changes

### Invite Bot to Server

1. Go to **OAuth2** → **URL Generator**
2. Select scopes:
   - `bot`
   - `applications.commands`
3. Select bot permissions:
   - Send Messages
   - Read Message History
   - Read Messages/View Channels
   - Add Reactions
4. Copy the generated URL and open it in browser
5. Authorize the bot for your server

### Configure Bot on VPS

Add the bot token to your Discord config:

```bash
nano ~/.config/pilot-deck/discord.env
```

Add:
```bash
# Discord Bot Token (for two-way communication)
export DISCORD_BOT_TOKEN="your_bot_token_here"

# Optional: Restrict bot to specific channel ID
# export DISCORD_COMMAND_CHANNEL="your_channel_id"
```

To get a channel ID, right-click the channel in Discord and select "Copy ID".

### Install and Start Bot Service

```bash
# Install discord.py (already done)
pip3 install discord.py --break-system-packages

# Install systemd service
sudo cp /home/billz/scripts/pilot-deck/pilot-deck-bot.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pilot-deck-bot
sudo systemctl start pilot-deck-bot

# Check status
sudo systemctl status pilot-deck-bot
```

### Bot Commands

Once running, the bot responds to these commands in Discord:

| Command | Description |
|---------|-------------|
| `!health` | Show system health status |
| `!projects` | List all pilot-deck projects |
| `!logs [service]` | Show recent logs (caddy, health, notion) |
| `!backup [type]` | Run a backup (daily/weekly) |
| `!sync` | Sync projects to Notion |
| `!status` | Bot and system status |
| `!help` | Show help message |

### Alert Responses

Reply to any alert message with `?` to get more details about what went wrong.

## Next Steps

Once Discord is configured:

1. Enable cron jobs (see `CRON.md` for scheduled tasks)
2. Integrate notifications into backup scripts
3. Set up Notion integration (see `NOTION_SETUP.md`)

## Troubleshooting

### Webhook URL Not Working
- Verify the URL is complete (no truncation)
- Check that the webhook is enabled in Discord (not disabled)
- Ensure the channel still exists

### No Notifications Appearing
- Check that the `discord.env` file is being sourced correctly
- Test with `notify.sh` manually first
- Check script logs in `~/logs/` for errors

### Cron Jobs Not Running
- Verify cron entries with `crontab -l`
- Check cron logs: `sudo journalctl -u cron`
- Ensure scripts are executable: `chmod +x ~/scripts/pilot-deck/*.sh`

---

*Last updated: 2026-01-08*
