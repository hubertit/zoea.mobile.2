#!/bin/bash

# Test Password Reset Endpoints
# This script tests all password reset endpoints

set -e

API_BASE_URL="https://zoea-africa.qtsoftwareltd.com/api"
# For local testing, use: API_BASE_URL="http://localhost:3000/api"

echo "🧪 Testing Password Reset Endpoints"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test email (use a test user that exists)
TEST_EMAIL="test@example.com"
TEST_PHONE="250788606765"
RESET_CODE="0000"

echo -e "${YELLOW}1. Testing Request Password Reset (Email)...${NC}"
RESPONSE=$(curl -s -X POST "$API_BASE_URL/auth/password/reset/request" \
  -H "Content-Type: application/json" \
  -d "{\"identifier\": \"$TEST_EMAIL\"}" \
  -w "\nHTTP_STATUS:%{http_code}")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Request reset (email) - SUCCESS${NC}"
  echo "Response: $BODY"
else
  echo -e "${RED}❌ Request reset (email) - FAILED (Status: $HTTP_STATUS)${NC}"
  echo "Response: $BODY"
fi

echo ""
echo -e "${YELLOW}2. Testing Request Password Reset (Phone)...${NC}"
RESPONSE=$(curl -s -X POST "$API_BASE_URL/auth/password/reset/request" \
  -H "Content-Type: application/json" \
  -d "{\"identifier\": \"$TEST_PHONE\"}" \
  -w "\nHTTP_STATUS:%{http_code}")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Request reset (phone) - SUCCESS${NC}"
  echo "Response: $BODY"
else
  echo -e "${RED}❌ Request reset (phone) - FAILED (Status: $HTTP_STATUS)${NC}"
  echo "Response: $BODY"
fi

echo ""
echo -e "${YELLOW}3. Testing Verify Reset Code...${NC}"
RESPONSE=$(curl -s -X POST "$API_BASE_URL/auth/password/reset/verify" \
  -H "Content-Type: application/json" \
  -d "{\"identifier\": \"$TEST_EMAIL\", \"code\": \"$RESET_CODE\"}" \
  -w "\nHTTP_STATUS:%{http_code}")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Verify code - SUCCESS${NC}"
  echo "Response: $BODY"
else
  echo -e "${RED}❌ Verify code - FAILED (Status: $HTTP_STATUS)${NC}"
  echo "Response: $BODY"
fi

echo ""
echo -e "${YELLOW}4. Testing Reset Password...${NC}"
RESPONSE=$(curl -s -X POST "$API_BASE_URL/auth/password/reset" \
  -H "Content-Type: application/json" \
  -d "{\"identifier\": \"$TEST_EMAIL\", \"code\": \"$RESET_CODE\", \"newPassword\": \"newPassword123\"}" \
  -w "\nHTTP_STATUS:%{http_code}")

HTTP_STATUS=$(echo "$RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
  echo -e "${GREEN}✅ Reset password - SUCCESS${NC}"
  echo "Response: $BODY"
else
  echo -e "${RED}❌ Reset password - FAILED (Status: $HTTP_STATUS)${NC}"
  echo "Response: $BODY"
fi

echo ""
echo -e "${GREEN}✅ Password reset endpoint tests completed!${NC}"

