"""
API endpoints for managing user integrations with external services via MCP
"""
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException

from models.integration import (
    Integration,
    IntegrationConnection,
    IntegrationToolCall,
    IntegrationToolResult,
    IntegrationStatus,
)
from database.integrations import (
    get_user_integrations,
    get_user_integration,
    save_user_integration,
    delete_user_integration,
    update_integration_last_used,
)
from utils.mcp.client import mcp_client
from utils.other import endpoints as auth

router = APIRouter()


@router.get('/v1/integrations', tags=['integrations'], response_model=List[Integration])
def get_integrations(uid: str = Depends(auth.get_current_user_uid)):
    """Get all integrations for the current user"""
    return get_user_integrations(uid)


@router.get('/v1/integrations/available', tags=['integrations'])
def get_available_integrations():
    """Get list of available MCP integrations"""
    return mcp_client.get_available_servers()


@router.post('/v1/integrations/connect', tags=['integrations'])
async def connect_integration(
    connection: IntegrationConnection,
    uid: str = Depends(auth.get_current_user_uid)
):
    """Connect a user to an MCP integration"""
    try:
        # Connect to the MCP server
        success = await mcp_client.connect_server(
            connection.server_id,
            connection.config or {}
        )
        
        if not success:
            raise HTTPException(status_code=400, detail="Failed to connect to integration")
        
        # Save integration to database
        integration = Integration(
            id=connection.server_id,
            user_id=uid,
            status=IntegrationStatus.connected,
            config=connection.config,
            connected_at=datetime.now(timezone.utc),
        )
        
        save_user_integration(uid, integration)
        
        return {
            'success': True,
            'integration': integration,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post('/v1/integrations/{integration_id}/disconnect', tags=['integrations'])
async def disconnect_integration(
    integration_id: str,
    uid: str = Depends(auth.get_current_user_uid)
):
    """Disconnect a user from an MCP integration"""
    try:
        # Check if integration exists
        integration = get_user_integration(uid, integration_id)
        if not integration:
            raise HTTPException(status_code=404, detail="Integration not found")
        
        # Disconnect from MCP server
        await mcp_client.disconnect_server(integration_id)
        
        # Delete from database
        delete_user_integration(uid, integration_id)
        
        return {'success': True}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get('/v1/integrations/{integration_id}/tools', tags=['integrations'])
async def list_integration_tools(
    integration_id: str,
    uid: str = Depends(auth.get_current_user_uid)
):
    """List available tools for an integration"""
    try:
        # Check if user has this integration connected
        integration = get_user_integration(uid, integration_id)
        if not integration or integration.status != IntegrationStatus.connected:
            raise HTTPException(status_code=403, detail="Integration not connected")
        
        tools = await mcp_client.list_tools(integration_id)
        return {'tools': tools}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post('/v1/integrations/execute', tags=['integrations'], response_model=IntegrationToolResult)
async def execute_integration_tool(
    tool_call: IntegrationToolCall,
    uid: str = Depends(auth.get_current_user_uid)
):
    """Execute a tool on an MCP integration"""
    try:
        # Check if user has this integration connected
        integration = get_user_integration(uid, tool_call.server_id)
        if not integration or integration.status != IntegrationStatus.connected:
            raise HTTPException(status_code=403, detail="Integration not connected")
        
        # Execute the tool
        result = await mcp_client.call_tool(
            tool_call.server_id,
            tool_call.tool_name,
            tool_call.arguments
        )
        
        # Update last used timestamp
        update_integration_last_used(uid, tool_call.server_id)
        
        return IntegrationToolResult(
            success=result.get('success', False),
            result=result.get('result'),
            error=result.get('error'),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get('/v1/integrations/{integration_id}', tags=['integrations'], response_model=Integration)
def get_integration_details(
    integration_id: str,
    uid: str = Depends(auth.get_current_user_uid)
):
    """Get details of a specific integration"""
    integration = get_user_integration(uid, integration_id)
    if not integration:
        raise HTTPException(status_code=404, detail="Integration not found")
    
    return integration


