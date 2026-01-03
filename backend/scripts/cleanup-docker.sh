#!/bin/bash

# Clean up unused Docker images and containers on production server
# This script removes:
# - Dangling images (untagged)
# - Unused images (not used by any container)
# - Stopped containers
# - Unused volumes (optional)

set -e

SERVER="qt@172.16.40.61"
PASSWORD="Easy2Use$"

echo "🧹 Cleaning up Docker on production server..."
echo ""

sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER" << 'EOF'
cd ~/zoea-backend

echo "📊 Current disk usage:"
df -h / | tail -1

echo ""
echo "📦 Docker disk usage:"
docker system df

echo ""
echo "🗑️  Removing dangling images..."
docker image prune -f

echo ""
echo "🗑️  Removing unused images (not used by any container)..."
docker image prune -a -f

echo ""
echo "🗑️  Removing stopped containers..."
docker container prune -f

echo ""
echo "🗑️  Removing unused volumes (optional - be careful!)..."
# Uncomment the next line if you want to remove unused volumes too
# docker volume prune -f

echo ""
echo "📊 Disk usage after cleanup:"
docker system df

echo ""
echo "✅ Cleanup complete!"
EOF

echo ""
echo "✅ Docker cleanup completed on production server"

