#!/bin/bash

# Check for similar phone numbers
PHONE="$1"

if [ -z "$PHONE" ]; then
  echo "Usage: $0 <phone_number>"
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

echo "🔍 Searching for similar phone numbers: $PHONE"
echo ""

# Remove country code and search
PHONE_SHORT="${PHONE#250}"
if [ "$PHONE_SHORT" != "$PHONE" ]; then
  echo "Searching with format: $PHONE_SHORT (without country code)"
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT phone_number, email, full_name, created_at FROM users WHERE phone_number LIKE '%$PHONE_SHORT%' LIMIT 10;" 2>&1 | grep -v "WARNING:" | grep -v "DETAIL:" | grep -v "HINT:"
fi

echo ""
echo "Searching with format: $PHONE (full number)"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT phone_number, email, full_name, created_at FROM users WHERE phone_number LIKE '%$PHONE%' LIMIT 10;" 2>&1 | grep -v "WARNING:" | grep -v "DETAIL:" | grep -v "HINT:"

unset PGPASSWORD

