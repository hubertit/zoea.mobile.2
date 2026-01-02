#!/bin/bash

# Script to remove duplicate accounts using direct database access
# Usage: ./remove-duplicates-db.sh <phone_pattern> [--execute]

PHONE_PATTERN="$1"
EXECUTE="$2"

if [ -z "$PHONE_PATTERN" ]; then
  echo "Usage: $0 <phone_pattern> [--execute]"
  echo "Example: $0 786375245"
  echo "Example: $0 786375245 --execute"
  exit 1
fi

# Load environment variables from .env if it exists
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL not set"
  exit 1
fi

# Extract connection details
DB_URL_REGEX="postgresql://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+)"
if [[ $DATABASE_URL =~ $DB_URL_REGEX ]]; then
  DB_USER="${BASH_REMATCH[1]}"
  DB_PASS="${BASH_REMATCH[2]}"
  DB_HOST="${BASH_REMATCH[3]}"
  DB_PORT="${BASH_REMATCH[4]}"
  DB_NAME="${BASH_REMATCH[5]}"
else
  echo "❌ Invalid DATABASE_URL format"
  exit 1
fi

export PGPASSWORD="$DB_PASS"

echo "🔍 Finding duplicate accounts for pattern: $PHONE_PATTERN"
echo ""

# Find all duplicates
DUPLICATES=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -A -F'|' <<EOF
SELECT 
  id,
  phone_number,
  COALESCE(email, '') as email,
  COALESCE(full_name, '') as full_name,
  created_at,
  CASE 
    WHEN email IS NOT NULL THEN 10 
    ELSE 0 
  END + 
  CASE 
    WHEN full_name IS NOT NULL THEN 5 
    ELSE 0 
  END as score
FROM users
WHERE phone_number LIKE '%$PHONE_PATTERN%'
   OR phone_number LIKE '%${PHONE_PATTERN#250}%'
ORDER BY 
  CASE WHEN email IS NOT NULL THEN 10 ELSE 0 END + 
  CASE WHEN full_name IS NOT NULL THEN 5 ELSE 0 END DESC,
  created_at ASC;
EOF
)

if [ -z "$DUPLICATES" ]; then
  echo "✅ No duplicates found"
  unset PGPASSWORD
  exit 0
fi

# Count duplicates
DUPLICATE_COUNT=$(echo "$DUPLICATES" | wc -l | tr -d ' ')
echo "Found $DUPLICATE_COUNT duplicate account(s):"
echo ""

# Display duplicates
IFS=$'\n'
KEEP_ID=""
KEEP_PHONE=""
DELETE_IDS=()
i=0

for line in $DUPLICATES; do
  IFS='|' read -r -a FIELDS <<< "$line"
  ID="${FIELDS[0]}"
  PHONE="${FIELDS[1]}"
  EMAIL="${FIELDS[2]}"
  NAME="${FIELDS[3]}"
  CREATED="${FIELDS[4]}"
  SCORE="${FIELDS[5]}"
  
  i=$((i + 1))
  echo "$i. Account $ID"
  echo "   Phone: $PHONE"
  echo "   Email: ${EMAIL:-N/A}"
  echo "   Name: ${NAME:-N/A}"
  echo "   Created: $CREATED"
  echo "   Score: $SCORE"
  echo ""
  
  if [ -z "$KEEP_ID" ]; then
    KEEP_ID="$ID"
    KEEP_PHONE="$PHONE"
    echo "   📌 This account will be KEPT (highest score)"
  else
    DELETE_IDS+=("$ID")
    echo "   🗑️  This account will be DELETED"
  fi
  echo ""
done

echo "📌 Account to KEEP: $KEEP_ID"
echo "   Phone: $KEEP_PHONE"
echo ""
echo "🗑️  Accounts to DELETE: ${#DELETE_IDS[@]}"
for id in "${DELETE_IDS[@]}"; do
  echo "   - $id"
done

if [ "$EXECUTE" != "--execute" ]; then
  echo ""
  echo "⚠️  DRY RUN MODE - No changes will be made"
  echo "   Run with --execute flag to actually delete duplicates"
  unset PGPASSWORD
  exit 0
fi

echo ""
echo "⚠️  EXECUTING DELETIONS..."
echo ""

# Delete each duplicate
for id in "${DELETE_IDS[@]}"; do
  echo "🗑️  Deleting account $id..."
  
  # Delete related data first
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -q <<EOF 2>&1 | grep -v "WARNING:" | grep -v "DETAIL:" | grep -v "HINT:"
    -- Delete carts
    DELETE FROM carts WHERE user_id = '$id'::uuid;
    
    -- Delete user sessions
    DELETE FROM user_sessions WHERE user_id = '$id'::uuid;
    
    -- Delete favorites
    DELETE FROM favorites WHERE user_id = '$id'::uuid;
    
    -- Delete reviews
    DELETE FROM reviews WHERE user_id = '$id'::uuid;
    
    -- Delete booking guests and bookings
    DELETE FROM booking_guests WHERE booking_id IN (SELECT id FROM bookings WHERE user_id = '$id'::uuid);
    DELETE FROM bookings WHERE user_id = '$id'::uuid;
    
    -- Delete order items and orders
    DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE user_id = '$id'::uuid);
    DELETE FROM orders WHERE user_id = '$id'::uuid;
    
    -- Delete transactions
    DELETE FROM transactions WHERE user_id = '$id'::uuid;
    
    -- Delete profiles
    DELETE FROM merchant_profiles WHERE user_id = '$id'::uuid;
    DELETE FROM organizer_profiles WHERE user_id = '$id'::uuid;
    DELETE FROM tour_operator_profiles WHERE user_id = '$id'::uuid;
    
    -- Delete zoea cards
    DELETE FROM zoea_cards WHERE user_id = '$id'::uuid;
    
    -- Finally delete the user
    DELETE FROM users WHERE id = '$id'::uuid;
EOF

  if [ $? -eq 0 ]; then
    echo "   ✅ Account deleted successfully"
  else
    echo "   ❌ Error deleting account"
  fi
  echo ""
done

echo "✅ All duplicate accounts deleted successfully!"
echo "   Kept account: $KEEP_ID ($KEEP_PHONE)"

unset PGPASSWORD

