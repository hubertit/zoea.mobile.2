# Zoea Admin Panel - Quick Start Deployment

## 🚀 One-Command Deployment

```bash
cd /Users/macbookpro/projects/flutter/zoea2/admin
./deploy-admin.sh
```

## 📋 Pre-Deployment Checklist

- [ ] VPN connected
- [ ] Backend running on port 3000
- [ ] SSH access to servers configured
- [ ] Port 3002 available

## 🔧 Port Configuration

| Service | Port | URL |
|---------|------|-----|
| Backend | 3000 | http://172.16.40.61:3000/api |
| Admin | **3002** | **http://172.16.40.61:3002** |

## 📊 Deployment Summary

Based on resolveit deployment analysis:

### Architecture
- **Framework**: Next.js 16 (Turbopack)
- **Container**: Docker with multi-stage build
- **Network**: zoea-network (shared with backend)
- **User**: Non-root (nextjs:nodejs)
- **Health Check**: Every 30s

### Files Created
1. ✅ `Dockerfile` - Multi-stage Next.js build
2. ✅ `docker-compose.admin.yml` - Container orchestration
3. ✅ `deploy-admin.sh` - Automated deployment script
4. ✅ `next.config.ts` - Updated with standalone output
5. ✅ `DEPLOYMENT.md` - Full documentation

### Deployment Flow
```
Local Build → Package → Sync to Server → Docker Build → Deploy → Health Check
```

## 🎯 Quick Commands

### Deploy
```bash
./deploy-admin.sh
```

### Check Status
```bash
ssh root@172.16.40.61 'docker ps | grep zoea-admin'
```

### View Logs
```bash
ssh root@172.16.40.61 'docker logs zoea-admin -f'
```

### Restart
```bash
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml restart'
```

### Stop
```bash
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml down'
```

## 🔍 Verification Steps

1. **Container Running**
   ```bash
   ssh root@172.16.40.61 'docker ps | grep zoea-admin'
   ```
   Expected: `zoea-admin ... Up ... (healthy)`

2. **Access URL**
   ```bash
   curl -I http://172.16.40.61:3002
   ```
   Expected: `HTTP/1.1 200 OK`

3. **Check Logs**
   ```bash
   ssh root@172.16.40.61 'docker logs zoea-admin --tail=20'
   ```
   Expected: No errors, "Ready" message

## ⚠️ Important Notes

1. **Port 3002** chosen to avoid conflicts:
   - Port 3000: Zoea backend (existing)
   - Port 3001: ResolveIt UI (existing)
   - Port 3002: Zoea admin (new)

2. **Network**: Uses external `zoea-network` to communicate with backend

3. **API Base**: Set to `http://172.16.40.61:3000/api` during build

4. **Servers**: 
   - Primary: 172.16.40.61
   - Backup: 172.16.40.62

## 🆘 Troubleshooting

### Cannot Connect to Server
```bash
# Check VPN
# Check SSH: ssh root@172.16.40.61 'echo connected'
```

### Port Already in Use
```bash
ssh root@172.16.40.61 'netstat -tulpn | grep :3002'
# Stop conflicting service before deploying
```

### Build Fails
```bash
rm -rf .next node_modules
npm install
npm run build
```

### Container Unhealthy
```bash
ssh root@172.16.40.61 'docker logs zoea-admin'
ssh root@172.16.40.61 'cd /root/zoea-admin && docker compose -f docker-compose.admin.yml restart'
```

## 📞 Access After Deployment

**Admin Panel**: http://172.16.40.61:3002

Login with your admin credentials to:
- ✅ Manage listings with country selector
- ✅ View analytics
- ✅ Manage users and merchants
- ✅ Configure settings

---

**Ready to deploy?** Run `./deploy-admin.sh` and confirm when prompted! 🚀

