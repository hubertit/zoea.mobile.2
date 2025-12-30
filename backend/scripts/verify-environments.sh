#!/bin/bash

# Quick verification script to check if all environments have the same codebase

PRIMARY_SERVER="qt@172.16.40.61"
BACKUP_SERVER="qt@172.16.40.60"
PASSWORD="Easy2Use$"
BACKEND_DIR="~/zoea-backend"
LOCAL_DIR="/Applications/AMPPS/www/zoea-2/backend"

echo "🔍 Verifying Codebase Across All Environments"
echo "=============================================="
echo ""

# Check localhost
echo "📋 Localhost:"
cd "$LOCAL_DIR"
LOCAL_FILES=$(find src/modules/admin -type f 2>/dev/null | wc -l | tr -d ' ')
LOCAL_COMMIT=$(git log -1 --pretty=format:"%h" 2>/dev/null || echo "N/A")
echo "  Admin files: $LOCAL_FILES"
echo "  Latest commit: $LOCAL_COMMIT"
echo ""

# Check primary server
echo "📋 Primary Server (172.16.40.61):"
PRIMARY_FILES=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$PRIMARY_SERVER" \
    "cd $BACKEND_DIR && find src/modules/admin -type f 2>/dev/null | wc -l" 2>/dev/null | tr -d ' ' || echo "Connection failed")
PRIMARY_COMMIT=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$PRIMARY_SERVER" \
    "cd $BACKEND_DIR && git log -1 --pretty=format:'%h' 2>/dev/null" 2>/dev/null || echo "N/A")
echo "  Admin files: $PRIMARY_FILES"
echo "  Latest commit: $PRIMARY_COMMIT"
echo ""

# Check backup server
echo "📋 Backup Server (172.16.40.60):"
BACKUP_FILES=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$BACKUP_SERVER" \
    "cd $BACKEND_DIR && find src/modules/admin -type f 2>/dev/null | wc -l" 2>/dev/null | tr -d ' ' || echo "Connection failed")
BACKUP_COMMIT=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$BACKUP_SERVER" \
    "cd $BACKEND_DIR && git log -1 --pretty=format:'%h' 2>/dev/null" 2>/dev/null || echo "N/A")
echo "  Admin files: $BACKUP_FILES"
echo "  Latest commit: $BACKUP_COMMIT"
echo ""

# Summary
echo "=============================================="
if [ "$LOCAL_FILES" = "$PRIMARY_FILES" ] && [ "$LOCAL_FILES" = "$BACKUP_FILES" ] && [ "$LOCAL_FILES" != "Connection failed" ]; then
    echo "✅ All environments have the same number of admin files"
else
    echo "⚠️  Environments may be out of sync"
    echo ""
    echo "Run ./sync-all-environments.sh to synchronize"
fi
echo "=============================================="

