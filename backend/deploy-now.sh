#!/bin/bash

# Quick Deployment Script for Ask Zoea Feature
# This script deploys to both primary and backup servers

set -e

PRIMARY_SERVER="qt@172.16.40.61"
BACKUP_SERVER="qt@172.16.40.60"
PASSWORD="Easy2Use$"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 Ask Zoea Feature Deployment      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Build locally
echo -e "${YELLOW}📦 Step 1: Building backend locally...${NC}"
npm run build
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed. Aborting deployment.${NC}"
    exit 1
fi
echo ""

# Step 2: Sync to primary server
echo -e "${YELLOW}📤 Step 2: Syncing to Primary Server (172.16.40.61)...${NC}"
./scripts/sync-all-environments.sh
echo ""

# Step 3: Deploy on primary server
echo -e "${YELLOW}🔄 Step 3: Deploying on Primary Server...${NC}"
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$PRIMARY_SERVER" << 'EOF'
cd ~/zoea-backend
echo "Stopping containers..."
docker-compose down
echo "Building and starting containers..."
docker-compose up --build -d
echo "Waiting for API to start..."
sleep 10
echo "Checking container status..."
docker-compose ps
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Primary server deployed${NC}"
else
    echo -e "${RED}❌ Primary server deployment failed${NC}"
    exit 1
fi
echo ""

# Step 4: Deploy on backup server
echo -e "${YELLOW}🔄 Step 4: Deploying on Backup Server (172.16.40.60)...${NC}"
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$BACKUP_SERVER" << 'EOF'
cd ~/zoea-backend
echo "Stopping containers..."
docker-compose down
echo "Building and starting containers..."
docker-compose up --build -d
echo "Waiting for API to start..."
sleep 10
echo "Checking container status..."
docker-compose ps
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup server deployed${NC}"
else
    echo -e "${RED}❌ Backup server deployment failed${NC}"
    exit 1
fi
echo ""

# Step 5: Verification
echo -e "${YELLOW}🔍 Step 5: Verifying deployment...${NC}"
echo ""

echo "Testing Primary Server Health..."
HEALTH_CHECK=$(curl -s https://zoea-africa.qtsoftwareltd.com/api/health)
if echo "$HEALTH_CHECK" | grep -q "ok"; then
    echo -e "${GREEN}✅ Primary server health check passed${NC}"
    echo "Response: $HEALTH_CHECK"
else
    echo -e "${RED}❌ Primary server health check failed${NC}"
fi
echo ""

echo "Checking for Assistant endpoints..."
SWAGGER_CHECK=$(curl -s https://zoea-africa.qtsoftwareltd.com/api/docs | grep -c "assistant" || true)
if [ "$SWAGGER_CHECK" -gt 0 ]; then
    echo -e "${GREEN}✅ Assistant endpoints found in Swagger${NC}"
else
    echo -e "${YELLOW}⚠️  Could not verify assistant endpoints (check manually)${NC}"
fi
echo ""

# Step 6: Show logs
echo -e "${YELLOW}📋 Step 6: Recent logs from Primary Server...${NC}"
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$PRIMARY_SERVER" << 'EOF'
cd ~/zoea-backend
docker-compose logs --tail=20 api | grep -E "OpenAI|Assistant|Nest application"
EOF
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ✅ Deployment Complete!              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Test the API: https://zoea-africa.qtsoftwareltd.com/api/docs"
echo "2. Test Ask Zoea in mobile app"
echo "3. Monitor OpenAI usage: https://platform.openai.com/usage"
echo "4. Check logs: ssh qt@172.16.40.61 'cd ~/zoea-backend && docker-compose logs -f api'"
echo ""
echo -e "${YELLOW}📚 Full documentation: backend/DEPLOY_ASK_ZOEA.md${NC}"

