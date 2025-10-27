# Backend Integration Setup Guide

## Overview

The backend now supports MCP (Model Context Protocol) integrations for Calendar, Notion, Slack, and Task Management.

## Quick Start

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

This will install:
- `agents-sdk` - For real MCP server connections
- All other existing dependencies

### 2. Run Backend

```bash
# Development mode
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Or with modal (if using modal deployment)
modal serve main.py
```

### 3. Test Integration Endpoints

```bash
# Get available integrations
curl http://localhost:8000/v1/integrations/available

# Connect to calendar (requires auth token)
curl -X POST http://localhost:8000/v1/integrations/connect \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"server_id": "calendar", "config": {}}'

# List user's integrations
curl http://localhost:8000/v1/integrations \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Integration Status

### ✅ Ready to Use (Simulation Mode)
Without `agents-sdk`, integrations work in simulation mode:
- All API endpoints functional
- Database operations working
- Frontend UI fully functional
- Simulated tool execution for testing

### 🚀 Production Mode (Real MCP)
After installing `agents-sdk`:
- Real MCP server connections
- Actual tool execution
- Calendar events created
- Notion pages saved
- Slack messages sent
- Tasks created

## Available Integrations

### 1. 📅 Calendar
**MCP Server:** `@modelcontextprotocol/server-calendar`
**Tools:**
- `create_event` - Create calendar events
- `list_events` - List upcoming events
- `update_event` - Modify events
- `delete_event` - Remove events

**Setup:** User needs Google Calendar OAuth

### 2. 📝 Notion
**MCP Server:** `@notionhq/mcp-server-notion`
**Tools:**
- `create_page` - Create Notion pages
- `update_page` - Update pages
- `search` - Search workspace
- `query_database` - Query databases

**Setup:** User needs Notion integration token

### 3. 💬 Slack
**MCP Server:** `@slack/mcp-server`
**Tools:**
- `post_message` - Post to channels
- `list_channels` - List channels
- `upload_file` - Upload files
- `add_reaction` - Add reactions

**Setup:** User needs Slack app OAuth

### 4. ✅ Task Manager
**MCP Server:** `@todoist/mcp-server`
**Tools:**
- `create_task` - Create tasks
- `list_projects` - List projects
- `update_task` - Update tasks
- `complete_task` - Complete tasks

**Setup:** User needs Todoist API token

## Database Schema

User integrations are stored in Firestore:

```
users/
  {uid}/
    integrations/
      {integration_id}/
        status: "connected" | "not_connected" | "error"
        config: {...}  # User-specific config (API keys, tokens)
        connected_at: timestamp
        last_used_at: timestamp
        error_message: string (optional)
```

## API Endpoints

### GET /v1/integrations
Get user's connected integrations

**Response:**
```json
[
  {
    "id": "calendar",
    "user_id": "user123",
    "status": "connected",
    "config": {...},
    "connected_at": "2025-10-24T...",
    "last_used_at": "2025-10-24T..."
  }
]
```

### GET /v1/integrations/available
List available MCP integrations

**Response:**
```json
[
  {
    "id": "calendar",
    "name": "Calendar",
    "description": "Create and manage calendar events",
    "tools": ["create_event", "list_events", ...]
  }
]
```

### POST /v1/integrations/connect
Connect an integration

**Request:**
```json
{
  "server_id": "calendar",
  "config": {
    "env": {
      "GOOGLE_API_KEY": "...",
      "CALENDAR_ID": "..."
    }
  }
}
```

**Response:**
```json
{
  "success": true,
  "integration": {...}
}
```

### POST /v1/integrations/{id}/disconnect
Disconnect an integration

**Response:**
```json
{
  "success": true
}
```

### POST /v1/integrations/execute
Execute an MCP tool

**Request:**
```json
{
  "server_id": "calendar",
  "tool_name": "create_event",
  "arguments": {
    "title": "Team Meeting",
    "date": "2025-10-25",
    "time": "14:00",
    "duration": "1h"
  }
}
```

**Response:**
```json
{
  "success": true,
  "result": {...},
  "error": null
}
```

## Enabling Real MCP Connections

### Option 1: Install agents-sdk (Recommended)

```bash
pip install agents-sdk
```

The system will automatically detect and use real MCP connections.

### Option 2: Manual MCP Server Installation

For each integration, install the corresponding MCP server:

```bash
# Calendar
npm install -g @modelcontextprotocol/server-calendar

# Notion
npm install -g @notionhq/mcp-server-notion

# Slack
npm install -g @slack/mcp-server

# Todoist
npm install -g @todoist/mcp-server
```

## Environment Variables

Add to your `.env` file:

```bash
# Optional: Pre-configure API keys for MCP servers
GOOGLE_CALENDAR_API_KEY=your_key_here
NOTION_API_TOKEN=your_token_here
SLACK_BOT_TOKEN=your_token_here
TODOIST_API_TOKEN=your_token_here
```

## Testing

### Test Location Tracking
1. Start a phone mic recording in the app
2. Check backend logs for: `Location captured: [address]`
3. Location data is attached to conversation

### Test Integration Connection
1. Go to Integrations page in app
2. Tap on Calendar
3. Tap "Connect Calendar"
4. Check backend logs for connection status
5. Verify in database: `users/{uid}/integrations/calendar`

### Test Tool Execution
1. Connect an integration
2. Call execute endpoint:
```bash
curl -X POST http://localhost:8000/v1/integrations/execute \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "server_id": "calendar",
    "tool_name": "create_event",
    "arguments": {
      "title": "Test Event",
      "date": "2025-10-25"
    }
  }'
```

## Troubleshooting

### "agents-sdk not installed" warning
- This is normal if you haven't installed the package yet
- System works in simulation mode
- Install with: `pip install agents-sdk`

### MCP server connection fails
- Check Node.js is installed: `node --version`
- Check MCP server is installed: `npx @modelcontextprotocol/server-calendar --version`
- Check environment variables are set

### Integration not showing as connected
- Check database: Firestore Console → users/{uid}/integrations
- Check backend logs for errors
- Verify auth token is valid

## Development Mode vs Production

**Development (Simulation):**
- No `agents-sdk` required
- All endpoints work
- Simulated tool execution
- Great for UI testing

**Production (Real MCP):**
- Install `agents-sdk`
- Real MCP server connections
- Actual tool execution
- OAuth flows for each service

## Next Steps

1. ✅ Backend is set up and running
2. 📱 Test in the Flutter app
3. 🔗 Install agents-sdk for real connections
4. 🔐 Add OAuth flows for each service
5. 🎯 Start using integrations!

## Support

If you encounter issues:
1. Check backend logs
2. Verify database entries
3. Test API endpoints directly
4. Check MCP server installation


