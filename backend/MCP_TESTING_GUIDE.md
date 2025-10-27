# MCP Integration Testing Guide

## Current Status

⚠️ **MCP requires real SDK - simulation mode DISABLED** 
- Backend code: ✓ Deployed
- API endpoints: ✓ Available
- Mode: **REAL ONLY** - MCP SDK required (mcp>=1.0.0)
- Without SDK: API will return errors

## Quick Tests

### 1. Test Local Backend

```bash
cd backend
python3 -c "
import sys; sys.path.insert(0, '.')
from utils.mcp.client import mcp_client
import asyncio

async def test():
    result = await mcp_client.connect_server('calendar', {})
    print(f'Connection: {result}')
    tool_result = await mcp_client.call_tool('calendar', 'create_event', 
        {'title': 'Test', 'date': '2025-10-28'})
    print(f'Tool result: {tool_result}')

asyncio.run(test())
"
```

### 2. Test API Endpoints

**Test without auth** (works right away):
```bash
cd backend
./test_api_endpoints.sh https://your-backend-url.railway.app
```

**Test with auth** (requires login token):
```bash
./test_api_endpoints.sh https://your-backend-url.railway.app YOUR_AUTH_TOKEN
```

### 3. Test from Flutter App

1. Run the app: `flutter run --flavor prod`
2. Go to **Apps/Integrations** page
3. You should see:
   - Calendar
   - Notion
   - Slack
   - Task Manager
4. Tap "Connect" on any integration
5. Check Railway logs for connection attempt

## How to Get Real MCP (Not Simulation)

The deployment will automatically install `mcp` package from requirements.txt.

Once deployed, Railway will:
1. Install `mcp>=1.0.0` from PyPI
2. Enable real MCP SDK connections
3. Allow actual tool execution

Check Railway logs for:
- ✅ `MCP SDK installed successfully`
- ✅ `MCP_AVAILABLE: True`

## Testing Real Connections

### Calendar Integration

```bash
# From your Flutter app or API:
POST /v1/integrations/connect
{
  "server_id": "calendar",
  "config": {
    "env": {
      "GOOGLE_API_KEY": "your_key_here"
    }
  }
}
```

### Notion Integration

```bash
POST /v1/integrations/connect
{
  "server_id": "notion",
  "config": {
    "env": {
      "NOTION_TOKEN": "your_token_here"
    }
  }
}
```

## Troubleshooting

### Issue: "MCP SDK not installed"

**Cause**: `mcp` package not installed
**Solution**: 
```bash
pip install mcp
```

### Issue: "Connection failed"

**Cause**: Missing API keys or config
**Solution**: Provide proper config when connecting:
```json
{
  "server_id": "calendar",
  "config": {
    "env": {
      "API_KEY": "your_actual_key"
    }
  }
}
```

### Issue: "Tool execution returns simulation mode"

**Cause**: Real MCP SDK not available
**Check**: 
```python
from utils.mcp.client import MCP_AVAILABLE
print(MCP_AVAILABLE)  # Should be True
```

## What's Working Right Now

✅ Backend deployed with MCP support  
✅ API endpoints available  
✅ Dynamic message suggestions  
✅ Integration connection management  
⚠️ **Real MCP SDK required** - No simulation fallback  
🔄 MCP SDK installing on Railway deployment  

## Expected Behavior

### Without MCP SDK (mcp not installed)
- ✗ API returns error: "MCP SDK not installed"
- ✗ Cannot connect to integrations
- ✗ Integration endpoints throw RuntimeError

### With MCP SDK (mcp installed)
- ✓ Connects to real MCP servers
- ✓ Lists real tools  
- ✓ Creates actual calendar events
- ✓ Posts to real Slack channels
- ✓ Saves to real Notion pages
- ✓ Creates real tasks

## Check Deployment Status

```bash
# Check Railway logs
railway logs --service backend

# Look for:
# "Successfully installed mcp-1.x.x"
# "MCP SDK loaded successfully"
```

## Next Steps

1. Wait for Railway deployment to complete
2. Check logs for MCP SDK installation
3. Test API endpoints with `./test_api_endpoints.sh`
4. Try connecting an integration from Flutter app
5. Check Railway logs for connection attempts
6. If simulation mode appears, check if `mcp` installed correctly

## Support

If issues persist:
1. Check Railway deployment logs
2. Verify `mcp` in pip freeze output
3. Test locally: `pip install mcp` then run tests
4. Check API responses for error messages

