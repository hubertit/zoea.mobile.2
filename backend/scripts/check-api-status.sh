#!/bin/bash

# Check API status and container health on production server

SERVER="qt@172.16.40.61"
PASSWORD="Easy2Use$"

echo "🔍 Checking API status on production server..."
echo ""

sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$SERVER" << 'EOF'
cd ~/zoea-backend

echo "📦 Docker container status:"
docker-compose ps

echo ""
echo "📋 Recent container logs (last 50 lines):"
docker-compose logs --tail=50 api

echo ""
echo "💾 Disk usage:"
df -h / | tail -1

echo ""
echo "🧠 Memory usage:"
free -h

echo ""
echo "🔄 Container health check:"
docker inspect zoea-api --format='{{.State.Status}} - {{.State.Health.Status}}' 2>/dev/null || echo "Container not found"

echo ""
echo "📊 Docker system info:"
docker system df
EOF

echo ""
echo "🌐 External API check:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" https://zoea-africa.qtsoftwareltd.com/api/health || echo "API not reachable"




