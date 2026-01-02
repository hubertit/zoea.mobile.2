#!/bin/bash

# Script to check if an account exists in the database using direct psql access
# Usage: ./check-account-db.sh <phone|email|username|id>

if [ -z "$1" ]; then
  echo "Usage: $0 <phone|email|username|id>"
  exit 1
fi

IDENTIFIER="$1"

# Load environment variables from .env if it exists
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Parse DATABASE_URL if set, otherwise use defaults
if [ -z "$DATABASE_URL" ]; then
  echo "❌ DATABASE_URL not set. Please set it in .env file or environment."
  echo "   Example: DATABASE_URL=postgresql://user:password@host:5432/database"
  exit 1
fi

# Extract connection details from DATABASE_URL
# Format: postgresql://user:password@host:port/database
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

echo "🔍 Checking account in database: $IDENTIFIER"
echo "   Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo ""

# Set password for psql
export PGPASSWORD="$DB_PASS"

# Query the database
QUERY_RESULT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -A -F'|' <<EOF
SELECT 
  id,
  COALESCE(email, 'N/A') as email,
  COALESCE(phone_number, 'N/A') as phone_number,
  COALESCE(username, 'N/A') as username,
  COALESCE(full_name, 'N/A') as full_name,
  roles::text,
  is_active,
  is_verified,
  created_at,
  COALESCE(last_login_at::text, 'Never') as last_login_at
FROM users
WHERE phone_number = '$IDENTIFIER'
   OR email = '$IDENTIFIER'
   OR username = '$IDENTIFIER'
   OR id::text = '$IDENTIFIER'
LIMIT 1;
EOF
)

if [ -z "$QUERY_RESULT" ] || [ "$QUERY_RESULT" = "" ]; then
  echo "❌ Account not found in database"
  echo "   Searched by: phone number, email, username, and ID"
  
  # Get total user count
  USER_COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -A <<EOF
SELECT COUNT(*) FROM users;
EOF
)
  echo ""
  echo "   Total users in database: $USER_COUNT"
else
  # Parse the result (pipe-separated)
  IFS='|' read -r -a FIELDS <<< "$QUERY_RESULT"
  
  echo "✅ Account found in database!"
  echo ""
  echo "Account Details:"
  echo "   ID: ${FIELDS[0]}"
  echo "   Email: ${FIELDS[1]}"
  echo "   Phone: ${FIELDS[2]}"
  echo "   Username: ${FIELDS[3]}"
  echo "   Full Name: ${FIELDS[4]}"
  echo "   Roles: ${FIELDS[5]}"
  echo "   Active: ${FIELDS[6]}"
  echo "   Verified: ${FIELDS[7]}"
  echo "   Created: ${FIELDS[8]}"
  echo "   Last Login: ${FIELDS[9]}"
fi

# Unset password
unset PGPASSWORD

