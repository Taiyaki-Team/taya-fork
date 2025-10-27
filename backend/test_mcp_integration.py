#!/usr/bin/env python3
"""
Test script for MCP integration
Tests both the backend API endpoints and MCP client functionality
"""
import asyncio
import sys
import requests
import json

# Test configuration
BASE_URL = "http://localhost:8000"  # Change to your backend URL
TEST_TOKEN = "your_auth_token_here"  # Replace with real token for authenticated tests

def test_available_integrations():
    """Test getting available integrations"""
    print("\n" + "="*60)
    print("TEST 1: Get Available Integrations")
    print("="*60)
    
    try:
        response = requests.get(f"{BASE_URL}/v1/integrations/available")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Found {len(data)} available integrations:")
            for integration in data:
                print(f"  - {integration['name']} ({integration['id']})")
                print(f"    Tools: {', '.join(integration['tools'][:3])}...")
            return True
        else:
            print(f"✗ Failed: {response.text}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False


def test_user_integrations():
    """Test getting user's connected integrations (requires auth)"""
    print("\n" + "="*60)
    print("TEST 2: Get User Integrations (requires auth)")
    print("="*60)
    
    if TEST_TOKEN == "your_auth_token_here":
        print("⚠ Skipped: No auth token provided")
        return None
    
    try:
        headers = {"Authorization": f"Bearer {TEST_TOKEN}"}
        response = requests.get(f"{BASE_URL}/v1/integrations", headers=headers)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✓ User has {len(data)} connected integrations")
            for integration in data:
                print(f"  - {integration['id']}: {integration['status']}")
            return True
        else:
            print(f"✗ Failed: {response.text}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False


def test_mcp_client():
    """Test MCP client directly"""
    print("\n" + "="*60)
    print("TEST 3: MCP Client Functionality")
    print("="*60)
    
    try:
        sys.path.insert(0, '.')
        from utils.mcp.client import mcp_client, MCP_AVAILABLE
        
        print(f"MCP_AVAILABLE: {MCP_AVAILABLE}")
        
        if not MCP_AVAILABLE:
            print("⚠ MCP SDK not installed - running in simulation mode")
            print("  Install with: pip install mcp or pip install fastmcp")
        
        # Test getting available servers
        servers = mcp_client.get_available_servers()
        print(f"✓ Found {len(servers)} configured servers:")
        for server in servers:
            print(f"  - {server['name']} ({server['id']})")
        
        # Test async connection
        async def test_connection():
            print("\n  Testing calendar connection...")
            result = await mcp_client.connect_server('calendar', {})
            print(f"  Connection result: {result}")
            
            if result:
                is_connected = mcp_client.is_server_connected('calendar')
                print(f"  Is connected: {is_connected}")
                
                tools = await mcp_client.list_tools('calendar')
                print(f"  Available tools: {len(tools)}")
                
                # Test tool execution (simulation mode)
                print("\n  Testing tool execution...")
                tool_result = await mcp_client.call_tool(
                    'calendar',
                    'create_event',
                    {
                        'title': 'Test Event',
                        'date': '2025-10-28',
                        'time': '14:00'
                    }
                )
                print(f"  Tool result: {tool_result}")
                
                # Disconnect
                await mcp_client.disconnect_server('calendar')
                print(f"  Disconnected successfully")
        
        asyncio.run(test_connection())
        return True
        
    except Exception as e:
        print(f"✗ Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_message_suggestions():
    """Test dynamic message suggestions endpoint"""
    print("\n" + "="*60)
    print("TEST 4: Dynamic Message Suggestions")
    print("="*60)
    
    if TEST_TOKEN == "your_auth_token_here":
        print("⚠ Skipped: No auth token provided")
        return None
    
    try:
        headers = {"Authorization": f"Bearer {TEST_TOKEN}"}
        response = requests.get(f"{BASE_URL}/v1/messages/suggestions", headers=headers)
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✓ Received {data['count']} suggestions:")
            for i, suggestion in enumerate(data['suggestions'], 1):
                print(f"  {i}. {suggestion}")
            return True
        else:
            print(f"✗ Failed: {response.text}")
            return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False


def main():
    """Run all tests"""
    print("\n" + "="*60)
    print("MCP INTEGRATION TEST SUITE")
    print("="*60)
    print(f"Testing backend at: {BASE_URL}")
    print(f"Auth token configured: {'Yes' if TEST_TOKEN != 'your_auth_token_here' else 'No'}")
    
    results = {
        "Available Integrations": test_available_integrations(),
        "User Integrations": test_user_integrations(),
        "MCP Client": test_mcp_client(),
        "Message Suggestions": test_message_suggestions(),
    }
    
    # Summary
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    
    for test_name, result in results.items():
        if result is True:
            status = "✓ PASSED"
        elif result is False:
            status = "✗ FAILED"
        else:
            status = "⚠ SKIPPED"
        print(f"{status:12} {test_name}")
    
    print("\n" + "="*60)
    print("RECOMMENDATIONS")
    print("="*60)
    
    if results["MCP Client"] and not MCP_AVAILABLE:
        print("• Install MCP SDK for real connections:")
        print("  pip install mcp")
        print("  or")
        print("  pip install fastmcp")
    
    if results["User Integrations"] is None:
        print("• Set TEST_TOKEN in this script to test authenticated endpoints")
        print("  Get token from your app after logging in")
    
    print("\n✓ Test suite complete!")


if __name__ == "__main__":
    main()

