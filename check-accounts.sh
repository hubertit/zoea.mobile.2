#!/bin/bash

# Script to check if test accounts exist in the database via API

BASE_URL="${API_URL:-https://zoea-africa.qtsoftwareltd.com/api}"

echo "🔍 Checking test accounts via API..."
echo "API URL: $BASE_URL"
echo ""

# Check super admin account
echo "1. Checking Super Admin Account:"
echo "   Email: hubert@zoea.africa"
echo "   Phone: 250788606765"
echo ""

# Try to login (this will tell us if the account exists)
echo "   Attempting login with email..."
LOGIN_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "hubert@zoea.africa",
    "password": "test"
  }')

HTTP_CODE=$(echo "$LOGIN_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$LOGIN_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
  echo "   ✅ Account exists and login successful!"
  echo "$BODY" | jq -r '.user | "      ID: \(.id)\n      Email: \(.email)\n      Phone: \(.phoneNumber)\n      Name: \(.fullName)\n      Roles: \(.roles)"' 2>/dev/null || echo "$BODY"
elif [ "$HTTP_CODE" = "401" ]; then
  echo "   ✅ Account exists but password is incorrect"
  echo "   (This means the account is registered)"
elif [ "$HTTP_CODE" = "404" ]; then
  echo "   ❌ Account not found"
else
  echo "   ⚠️  HTTP $HTTP_CODE: $BODY"
fi

echo ""
echo "2. To check merchant accounts, you need to:"
echo "   - Login as admin"
echo "   - Go to Users page in admin portal"
echo "   - Search for users with MERCHANT role"
echo ""
echo "3. To create a test merchant account:"
echo "   - Login as super admin"
echo "   - Go to Users → Create User"
echo "   - Assign MERCHANT role"
echo ""

