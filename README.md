# Bilawal's Pilot Deck

**Central command and control system for tracking projects, agent activity, and daily operations.**

**Owner:** Bilawal Riaz (bilawalriaz)
**VPS:** Oracle ARM VPS (agent.hyperflash.uk)
**Created:** 2026-01-08

---

## Purpose

This repository serves as the off-VPS record of all agent activity, project progress, and operational context. If the VPS disappears, this repo shows what was happening and what needs to be restored.

## Structure

```
pilot-deck/
├── README.md               # This file
├── projects/               # Project tracking with staged completion
│   ├── _template.md        # Copy this to start a new project
│   ├── infrastructure/     # VPS automation, backups, monitoring
│   ├── ml-ai/             # MedSmol-3B, experiments, RAG
│   ├── career/            # CV, portfolio, applications
│   ├── learning/          # Courses, tutorials, skills
│   └── side-projects/     # Personal tools, experiments
├── logs/                   # Agent activity logs
│   ├── daily/             # Daily activity summaries
│   └── incidents/         # Critical events and failures
├── todos/                  # Active task lists
│   ├── today.md           # Today's focus
│   ├── this-week.md       # Week plan
│   └── backlog.md         # Ideas and future work
└── journal/                # Progress notes, wins, blockers
    └── 2026/
        └── 01/            # January 2026 entries
```

## Project Stages

Each project follows four stages. Each stage is a valid stopping point worth celebrating:

| Stage | Name | Description |
|-------|------|-------------|
| 1 | MVP | Working code + README |
| 2 | Deployed | Accessible somewhere (even locally) |
| 3 | Written | Blog post / write-up drafted |
| 4 | Public | Portfolio entry on bilawal.net |

**Rule:** Never push for Stage 4 when Stage 1 isn't solid. Momentum matters more than perfection.

## Discord Integration

Notifications go to Discord channels:
- `#agent-activity` - Real-time actions and status
- `#alerts` - System problems, urgent items
- `#project-updates` - Stage completions, milestones
- `#daily-digest` - Morning health summary + nudges
- `#commands` - Bilawal sends commands here

## Backup & Sync

This repo is synced to GitHub daily as part of the backup routine. It provides:
- Off-VPS record of agent activity
- Project state tracking
- Recovery information if VPS needs rebuilding

## Related

- VPS Config: https://github.com/bilawalriaz/vps-config
- Portfolio: https://bilawal.net
- Dashboard: https://agent.hyperflash.uk

---

*Last updated: 2026-01-08*
