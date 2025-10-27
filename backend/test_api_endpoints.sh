#!/bin/bash
# Test MCP API endpoints
# Usage: ./test_api_endpoints.sh <base_url> [auth_token]

BASE_URL="${1:-http://localhost:8000}"
AUTH_TOKEN="${2:-}"

echo "========================================"
echo "MCP API ENDPOINT TESTS"
echo "========================================"
echo "Backend URL: $BASE_URL"
echo

# Test 1: Get available integrations (no auth needed)
echo "Test 1: GET /v1/integrations/available"
echo "----------------------------------------"
curl -s "$BASE_URL/v1/integrations/available" | python3 -m json.tool || echo "Failed"
echo

# Test 2: Get user integrations (requires auth)
if [ -n "$AUTH_TOKEN" ]; then
    echo "Test 2: GET /v1/integrations (with auth)"
    echo "----------------------------------------"
    curl -s -H "Authorization: Bearer $AUTH_TOKEN" \
         "$BASE_URL/v1/integrations" | python3 -m json.tool || echo "Failed"
    echo
    
    # Test 3: Get message suggestions (requires auth)
    echo "Test 3: GET /v1/messages/suggestions (with auth)"
    echo "----------------------------------------"
    curl -s -H "Authorization: Bearer $AUTH_TOKEN" \
         "$BASE_URL/v1/messages/suggestions" | python3 -m json.tool || echo "Failed"
    echo
else
    echo "Test 2 & 3: Skipped (no auth token)"
    echo "Provide auth token as second argument to test authenticated endpoints"
    echo
fi

# Test 4: Health check (if exists)
echo "Test 4: GET /health or /"
echo "----------------------------------------"
curl -s "$BASE_URL/" | head -20 || echo "Root endpoint not available"
echo

echo "========================================"
echo "Tests complete!"
echo "========================================"
echo
echo "To test authenticated endpoints:"
echo "  ./test_api_endpoints.sh $BASE_URL YOUR_AUTH_TOKEN"

