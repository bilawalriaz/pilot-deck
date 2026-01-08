# Cron Configuration for Pilot Deck

This file contains the cron job configuration for automated Pilot Deck tasks.

## Configuration

Add the following entries to your crontab:

```bash
# Edit crontab
crontab -e

# Add these lines:
# Pilot Deck - Daily Digest (08:00 daily)
0 8 * * * ~/.config/pilot-deck/daily-digest.sh >> ~/logs/cron-daily.log 2>&1

# Pilot Deck - Health Check (every 30 minutes)
*/30 * * * * ~/.config/pilot-deck/health-check.sh >> ~/logs/cron-health.log 2>&1

# Pilot Deck - Backup with Notifications (02:00 daily)
0 2 * * * ~/.config/pilot-deck/backup-wrapper.sh ~/scripts/backups/backup-daily.sh daily >> ~/logs/backup-daily-wrapper.log 2>&1

# Pilot Deck - Sync pilot-deck to GitHub (after daily backup, 04:30)
30 4 * * * (cd ~/pilot-deck && git add -A && git commit -m "Auto-sync: $(date +\%Y-\%m-\%d)" && git push) >> ~/logs/cron-sync.log 2>&1

# Pilot Deck - Notion sync (every 15 minutes)
*/15 * * * * ~/scripts/pilot-deck/notion-sync.sh export >> ~/logs/cron-notion.log 2>&1
```

## Cron Job Descriptions

| Time | Job | Description |
|------|-----|-------------|
| 02:00 | backup-daily.sh | Daily backup with Discord notifications |
| 04:30 | git sync | Push pilot-deck changes to GitHub |
| 08:00 | daily-digest.sh | Morning health summary + project nudges |
| */:15 | notion-sync.sh | Sync pilot-deck projects to Notion |
| */:30 | health-check.sh | System health monitoring (alerts on issues) |

## Applying Cron Jobs

**Option 1: Manual (recommended for first time)**
```bash
crontab -e
# Paste the entries above
# Save and exit
```

**Option 2: Automated (apply from file)**
```bash
# Create temp file with cron entries
cat > /tmp/pilot-deck-cron <<'EOF'
# Pilot Deck - Daily Digest (08:00 daily)
0 8 * * * ~/.config/pilot-deck/daily-digest.sh >> ~/logs/cron-daily.log 2>&1

# Pilot Deck - Health Check (every 30 minutes)
*/30 * * * * ~/.config/pilot-deck/health-check.sh >> ~/logs/cron-health.log 2>&1

# Pilot Deck - Backup with Notifications (02:00 daily)
0 2 * * * ~/.config/pilot-deck/backup-wrapper.sh ~/scripts/backups/backup-daily.sh daily >> ~/logs/backup-daily-wrapper.log 2>&1

# Pilot Deck - Sync pilot-deck to GitHub (after daily backup, 04:30)
30 4 * * * (cd ~/pilot-deck && git add -A && git commit -m "Auto-sync: $(date +\%Y-\%m-\%d)" && git push) >> ~/logs/cron-sync.log 2>&1

# Pilot Deck - Notion sync (every 15 minutes)
*/15 * * * * ~/scripts/pilot-deck/notion-sync.sh export >> ~/logs/cron-notion.log 2>&1
EOF

# Apply (will show current crontab first, then replace)
crontab /tmp/pilot-deck-cron
```

## Verifying Cron Jobs

After applying, verify:
```bash
crontab -l
```

## Testing Cron Jobs

Test each job manually before relying on automation:
```bash
# Test daily digest
~/.config/pilot-deck/daily-digest.sh

# Test health check
~/.config/pilot-deck/health-check.sh

# Test backup wrapper
~/.config/pilot-deck/backup-wrapper.sh ~/scripts/backups/backup-daily.sh daily

# Test git sync
(cd ~/pilot-deck && git add -A && git commit -m "Test sync" && git push)

# Test Notion sync
~/scripts/pilot-deck/notion-sync.sh export
```

## Cron Logs

Monitor cron job logs:
```bash
# Daily digest log
tail -f ~/logs/cron-daily.log

# Health check log
tail -f ~/logs/cron-health.log

# Backup wrapper log
tail -f ~/logs/backup-daily-wrapper.log

# Sync log
tail -f ~/logs/cron-sync.log

# Notion sync log
tail -f ~/logs/cron-notion.log
```

## Time Zones

Cron uses the server's local timezone. Verify:
```bash
timedatectl
# or
date
```

The Oracle VPS should be in CET (Central European Time).

## Troubleshooting

### Cron job not running
- Check crontab with `crontab -l`
- Verify scripts are executable: `chmod +x ~/.config/pilot-deck/*.sh`
- Check cron logs: `sudo journalctl -u cron`
- Ensure PATH includes necessary binaries in cron environment

### Discord notifications not appearing
- Verify webhooks are configured: `cat ~/.config/pilot-deck/discord.env`
- Test manually first: `~/.config/pilot-deck/notify.sh activity "test"`
- Check cron logs for errors

### Git sync failing
- Verify git config: `git config --global user.name` and `git config --global user.email`
- Test SSH auth to GitHub: `ssh -T git@github.com`
- Check pilot-deck is a git repo: `cd ~/pilot-deck && git status`

---

*Last updated: 2026-01-08*
