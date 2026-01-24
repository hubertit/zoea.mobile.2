#!/bin/bash

# Zoea Admin Panel Deployment Script
# This script builds and deploys the admin panel to the production server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVER_PRIMARY="root@159.198.65.38"
SERVER_BACKUP="root@159.198.65.38"
REMOTE_DIR="/root/zoea-admin"
ADMIN_PORT="${ADMIN_PORT:-3010}"
API_BASE="${NEXT_PUBLIC_API_BASE:-http://172.16.40.61:3000/api}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Zoea Admin Panel Deployment${NC}"
echo -e "${GREEN}========================================${NC}"

# Function to check if server is reachable
check_server() {
    local server=$1
    echo -e "${YELLOW}Checking connection to $server...${NC}"
    if sshpass -p 'QF87VtuYReX5v9p6e3' ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$server" "echo 'Connected'" &> /dev/null; then
        echo -e "${GREEN}✓ Connected to $server${NC}"
        return 0
    else
        echo -e "${RED}✗ Cannot connect to $server${NC}"
        return 1
    fi
}

# Determine which server to use
if check_server "$SERVER_PRIMARY"; then
    SERVER="$SERVER_PRIMARY"
    echo -e "${GREEN}Using primary server: $SERVER${NC}"
elif check_server "$SERVER_BACKUP"; then
    SERVER="$SERVER_BACKUP"
    echo -e "${GREEN}Using backup server: $SERVER${NC}"
else
    echo -e "${RED}Error: Cannot connect to any server${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "  1. VPN connection is active"
    echo "  2. Server IP addresses are correct"
    echo "  3. SSH keys are properly configured"
    exit 1
fi

# Step 1: Create deployment package (matching resolveit pattern - build on server)
echo -e "\n${YELLOW}Step 1: Creating deployment package...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create tarball excluding unnecessary files (like resolveit)
tar --exclude='node_modules' --exclude='.next' --exclude='dist' \
    --exclude='.git' --exclude='*.log' --exclude='.env*' \
    --exclude='deploy-*' --exclude='admin-deploy.tar.gz' \
    -czf /tmp/admin-deploy.tar.gz .

# Step 2: Sync to server
echo -e "\n${YELLOW}Step 2: Syncing to server...${NC}"
sshpass -p 'QF87VtuYReX5v9p6e3' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$SERVER" "mkdir -p $REMOTE_DIR"
sshpass -p 'QF87VtuYReX5v9p6e3' scp -o StrictHostKeyChecking=no -o PreferredAuthentications=password /tmp/admin-deploy.tar.gz "$SERVER:/tmp/"
sshpass -p 'QF87VtuYReX5v9p6e3' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$SERVER" "cd $REMOTE_DIR && rm -rf * && tar xzf /tmp/admin-deploy.tar.gz && rm /tmp/admin-deploy.tar.gz"

# Create .env file on server (matching resolveit pattern)
sshpass -p 'QF87VtuYReX5v9p6e3' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$SERVER" <<EOF
cd $REMOTE_DIR
cat > .env.admin <<'ENVEOF'
# Admin Panel Configuration
ADMIN_PORT=$ADMIN_PORT
NEXT_PUBLIC_API_BASE=$API_BASE
NODE_ENV=production
ENVEOF
EOF

rm -f /tmp/admin-deploy.tar.gz

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Sync failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Files synced to server${NC}"

# Step 3: Deploy on server
echo -e "\n${YELLOW}Step 3: Deploying on server...${NC}"
sshpass -p 'QF87VtuYReX5v9p6e3' ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$SERVER" <<'ENDSSH'
cd /root/zoea-admin

# Ensure network exists (same pattern as resolveit)
docker network create zoea-network 2>/dev/null || true

# Check if port is already in use
if netstat -tulpn | grep -q ":3010 "; then
    echo "Port 3010 is in use. Stopping existing container..."
    docker compose -f docker-compose.admin.yml down
fi

# Build and start the container (without --no-cache for better caching, like resolveit)
echo "Building Docker image..."
docker compose -f docker-compose.admin.yml --env-file .env.admin build

echo "Starting admin panel..."
docker compose -f docker-compose.admin.yml --env-file .env.admin up -d

# Wait for container to be healthy
echo "Waiting for admin panel to be ready..."
for i in {1..30}; do
    if docker compose -f docker-compose.admin.yml ps | grep -q "healthy"; then
        echo "✓ Admin panel is healthy"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Show container status
echo ""
echo "Container status:"
docker compose -f docker-compose.admin.yml ps

# Show logs
echo ""
echo "Recent logs:"
docker compose -f docker-compose.admin.yml logs --tail=20
ENDSSH

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Deployment failed${NC}"
    exit 1
fi

# Step 4: Health check
echo -e "\n${YELLOW}Step 4: Running health check...${NC}"
SERVER_IP=$(echo "$SERVER" | cut -d'@' -f2)
sleep 5

if curl -f -s "http://$SERVER_IP:$ADMIN_PORT" > /dev/null; then
    echo -e "${GREEN}✓ Admin panel is accessible${NC}"
else
    echo -e "${YELLOW}⚠ Admin panel might not be ready yet. Check manually.${NC}"
fi

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Admin Panel URL: ${GREEN}http://$SERVER_IP:$ADMIN_PORT${NC}"
echo -e "API Base URL: ${GREEN}$API_BASE${NC}"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "  View logs:    ssh $SERVER 'cd $REMOTE_DIR && docker compose -f docker-compose.admin.yml logs -f'"
echo "  Restart:      ssh $SERVER 'cd $REMOTE_DIR && docker compose -f docker-compose.admin.yml restart'"
echo "  Stop:         ssh $SERVER 'cd $REMOTE_DIR && docker compose -f docker-compose.admin.yml down'"
echo "  Check status: ssh $SERVER 'cd $REMOTE_DIR && docker compose -f docker-compose.admin.yml ps'"

