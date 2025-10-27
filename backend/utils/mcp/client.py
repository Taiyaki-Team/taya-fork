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
    from mcp import ClientSession, StdioServerParameters
    from mcp.client.stdio import stdio_client
    MCP_AVAILABLE = True
    logger.info("MCP SDK loaded successfully - real MCP connections enabled")
except ImportError:
    MCP_AVAILABLE = False
    logger.error("=" * 60)
    logger.error("MCP SDK NOT INSTALLED - MCP integrations will NOT work")
    logger.error("Real MCP SDK is required. Simulation mode is disabled.")
    logger.error("Install with: pip install mcp")
    logger.error("=" * 60)


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
        Connect to an MCP server (requires real MCP SDK)
        
        Args:
            server_id: ID of the server to connect to
            user_config: User-specific configuration (API keys, tokens, etc.)
        
        Returns:
            bool: True if connection successful
        
        Raises:
            RuntimeError: If MCP SDK is not installed
        """
        if not MCP_AVAILABLE:
            error_msg = "MCP SDK not installed. Real MCP connections required. Install with: pip install mcp"
            logger.error(error_msg)
            raise RuntimeError(error_msg)
        
        try:
            if server_id not in self._server_configs:
                logger.error(f"Unknown server ID: {server_id}")
                return False
            
            config = self._server_configs[server_id].copy()
            
            # Merge user config (API keys, etc.)
            if user_config:
                config['env'].update(user_config.get('env', {}))
            
            # Use real MCP connection
            logger.info(f"Connecting to MCP server {server_id} with real MCP SDK")
            
            # Use official MCP SDK
            server_params = StdioServerParameters(
                command=config['command'],
                args=config['args'],
                env=config['env']
            )
            
            # Create stdio client context
            async with stdio_client(server_params) as (read, write):
                async with ClientSession(read, write) as session:
                    # Initialize connection
                    await session.initialize()
                    
                    # List available tools
                    tools_result = await session.list_tools()
                    tools = tools_result.tools if hasattr(tools_result, 'tools') else []
                    
                    logger.info(f"MCP server {server_id} connected successfully with {len(tools)} tools")
                    
                    self.servers[server_id] = {
                        'session': session,
                        'config': config,
                        'status': 'connected',
                        'connected_at': asyncio.get_event_loop().time(),
                        'tools': [tool.name for tool in tools],
                    }
            
            return True
        except Exception as e:
            logger.error(f"Error connecting to server {server_id}: {e}")
            return False
    
    async def disconnect_server(self, server_id: str) -> bool:
        """
        Disconnect from an MCP server
        
        Raises:
            RuntimeError: If MCP SDK is not installed
        """
        if not MCP_AVAILABLE:
            raise RuntimeError("MCP SDK not installed. Install with: pip install mcp")
        
        try:
            if server_id in self.servers:
                server_data = self.servers[server_id]
                
                # Close MCP session if exists
                session = server_data.get('session')
                if session:
                    try:
                        await session.__aexit__(None, None, None)
                        logger.info(f"MCP server {server_id} session closed")
                    except Exception as e:
                        logger.warning(f"Error closing MCP session: {e}")
                
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
        """
        List available tools from a server (requires real MCP SDK)
        
        Raises:
            RuntimeError: If MCP SDK is not installed or server not connected
        """
        if not MCP_AVAILABLE:
            raise RuntimeError("MCP SDK not installed. Install with: pip install mcp")
        
        if server_id not in self._server_configs:
            raise ValueError(f"Unknown server ID: {server_id}")
        
        if server_id not in self.servers:
            raise RuntimeError(f"Server {server_id} is not connected. Call connect_server first.")
        
        try:
            # Get tools from connected MCP session
            session = self.servers[server_id].get('session')
            if not session:
                # Return cached tools if available
                return [
                    {'name': tool, 'description': f'{tool} tool'}
                    for tool in self.servers[server_id].get('tools', [])
                ]
            
            tools_result = await session.list_tools()
            tools = tools_result.tools if hasattr(tools_result, 'tools') else []
            
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
            raise
    
    async def call_tool(
        self,
        server_id: str,
        tool_name: str,
        arguments: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Call a tool on an MCP server (requires real MCP SDK)
        
        Args:
            server_id: ID of the server
            tool_name: Name of the tool to call
            arguments: Tool arguments
        
        Returns:
            dict: Tool execution result
            
        Raises:
            RuntimeError: If MCP SDK is not installed or server not connected
        """
        if not MCP_AVAILABLE:
            raise RuntimeError("MCP SDK not installed. Install with: pip install mcp")
        
        if not self.is_server_connected(server_id):
            return {
                'success': False,
                'error': f'Server {server_id} is not connected'
            }
        
        try:
            logger.info(f"Calling tool {tool_name} on server {server_id} with args: {arguments}")
            
            session = self.servers[server_id].get('session')
            if not session:
                raise RuntimeError(f"No active session for server {server_id}")
            
            # Call tool using real MCP SDK
            result = await session.call_tool(tool_name, arguments)
            
            logger.info(f"MCP tool {tool_name} executed successfully on {server_id}")
            
            return {
                'success': True,
                'result': result.content if hasattr(result, 'content') else result,
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

