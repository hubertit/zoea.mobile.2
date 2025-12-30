#!/bin/bash

# Comprehensive Endpoint Testing Script
# Creates a user, logs in, and tests all endpoints

BASE_URL="https://zoea-africa.qtsoftwareltd.com/api"
TIMESTAMP=$(date +%s)
TEST_EMAIL="testuser${TIMESTAMP}@zoea.test"
TEST_PASSWORD="Test123456"
TEST_NAME="Test User ${TIMESTAMP}"

echo "🧪 Comprehensive Endpoint Testing"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Register a new user
echo -e "${BLUE}📝 Step 1: Registering new user...${NC}"
echo "Email: $TEST_EMAIL"
echo "Password: $TEST_PASSWORD"
echo ""

REGISTER_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"fullName\": \"$TEST_NAME\"
  }")

REGISTER_HTTP_CODE=$(echo "$REGISTER_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
REGISTER_BODY=$(echo "$REGISTER_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$REGISTER_HTTP_CODE" = "201" ] || [ "$REGISTER_HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ User registered successfully${NC}"
  echo "$REGISTER_BODY" | jq '.' 2>/dev/null || echo "$REGISTER_BODY"
  echo ""
else
  echo -e "${RED}❌ Registration failed (HTTP $REGISTER_HTTP_CODE)${NC}"
  echo "$REGISTER_BODY"
  echo ""
  echo "Trying to login with existing user..."
fi

# Step 2: Login to get token
echo -e "${BLUE}🔐 Step 2: Logging in...${NC}"
LOGIN_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"identifier\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

LOGIN_HTTP_CODE=$(echo "$LOGIN_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
LOGIN_BODY=$(echo "$LOGIN_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$LOGIN_HTTP_CODE" = "200" ]; then
  TOKEN=$(echo "$LOGIN_BODY" | jq -r '.accessToken' 2>/dev/null)
  if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    TOKEN=$(echo "$LOGIN_BODY" | jq -r '.token' 2>/dev/null)
  fi
  
  if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo -e "${GREEN}✅ Login successful${NC}"
    echo "Token: ${TOKEN:0:50}..."
    echo ""
  else
    echo -e "${RED}❌ No token in response${NC}"
    echo "$LOGIN_BODY"
    exit 1
  fi
else
  echo -e "${RED}❌ Login failed (HTTP $LOGIN_HTTP_CODE)${NC}"
  echo "$LOGIN_BODY"
  exit 1
fi

# Step 3: Test GET /api/users/me/preferences
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 Test 1: GET /api/users/me/preferences${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BASE_URL/users/me/preferences")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo ""
  echo "Response Structure:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo -e "${RED}❌ Failed${NC}"
  echo "$BODY"
fi
echo ""
read -p "Press Enter to continue to next test..."

# Step 4: Test PUT /api/users/me/preferences
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 Test 2: PUT /api/users/me/preferences${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

UPDATE_DATA='{
  "countryOfOrigin": "KE",
  "userType": "visitor",
  "visitPurpose": "business",
  "ageRange": "26-35",
  "gender": "male",
  "lengthOfStay": "4-7 days",
  "travelParty": "solo",
  "preferredLanguage": "en",
  "preferredCurrency": "KES"
}'

echo "Updating with:"
echo "$UPDATE_DATA" | jq '.'
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X PUT "$BASE_URL/users/me/preferences" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$UPDATE_DATA")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo ""
  echo "Response Structure:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo -e "${RED}❌ Failed${NC}"
  echo "$BODY"
fi
echo ""
read -p "Press Enter to continue to next test..."

# Step 5: Test GET /api/users/me/preferences again (verify update)
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Test 3: GET /api/users/me/preferences (Verify Update)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BASE_URL/users/me/preferences")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo ""
  echo "Updated Preferences:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
  
  # Verify specific fields
  echo ""
  echo "Field Verification:"
  echo "$BODY" | jq -r 'if .countryOfOrigin == "KE" then "✅ countryOfOrigin: " + .countryOfOrigin else "❌ countryOfOrigin: " + (.countryOfOrigin // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .userType == "visitor" then "✅ userType: " + .userType else "❌ userType: " + (.userType // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .visitPurpose == "business" then "✅ visitPurpose: " + .visitPurpose else "❌ visitPurpose: " + (.visitPurpose // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .ageRange == "26-35" then "✅ ageRange: " + .ageRange else "❌ ageRange: " + (.ageRange // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .gender == "male" then "✅ gender: " + .gender else "❌ gender: " + (.gender // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .lengthOfStay == "4-7 days" then "✅ lengthOfStay: " + .lengthOfStay else "❌ lengthOfStay: " + (.lengthOfStay // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .travelParty == "solo" then "✅ travelParty: " + .travelParty else "❌ travelParty: " + (.travelParty // "null") end' 2>/dev/null
  echo "$BODY" | jq -r 'if .calculatedAgeRange then "✅ calculatedAgeRange: " + .calculatedAgeRange else "⚠️  calculatedAgeRange: not present" end' 2>/dev/null
  echo "$BODY" | jq -r 'if .ageRangeSource then "✅ ageRangeSource: " + .ageRangeSource else "⚠️  ageRangeSource: not present" end' 2>/dev/null
else
  echo -e "${RED}❌ Failed${NC}"
  echo "$BODY"
fi
echo ""
read -p "Press Enter to continue to next test..."

# Step 6: Test GET /api/users/me/preferences/completion-status
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Test 4: GET /api/users/me/preferences/completion-status${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BASE_URL/users/me/preferences/completion-status")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo ""
  echo "Completion Status:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo -e "${RED}❌ Failed${NC}"
  echo "$BODY"
fi
echo ""
read -p "Press Enter to continue to next test..."

# Step 7: Test GET /api/users/me/profile/completion
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📈 Test 5: GET /api/users/me/profile/completion${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BASE_URL/users/me/profile/completion")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo ""
  echo "Profile Completion:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo -e "${RED}❌ Failed${NC}"
  echo "$BODY"
fi
echo ""
read -p "Press Enter to continue to next test..."

# Step 8: Test POST /api/analytics/events
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 Test 6: POST /api/analytics/events${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

ANALYTICS_DATA='{
  "events": [
    {
      "type": "listing_view",
      "data": {
        "listingId": "123e4567-e89b-12d3-a456-426614174000",
        "category": "Accommodation",
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
      }
    },
    {
      "type": "search",
      "data": {
        "query": "hotel in Kigali",
        "category": "Accommodation",
        "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
      }
    }
  ],
  "sessionId": "test_session_'$TIMESTAMP'",
  "deviceType": "ios",
  "os": "iOS 17.0",
  "appVersion": "2.0.0"
}'

echo "Sending analytics events:"
echo "$ANALYTICS_DATA" | jq '.'
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "$BASE_URL/analytics/events" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$ANALYTICS_DATA")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo -e "${GREEN}✅ Success!${NC}"
  echo ""
  echo "Analytics Response:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo -e "${RED}❌ Failed${NC}"
  echo "$BODY"
fi
echo ""

# Summary
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Testing Complete!${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Test User Created:"
echo "  Email: $TEST_EMAIL"
echo "  Password: $TEST_PASSWORD"
echo ""
echo "Token (for manual testing):"
echo "  $TOKEN"
echo ""

