#!/bin/bash

# Restart Backend Services on Production Servers
# This script restarts the Docker containers on both primary and backup servers

set -e

PRIMARY_SERVER="qt@172.16.40.61"
BACKUP_SERVER="qt@172.16.40.60"
PASSWORD="Easy2Use$"
BACKEND_DIR="~/zoea-backend"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔄 Restart Backend Services          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to restart services on a server
restart_server() {
    local server=$1
    local server_name=$2
    
    echo -e "${YELLOW}🔄 Restarting services on $server_name ($server)...${NC}"
    
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$server" << 'EOF'
cd ~/zoea-backend

echo "📦 Current Docker container status:"
docker-compose ps

echo ""
echo "🛑 Stopping containers..."
docker-compose down

echo ""
echo "🚀 Starting containers..."
docker-compose up -d

echo ""
echo "⏳ Waiting 15 seconds for services to start..."
sleep 15

echo ""
echo "📊 Container status after restart:"
docker-compose ps

echo ""
echo "📋 Recent logs (last 20 lines):"
docker-compose logs --tail=20 api

echo ""
echo "🔍 Health check:"
docker inspect zoea-api --format='{{.State.Status}} - {{.State.Health.Status}}' 2>/dev/null || echo "Container not found"
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $server_name restarted successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ $server_name restart failed${NC}"
        return 1
    fi
}

# Restart Primary Server
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
restart_server "$PRIMARY_SERVER" "Primary Server"
PRIMARY_STATUS=$?
echo ""

# Restart Backup Server
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
restart_server "$BACKUP_SERVER" "Backup Server"
BACKUP_STATUS=$?
echo ""

# Verification
echo -e "${YELLOW}🔍 Verifying API health...${NC}"
echo ""

HEALTH_CHECK=$(curl -s --max-time 10 https://zoea-africa.qtsoftwareltd.com/api/health 2>&1)
if echo "$HEALTH_CHECK" | grep -q "ok\|status"; then
    echo -e "${GREEN}✅ API health check passed${NC}"
    echo "Response: $HEALTH_CHECK"
else
    echo -e "${YELLOW}⚠️  API health check returned: $HEALTH_CHECK${NC}"
    echo "This might be normal if services are still starting up..."
fi
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
if [ $PRIMARY_STATUS -eq 0 ] && [ $BACKUP_STATUS -eq 0 ]; then
    echo -e "${BLUE}║  ✅ Restart Complete!                 ║${NC}"
else
    echo -e "${BLUE}║  ⚠️  Restart Completed with Issues    ║${NC}"
fi
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Check API: https://zoea-africa.qtsoftwareltd.com/api/docs"
echo "2. Monitor logs: ssh qt@172.16.40.61 'cd ~/zoea-backend && docker-compose logs -f api'"
echo "3. Check container status: ssh qt@172.16.40.61 'cd ~/zoea-backend && docker-compose ps'"
echo ""

