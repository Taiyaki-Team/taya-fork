"""
MCP Client Manager for connecting to external MCP servers
"""
import asyncio
import os
import logging
from typing import Dict, Any, List, Optional

# Set up logger
logger = logging.getLogger(__name__)

try:
    from grpc_mcp_sdk import MCPClient
    MCP_AVAILABLE = True
except ImportError:
    try:
        from agents.mcp import MCPServerStdio
        MCP_AVAILABLE = True
    except ImportError:
        MCP_AVAILABLE = False
        logger.warning("MCP SDK not installed. MCP integrations will use simulation mode.")
        logger.warning("Install with: pip install grpc-mcp-sdk")


class McpClientManager:
    """Manages connections to external MCP servers"""
    
    def __init__(self):
        self.servers: Dict[str, Any] = {}
        self._server_configs = self._get_server_configs()
    
    def _get_server_configs(self) -> Dict[str, dict]:
        """Define available MCP server configurations"""
        return {
            'calendar': {
                'name': 'Calendar',
                'description': 'Create and manage calendar events',
                'command': 'npx',
                'args': ['-y', '@modelcontextprotocol/server-calendar'],
                'env': {},
                'tools': ['create_event', 'list_events', 'update_event', 'delete_event'],
            },
            'notion': {
                'name': 'Notion',
                'description': 'Save conversations to Notion pages',
                'command': 'npx',
                'args': ['-y', '@notionhq/mcp-server-notion'],
                'env': {},
                'tools': ['create_page', 'update_page', 'search', 'query_database'],
            },
            'slack': {
                'name': 'Slack',
                'description': 'Post messages to Slack channels',
                'command': 'npx',
                'args': ['-y', '@slack/mcp-server'],
                'env': {},
                'tools': ['post_message', 'list_channels', 'upload_file', 'add_reaction'],
            },
            'tasks': {
                'name': 'Task Manager',
                'description': 'Manage tasks in Todoist/Linear/Asana',
                'command': 'npx',
                'args': ['-y', '@todoist/mcp-server'],
                'env': {},
                'tools': ['create_task', 'list_projects', 'update_task', 'complete_task'],
            },
        }
    
    async def connect_server(self, server_id: str, user_config: Optional[dict] = None) -> bool:
        """
        Connect to an MCP server
        
        Args:
            server_id: ID of the server to connect to
            user_config: User-specific configuration (API keys, tokens, etc.)
        
        Returns:
            bool: True if connection successful
        """
        try:
            if server_id not in self._server_configs:
                logger.error(f"Unknown server ID: {server_id}")
                return False
            
            config = self._server_configs[server_id].copy()
            
            # Merge user config (API keys, etc.)
            if user_config:
                config['env'].update(user_config.get('env', {}))
            
            if MCP_AVAILABLE:
                # Use real MCP connection
                logger.info(f"Connecting to MCP server {server_id} with real connection")
                
                server = MCPServerStdio(
                    params={
                        "command": config['command'],
                        "args": config['args'],
                        "env": config['env'],
                    }
                )
                
                # Initialize the server connection
                await server.__aenter__()
                
                # Test connection by listing tools
                tools = await server.list_tools()
                logger.info(f"MCP server {server_id} connected successfully with {len(tools)} tools")
                
                self.servers[server_id] = {
                    'server': server,
                    'config': config,
                    'status': 'connected',
                    'connected_at': asyncio.get_event_loop().time(),
                    'tools': [tool.name for tool in tools],
                }
            else:
                # Simulation mode when MCP SDK not available
                logger.info(f"Server {server_id} connection simulated (agents-sdk not installed)")
                
                self.servers[server_id] = {
                    'config': config,
                    'status': 'connected',
                    'connected_at': asyncio.get_event_loop().time(),
                }
            
            return True
        except Exception as e:
            logger.error(f"Error connecting to server {server_id}: {e}")
            return False
    
    async def disconnect_server(self, server_id: str) -> bool:
        """Disconnect from an MCP server"""
        try:
            if server_id in self.servers:
                server_data = self.servers[server_id]
                
                # Close MCP server connection if using real MCP
                if MCP_AVAILABLE and 'server' in server_data:
                    try:
                        await server_data['server'].__aexit__(None, None, None)
                        logger.info(f"MCP server {server_id} connection closed")
                    except Exception as e:
                        logger.warning(f"Error closing MCP server connection: {e}")
                
                del self.servers[server_id]
                logger.info(f"Disconnected from server: {server_id}")
                return True
            return False
        except Exception as e:
            logger.error(f"Error disconnecting from server {server_id}: {e}")
            return False
    
    def is_server_connected(self, server_id: str) -> bool:
        """Check if a server is connected"""
        return server_id in self.servers and self.servers[server_id]['status'] == 'connected'
    
    def get_available_servers(self) -> List[dict]:
        """Get list of available MCP servers"""
        return [
            {
                'id': server_id,
                'name': config['name'],
                'description': config['description'],
                'tools': config['tools'],
            }
            for server_id, config in self._server_configs.items()
        ]
    
    async def list_tools(self, server_id: str) -> List[dict]:
        """List available tools from a server"""
        if server_id not in self._server_configs:
            return []
        
        if MCP_AVAILABLE and server_id in self.servers and 'server' in self.servers[server_id]:
            # Query real MCP server for tools
            try:
                server = self.servers[server_id]['server']
                tools = await server.list_tools()
                return [
                    {
                        'name': tool.name,
                        'description': tool.description if hasattr(tool, 'description') else f'{tool.name} tool',
                        'input_schema': tool.inputSchema if hasattr(tool, 'inputSchema') else {},
                    }
                    for tool in tools
                ]
            except Exception as e:
                logger.error(f"Error listing tools from server {server_id}: {e}")
        
        # Fallback to predefined tools
        return [
            {'name': tool, 'description': f'{tool} tool'}
            for tool in self._server_configs[server_id]['tools']
        ]
    
    async def call_tool(
        self,
        server_id: str,
        tool_name: str,
        arguments: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Call a tool on an MCP server
        
        Args:
            server_id: ID of the server
            tool_name: Name of the tool to call
            arguments: Tool arguments
        
        Returns:
            dict: Tool execution result
        """
        try:
            if not self.is_server_connected(server_id):
                return {
                    'success': False,
                    'error': f'Server {server_id} is not connected'
                }
            
            logger.info(f"Calling tool {tool_name} on server {server_id} with args: {arguments}")
            
            if MCP_AVAILABLE and 'server' in self.servers[server_id]:
                # Use real MCP tool calling
                server = self.servers[server_id]['server']
                
                try:
                    result = await server.call_tool(tool_name, arguments)
                    
                    logger.info(f"MCP tool {tool_name} executed successfully on {server_id}")
                    
                    return {
                        'success': True,
                        'result': result.content if hasattr(result, 'content') else result,
                        'data': arguments,
                    }
                except Exception as e:
                    logger.error(f"MCP tool execution failed: {e}")
                    return {
                        'success': False,
                        'error': f'Tool execution failed: {str(e)}'
                    }
            else:
                # Simulation mode
                logger.info(f"Tool {tool_name} executed in simulation mode")
                return {
                    'success': True,
                    'result': f'Tool {tool_name} executed successfully (simulation mode - install agents-sdk for real connections)',
                    'data': arguments,
                }
        except Exception as e:
            logger.error(f"Error calling tool {tool_name} on server {server_id}: {e}")
            return {
                'success': False,
                'error': str(e)
            }


# Global instance
mcp_client = McpClientManager()

