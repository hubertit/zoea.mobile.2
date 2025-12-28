#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api"
TOKEN_FILE="/tmp/admin_token.txt"

# Get token
echo -e "${YELLOW}🔐 Getting admin token...${NC}"
TOKEN=$(curl -s -X POST ${BASE_URL}/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@zoea.africa","password":"Pass12"}' | jq -r '.accessToken')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo -e "${RED}❌ Failed to get token${NC}"
  exit 1
fi

echo "$TOKEN" > $TOKEN_FILE
echo -e "${GREEN}✅ Token obtained${NC}\n"

# Test function
test_endpoint() {
  local method=$1
  local endpoint=$2
  local data=$3
  local description=$4
  
  echo -e "${YELLOW}Testing: ${description}${NC}"
  echo "  ${method} ${endpoint}"
  
  if [ -n "$data" ]; then
    response=$(curl -s -w "\n%{http_code}" -X ${method} "${BASE_URL}${endpoint}" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "${data}")
  else
    response=$(curl -s -w "\n%{http_code}" -X ${method} "${BASE_URL}${endpoint}" \
      -H "Authorization: Bearer ${TOKEN}")
  fi
  
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')
  
  if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
    echo -e "${GREEN}  ✅ Success (${http_code})${NC}"
    echo "$body" | jq '.' 2>/dev/null | head -10 || echo "$body" | head -5
  else
    echo -e "${RED}  ❌ Failed (${http_code})${NC}"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
  fi
  echo ""
}

# ============================================
# 1. USERS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}1. TESTING USERS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/users?page=1&limit=10" "" "List users"
test_endpoint "GET" "/admin/users?page=1&limit=10&search=admin" "" "List users with search"
test_endpoint "GET" "/admin/users?page=1&limit=10&isActive=true" "" "List active users"

# Get a user ID (we'll use the admin user)
USER_ID=$(curl -s -X GET "${BASE_URL}/admin/users?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$USER_ID" ] && [ "$USER_ID" != "null" ]; then
  test_endpoint "GET" "/admin/users/${USER_ID}" "" "Get user by ID"
  test_endpoint "PATCH" "/admin/users/${USER_ID}/status" '{"isActive":true,"isBlocked":false}' "Update user status"
  test_endpoint "PATCH" "/admin/users/${USER_ID}/roles" '{"roles":["admin","explorer"]}' "Update user roles"
fi

# ============================================
# 2. MERCHANTS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}2. TESTING MERCHANTS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/merchants?page=1&limit=10" "" "List merchants"
test_endpoint "GET" "/admin/merchants?page=1&limit=10&isVerified=true" "" "List verified merchants"

# Get a merchant ID
MERCHANT_ID=$(curl -s -X GET "${BASE_URL}/admin/merchants?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$MERCHANT_ID" ] && [ "$MERCHANT_ID" != "null" ]; then
  test_endpoint "GET" "/admin/merchants/${MERCHANT_ID}" "" "Get merchant by ID"
  test_endpoint "PATCH" "/admin/merchants/${MERCHANT_ID}/status" '{"registrationStatus":"approved","isVerified":true}' "Update merchant status"
  test_endpoint "PATCH" "/admin/merchants/${MERCHANT_ID}/settings" '{"isVerified":true,"commissionRate":15.0}' "Update merchant settings"
fi

# Create a new merchant (if we have a user ID)
if [ -n "$USER_ID" ] && [ "$USER_ID" != "null" ]; then
  CREATE_MERCHANT_DATA=$(cat <<EOF
{
  "userId": "${USER_ID}",
  "businessName": "Test Merchant Admin Created",
  "businessType": "restaurant",
  "description": "Created by admin API test",
  "businessPhone": "+1234567890",
  "businessEmail": "testmerchant@example.com",
  "address": "123 Test St"
}
EOF
)
  CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/admin/merchants" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${CREATE_MERCHANT_DATA}")
  
  NEW_MERCHANT_ID=$(echo "$CREATE_MERCHANT_DATA" | jq -r '.id // empty' 2>/dev/null || echo "$CREATE_RESPONSE" | jq -r '.id // empty')
  
  test_endpoint "POST" "/admin/merchants" "${CREATE_MERCHANT_DATA}" "Create merchant"
  
  # If creation succeeded, test update and delete
  if [ -n "$NEW_MERCHANT_ID" ] && [ "$NEW_MERCHANT_ID" != "null" ]; then
    UPDATE_MERCHANT_DATA='{"businessName":"Updated Test Merchant","description":"Updated by admin"}'
    test_endpoint "PUT" "/admin/merchants/${NEW_MERCHANT_ID}" "${UPDATE_MERCHANT_DATA}" "Update merchant"
    test_endpoint "DELETE" "/admin/merchants/${NEW_MERCHANT_ID}" "" "Delete merchant (soft)"
    test_endpoint "PATCH" "/admin/merchants/${NEW_MERCHANT_ID}/restore" "" "Restore merchant"
  fi
fi

# ============================================
# 3. LISTINGS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}3. TESTING LISTINGS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/listings?page=1&limit=10" "" "List listings"
test_endpoint "GET" "/admin/listings?page=1&limit=10&status=active" "" "List active listings"

# Get a listing ID
LISTING_ID=$(curl -s -X GET "${BASE_URL}/admin/listings?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$LISTING_ID" ] && [ "$LISTING_ID" != "null" ]; then
  test_endpoint "GET" "/admin/listings/${LISTING_ID}" "" "Get listing by ID"
  test_endpoint "PATCH" "/admin/listings/${LISTING_ID}/status" '{"status":"active"}' "Update listing status"
fi

# Create a new listing (if we have a merchant ID)
if [ -n "$MERCHANT_ID" ] && [ "$MERCHANT_ID" != "null" ]; then
  CREATE_LISTING_DATA=$(cat <<EOF
{
  "merchantId": "${MERCHANT_ID}",
  "name": "Test Listing Admin Created",
  "description": "Created by admin API test",
  "type": "restaurant",
  "status": "draft"
}
EOF
)
  test_endpoint "POST" "/admin/listings" "${CREATE_LISTING_DATA}" "Create listing"
  
  # Get the created listing ID
  NEW_LISTING_ID=$(curl -s -X GET "${BASE_URL}/admin/listings?page=1&limit=1&search=Test Listing Admin" \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')
  
  if [ -n "$NEW_LISTING_ID" ] && [ "$NEW_LISTING_ID" != "null" ]; then
    UPDATE_LISTING_DATA='{"name":"Updated Test Listing","description":"Updated by admin"}'
    test_endpoint "PUT" "/admin/listings/${NEW_LISTING_ID}" "${UPDATE_LISTING_DATA}" "Update listing"
    test_endpoint "DELETE" "/admin/listings/${NEW_LISTING_ID}" "" "Delete listing (soft)"
    test_endpoint "PATCH" "/admin/listings/${NEW_LISTING_ID}/restore" "" "Restore listing"
  fi
fi

# ============================================
# 4. BOOKINGS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}4. TESTING BOOKINGS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/bookings?page=1&limit=10" "" "List bookings"
test_endpoint "GET" "/admin/bookings?page=1&limit=10&status=pending" "" "List pending bookings"

# Get a booking ID
BOOKING_ID=$(curl -s -X GET "${BASE_URL}/admin/bookings?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$BOOKING_ID" ] && [ "$BOOKING_ID" != "null" ]; then
  test_endpoint "GET" "/admin/bookings/${BOOKING_ID}" "" "Get booking by ID"
  test_endpoint "PATCH" "/admin/bookings/${BOOKING_ID}/status" '{"status":"confirmed"}' "Update booking status"
fi

# Create a new booking (if we have user ID and listing ID)
if [ -n "$USER_ID" ] && [ "$USER_ID" != "null" ] && [ -n "$LISTING_ID" ] && [ "$LISTING_ID" != "null" ]; then
  CREATE_BOOKING_DATA=$(cat <<EOF
{
  "userId": "${USER_ID}",
  "bookingType": "restaurant",
  "listingId": "${LISTING_ID}",
  "bookingDate": "2025-12-01T00:00:00Z",
  "bookingTime": "19:00",
  "guestCount": 2,
  "guests": [
    {
      "fullName": "Test Guest",
      "email": "guest@example.com"
    }
  ]
}
EOF
)
  test_endpoint "POST" "/admin/bookings" "${CREATE_BOOKING_DATA}" "Create booking"
fi

# ============================================
# 5. PAYMENTS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}5. TESTING PAYMENTS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/payments/transactions?page=1&limit=10" "" "List transactions"
test_endpoint "GET" "/admin/payments/transactions?page=1&limit=10&status=completed" "" "List completed transactions"

# Get a transaction ID
TRANSACTION_ID=$(curl -s -X GET "${BASE_URL}/admin/payments/transactions?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$TRANSACTION_ID" ] && [ "$TRANSACTION_ID" != "null" ]; then
  test_endpoint "GET" "/admin/payments/transactions/${TRANSACTION_ID}" "" "Get transaction by ID"
  test_endpoint "PATCH" "/admin/payments/transactions/${TRANSACTION_ID}/status" '{"status":"completed"}' "Update transaction status"
fi

test_endpoint "GET" "/admin/payments/payouts?page=1&limit=10" "" "List payouts"
test_endpoint "GET" "/admin/payments/payouts?page=1&limit=10&status=pending" "" "List pending payouts"

# Get a payout ID
PAYOUT_ID=$(curl -s -X GET "${BASE_URL}/admin/payments/payouts?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$PAYOUT_ID" ] && [ "$PAYOUT_ID" != "null" ]; then
  test_endpoint "GET" "/admin/payments/payouts/${PAYOUT_ID}" "" "Get payout by ID"
  test_endpoint "PATCH" "/admin/payments/payouts/${PAYOUT_ID}/status" '{"status":"processing"}' "Update payout status"
fi

# ============================================
# 6. EVENTS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}6. TESTING EVENTS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/events?page=1&limit=10" "" "List events"
test_endpoint "GET" "/admin/events?page=1&limit=10&status=published" "" "List published events"

# Get an event ID
EVENT_ID=$(curl -s -X GET "${BASE_URL}/admin/events?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$EVENT_ID" ] && [ "$EVENT_ID" != "null" ]; then
  test_endpoint "GET" "/admin/events/${EVENT_ID}" "" "Get event by ID"
  test_endpoint "PATCH" "/admin/events/${EVENT_ID}/status" '{"status":"published"}' "Update event status"
fi

# Create a new event (if we have an organizer profile ID)
ORGANIZER_ID=$(curl -s -X GET "${BASE_URL}/admin/events/3c54aad0-3127-429d-bacd-a60ff0b73763" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.organizerId // empty')

if [ -n "$ORGANIZER_ID" ] && [ "$ORGANIZER_ID" != "null" ]; then
  CREATE_EVENT_DATA=$(cat <<EOF
{
  "organizerId": "${ORGANIZER_ID}",
  "name": "Test Event Admin Created",
  "description": "Created by admin API test",
  "startDate": "2025-12-15T18:00:00Z",
  "endDate": "2025-12-15T22:00:00Z",
  "address": "Test Venue Address",
  "privacy": "public",
  "setup": "in_person"
}
EOF
)
  test_endpoint "POST" "/admin/events" "${CREATE_EVENT_DATA}" "Create event"
  
  # Get the created event ID
  NEW_EVENT_ID=$(curl -s -X GET "${BASE_URL}/admin/events?page=1&limit=1" \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[] | select(.name | contains("Test Event Admin")) | .id // empty' | head -1)
  
  if [ -n "$NEW_EVENT_ID" ] && [ "$NEW_EVENT_ID" != "null" ]; then
    UPDATE_EVENT_DATA='{"name":"Updated Test Event","description":"Updated by admin"}'
    test_endpoint "PUT" "/admin/events/${NEW_EVENT_ID}" "${UPDATE_EVENT_DATA}" "Update event"
    test_endpoint "DELETE" "/admin/events/${NEW_EVENT_ID}" "" "Delete event (soft)"
    test_endpoint "PATCH" "/admin/events/${NEW_EVENT_ID}/restore" "" "Restore event"
  fi
fi

# ============================================
# 7. NOTIFICATIONS ENDPOINTS
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}7. TESTING NOTIFICATIONS ENDPOINTS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

test_endpoint "GET" "/admin/notifications/requests?page=1&limit=10" "" "List notification requests"
test_endpoint "GET" "/admin/notifications/requests?page=1&limit=10&status=pending" "" "List pending notification requests"

# Get a notification request ID
NOTIF_REQUEST_ID=$(curl -s -X GET "${BASE_URL}/admin/notifications/requests?page=1&limit=1" \
  -H "Authorization: Bearer ${TOKEN}" | jq -r '.data[0].id // empty')

if [ -n "$NOTIF_REQUEST_ID" ] && [ "$NOTIF_REQUEST_ID" != "null" ]; then
  test_endpoint "PATCH" "/admin/notifications/requests/${NOTIF_REQUEST_ID}/status" '{"status":"approved"}' "Approve notification request"
fi

# Create a broadcast
BROADCAST_DATA='{"title":"Admin Test Broadcast","body":"This is a test broadcast from admin API","targetType":"all"}'
test_endpoint "POST" "/admin/notifications/broadcast" "${BROADCAST_DATA}" "Create broadcast notification"

# ============================================
# SUMMARY
# ============================================
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ All endpoint tests completed!${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

