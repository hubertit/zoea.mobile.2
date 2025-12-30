#!/bin/bash

# Sync Zoea Backend Codebase Across All Environments
# This script ensures localhost, primary server, and backup server have identical code

set -e

PRIMARY_SERVER="qt@172.16.40.61"
BACKUP_SERVER="qt@172.16.40.60"
PASSWORD="Easy2Use$"
BACKEND_DIR="~/zoea-backend"
LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔄 Syncing Zoea Backend Across All Environments"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to sync to server
sync_to_server() {
    local SERVER=$1
    local SERVER_NAME=$2
    
    echo -e "${YELLOW}📤 Syncing to ${SERVER_NAME}...${NC}"
    
    # Create directory if it doesn't exist
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER" "mkdir -p $BACKEND_DIR" || true
    
    # Sync files (excluding node_modules, dist, .git, etc.)
    rsync -avz --progress \
        -e "sshpass -p '$PASSWORD' ssh -o StrictHostKeyChecking=no" \
        --exclude 'node_modules' \
        --exclude 'dist' \
        --exclude '.git' \
        --exclude '.DS_Store' \
        --exclude '*.log' \
        --exclude '.env' \
        --exclude 'coverage' \
        --exclude '.nyc_output' \
        "$LOCAL_DIR/" "$SERVER:$BACKEND_DIR/" 2>&1 | tail -20
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ${SERVER_NAME} synced successfully${NC}"
    else
        echo -e "${RED}❌ Failed to sync to ${SERVER_NAME}${NC}"
        exit 1
    fi
}

# Sync to primary server
sync_to_server "$PRIMARY_SERVER" "Primary Server"

# Sync to backup server
sync_to_server "$BACKUP_SERVER" "Backup Server"

echo ""
echo -e "${GREEN}✅ All environments synced successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. SSH into each server"
echo "2. Navigate to $BACKEND_DIR"
echo "3. Run: docker-compose down && docker-compose up --build -d"
