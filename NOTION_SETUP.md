# Notion Integration Guide for Pilot Deck

This guide documents the Notion integration setup for tablet-friendly project editing and bidirectional sync.

## Status: Scaffolded

The Notion integration is **scaffolded but not implemented**. This means:
- The structure is designed
- The API requirements are documented
- Placeholder scripts exist
- **Manual setup required** to enable sync

## Why Notion?

Notion provides:
- Tablet-friendly interface for editing projects on the go
- Rich text editing for project notes
- Database views for filtering and sorting projects
- Mobile app access
- Collaborative editing (if needed)

## Database Structure

Create a Notion database with the following properties:

### Projects Database

| Property | Type | Notes |
|----------|------|-------|
| Name | Title | Project name |
| Category | Select | infrastructure, ml-ai, career, learning, side-project |
| Stage | Select | 1-MVP, 2-Deployed, 3-Written, 4-Public |
| Started | Date | Start date |
| Last Touched | Date | Last modified date |
| One-Liner | Text | Brief description |
| Current State | Text | What works right now |
| Next Step | Text | Single smallest action |
| Repository | URL | GitHub repo link |
| Live URL | URL | Deployed instance link |
| Done Checklist | Checkbox | Multi-select for stages |

### Journal Database

| Property | Type | Notes |
|----------|------|-------|
| Date | Title | Entry date (YYYY-MM-DD) |
| Progress | Text | What was accomplished |
| Decisions | Text | Key decisions made |
| Next Steps | Text | What's next |
| Notes | Text | Freeform context |

### Todos Database

| Property | Type | Notes |
|----------|------|-------|
| Task | Title | Task description |
| Status | Select | pending, in_progress, completed |
| Priority | Select | high, medium, low |
| Category | Select | today, this-week, backlog |
| Due Date | Date | Optional due date |

## API Setup Steps

### 1. Create Notion Integration

1. Go to https://www.notion.so/my-integrations
2. Click **New Integration**
3. Name it: `Pilot Deck Sync`
4. Associated workspace: Select your workspace
5. Type: **Internal**
6. Click **Submit**
7. Copy the **Internal Integration Token** (secret)

### 2. Share Databases with Integration

For each database you create:

1. Open the database in Notion
2. Click **...** (top right) > **Add connections**
3. Select **Pilot Deck Sync**
4. Click **Confirm**

### 3. Configure on VPS

SSH into your VPS and add the integration token:

```bash
# Add to Discord config (or create separate Notion config)
nano ~/.config/pilot-deck/notion.env
```

```bash
# Notion API Configuration
export NOTION_API_KEY="your_integration_token_here"
export NOTION_PROJECTS_DB_ID="projects_database_id"
export NOTION_JOURNAL_DB_ID="journal_database_id"
export NOTION_TODOS_DB_ID="todos_database_id"
```

**Finding Database IDs:**
1. Open a database in Notion
2. The URL contains the database ID: `https://notion.so/workspace/[DATABASE_ID]?v=...`
3. Copy the 32-character ID (including dashes)

## Placeholder Scripts

The following scripts are scaffolded but not implemented:

- `~/scripts/pilot-deck/notion-sync.sh` - Bidirectional sync
- `~/scripts/pilot-deck/notion-export.sh` - Export Pilot Deck to Notion
- `~/scripts/pilot-deck/notion-import.sh` - Import Notion changes to Pilot Deck

## Implementation Roadmap

When ready to implement:

1. **Install Notion CLI** (or use curl with API)
   ```bash
   npm install -g notion-client
   # OR use Python: pip install notion-client
   ```

2. **Create sync script** that:
   - Reads Pilot Deck markdown files
   - Creates/updates Notion database entries
   - Pulls changes from Notion back to markdown

3. **Set up sync schedule** (e.g., every 15 minutes via cron)

4. **Handle conflicts** (Pilot Deck is source of truth for now)

## Current Workflow

Until Notion integration is implemented:

- Edit projects directly in markdown at `~/pilot-deck/projects/`
- Commit changes to git for backup
- Use Discord for notifications
- Tablet editing: SSH in via Termius or similar

## Notion API Resources

- Notion API Docs: https://developers.notion.com/reference
- Python SDK: https://github.com/ramnes/notion-sdk-py
- Node.js SDK: https://github.com/microsoftgraph/msgraph-sdk-npm

---

*Last updated: 2026-01-08*
