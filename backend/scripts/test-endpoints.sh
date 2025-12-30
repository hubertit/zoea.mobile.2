#!/bin/bash

# Endpoint Testing Script
# Usage: ./test-endpoints.sh <JWT_TOKEN>

BASE_URL="https://zoea-africa.qtsoftwareltd.com/api"
TOKEN="${1:-}"

if [ -z "$TOKEN" ]; then
  echo "❌ Error: JWT token required"
  echo "Usage: ./test-endpoints.sh <JWT_TOKEN>"
  echo ""
  echo "To get a token, login via:"
  echo "  POST $BASE_URL/auth/login"
  exit 1
fi

echo "🧪 Testing Endpoints with Token"
echo "================================="
echo ""

# Test 1: GET /api/users/me/preferences
echo "📋 Test 1: GET /api/users/me/preferences"
echo "----------------------------------------"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BASE_URL/users/me/preferences")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Success!"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo "❌ Failed"
  echo "$BODY"
fi
echo ""
echo "Press Enter to continue to next test..."
read

