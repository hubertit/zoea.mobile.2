# Zoea Admin Panel - Deployment Guide

## Overview

This guide explains how to deploy the Zoea Admin Panel to production servers using Docker.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Production Server                      │
│                  (172.16.40.61/62)                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Backend    │  │    Admin     │  │  PostgreSQL  │ │
│  │   (NestJS)   │  │   (Next.js)  │  │              │ │
│  │   Port 3000  │  │   Port 3002  │  │   Port 5432  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                 │                  │          │
│         └─────────────────┴──────────────────┘          │
│                    zoea-network                          │
└─────────────────────────────────────────────────────────┘
```

## Port Allocation

Based on analysis of the resolveit deployment and to avoid conflicts:

| Service | Port | Status | Notes |
|---------|------|--------|-------|
| Backend API | 3000 | Used | Zoea backend (already deployed) |
| ResolveIt UI | 3001 | Used | ResolveIt frontend |
| **Admin Panel** | **3002** | **Available** | **New deployment** |
| PostgreSQL | 5432 | Used | Database (internal) |

## Prerequisites

1. **VPN Connection**: Must be connected to access servers
2. **SSH Access**: SSH keys configured for root@172.16.40.61 and root@172.16.40.62
3. **Docker**: Installed on production servers
4. **Node.js 20+**: For local build
5. **Backend Running**: Zoea backend API must be running on port 3000

## Deployment Files

### 1. Dockerfile
- Multi-stage build for optimized image size
- Uses Node.js 20 Alpine
- Runs as non-root user (nextjs)
- Health check included
- Port 3002 exposed

### 2. docker-compose.admin.yml
- Service name: `zoea-admin`
- Container name: `zoea-admin`
- Network: `zoea-network` (external, shared with backend)
- Auto-restart: unless-stopped
- Health checks every 30s

### 3. deploy-admin.sh
- Automated deployment script
- Builds locally
- Syncs to server
- Deploys via Docker Compose
- Includes health checks

## Deployment Steps

### Option 1: Automated Deployment (Recommended)

```bash
cd /Users/macbookpro/projects/flutter/zoea2/admin

# Deploy to production
./deploy-admin.sh
```

The script will:
1. ✅ Check server connectivity
2. ✅ Build the Next.js app locally
3. ✅ Create deployment package
4. ✅ Sync files to server
5. ✅ Build Docker image on server
6. ✅ Start container
7. ✅ Run health checks
8. ✅ Display access URL

### Option 2: Manual Deployment

```bash
# 1. Build locally
cd /Users/macbookpro/projects/flutter/zoea2/admin
NEXT_PUBLIC_API_BASE=http://172.16.40.61:3000/api npm run build

# 2. Sync to server
rsync -avz --delete ./ root@172.16.40.61:/root/zoea-admin/

# 3. Deploy on server
ssh root@172.16.40.61
cd /root/zoea-admin
docker compose -f docker-compose.admin.yml build
docker compose -f docker-compose.admin.yml up -d

# 4. Check status
docker compose -f docker-compose.admin.yml ps
docker compose -f docker-compose.admin.yml logs -f
```

## Environment Variables

### Build Time
```bash
NEXT_PUBLIC_API_BASE=http://172.16.40.61:3000/api
```

### Runtime
```bash
ADMIN_PORT=3002
NODE_ENV=production
```

## Post-Deployment Verification

### 1. Check Container Status
```bash
ssh root@172.16.40.61 'docker ps | grep zoea-admin'
```

Expected output:
```
zoea-admin    Up X minutes (healthy)    0.0.0.0:3002->3002/tcp
```

### 2. Check Logs
```bash
ssh root@172.16.40.61 'docker logs zoea-admin --tail=50'
```

### 3. Test Access
```bash
# From local machine
curl -I http://172.16.40.61:3002

# Or open in browser
open http://172.16.40.61:3002
```

### 4. Test API Connection
```bash
# Check if admin can reach backend
curl http://172.16.40.61:3002/api/health
```

## Monitoring

### View Live Logs
```bash
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml logs -f'
```

### Check Health Status
```bash
ssh root@172.16.40.61 'docker inspect zoea-admin | grep -A 10 Health'
```

### Resource Usage
```bash
ssh root@172.16.40.61 'docker stats zoea-admin --no-stream'
```

## Management Commands

### Restart Admin Panel
```bash
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml restart'
```

### Stop Admin Panel
```bash
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml down'
```

### Update Admin Panel
```bash
# Re-run deployment script
cd /Users/macbookpro/projects/flutter/zoea2/admin
./deploy-admin.sh
```

### View Container Details
```bash
ssh root@172.16.40.61 'docker inspect zoea-admin'
```

## Troubleshooting

### Issue: Port 3002 Already in Use
```bash
# Check what's using the port
ssh root@172.16.40.61 'netstat -tulpn | grep :3002'

# Stop the conflicting service
ssh root@172.16.40.61 'docker stop <container-name>'
```

### Issue: Cannot Connect to Backend
```bash
# Check backend is running
ssh root@172.16.40.61 'docker ps | grep zoea-api'

# Check backend health
curl http://172.16.40.61:3000/api/docs

# Check network
ssh root@172.16.40.61 'docker network inspect zoea-network'
```

### Issue: Build Fails
```bash
# Clear Next.js cache
rm -rf .next

# Clear node modules
rm -rf node_modules
npm install

# Rebuild
npm run build
```

### Issue: Container Unhealthy
```bash
# Check logs
ssh root@172.16.40.61 'docker logs zoea-admin --tail=100'

# Check health check
ssh root@172.16.40.61 'docker exec zoea-admin node -e "require(\"http\").get(\"http://localhost:3002\", (r) => console.log(r.statusCode))"'

# Restart container
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml restart'
```

## Security Considerations

1. **Firewall**: Ensure port 3002 is open in firewall
2. **Authentication**: Admin panel requires login
3. **HTTPS**: Consider adding nginx reverse proxy with SSL
4. **Network**: Uses isolated Docker network
5. **User**: Container runs as non-root user

## Backup & Rollback

### Backup Current Deployment
```bash
ssh root@172.16.40.61 'cd /root && tar -czf zoea-admin-backup-$(date +%Y%m%d).tar.gz zoea-admin/'
```

### Rollback
```bash
# Stop current deployment
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml down'

# Restore backup
ssh root@172.16.40.61 'cd /root && tar -xzf zoea-admin-backup-YYYYMMDD.tar.gz'

# Start previous version
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml up -d'
```

## Performance Optimization

### Image Size
- Multi-stage build reduces image size
- Alpine Linux base (~50MB)
- Standalone output (~80MB total)

### Startup Time
- Health check: 40s start period
- Typical startup: 10-15 seconds
- First request: ~2-3 seconds

### Resource Limits (Optional)
Add to docker-compose.admin.yml:
```yaml
deploy:
  resources:
    limits:
      cpus: '1'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
```

## Access URLs

### Primary Server (172.16.40.61)
- Admin Panel: http://172.16.40.61:3002
- Backend API: http://172.16.40.61:3000/api
- API Docs: http://172.16.40.61:3000/api/docs

### Backup Server (172.16.40.62)
- Admin Panel: http://172.16.40.62:3002
- Backend API: http://172.16.40.62:3000/api
- API Docs: http://172.16.40.62:3000/api/docs

## Support

For issues or questions:
1. Check logs: `docker logs zoea-admin`
2. Check health: `docker inspect zoea-admin`
3. Review this documentation
4. Contact DevOps team

---

**Last Updated**: January 2, 2026
**Version**: 1.0.0

