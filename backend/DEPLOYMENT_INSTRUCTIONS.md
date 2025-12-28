# Backend API Deployment Instructions

## Recent Changes to Deploy

**Date**: $(date +%Y-%m-%d)  
**Feature**: Sorting support for listings API + Enhanced Swagger documentation

### Changes Summary:
1. ✅ Added `sortBy` parameter to listings API
2. ✅ Enhanced Swagger documentation for all endpoints
3. ✅ Implemented dynamic sorting in backend service

### Files Changed:
- `src/modules/listings/dto/listing.dto.ts` - Added sortBy parameter
- `src/modules/listings/listings.service.ts` - Implemented dynamic sorting
- `src/modules/listings/listings.controller.ts` - Enhanced Swagger docs

## Deployment Steps

### Option 1: Using Deployment Script (Automated)

```bash
cd /Users/macbookpro/projects/flutter/zoea2/backend
./sync-all-environments.sh
```

**Note**: If script shows connection timeouts, use Option 2 (Manual).

### Option 2: Manual Deployment

#### Step 1: Build the Application
```bash
cd /Users/macbookpro/projects/flutter/zoea2/backend
npm run build
```

#### Step 2: Deploy to Primary Server (172.16.40.61)
```bash
# SSH into primary server
ssh qt@172.16.40.61

# Navigate to backend directory
cd ~/zoea-backend

# Pull latest changes (if using git)
git pull origin main

# Or sync files manually using rsync from local machine:
# rsync -avz --exclude 'node_modules' --exclude 'dist' --exclude '.git' \
#   /Users/macbookpro/projects/flutter/zoea2/backend/ \
#   qt@172.16.40.61:~/zoea-backend/

# Rebuild and restart Docker container
docker-compose down
docker-compose up --build -d

# Check logs
docker-compose logs -f api
```

#### Step 3: Deploy to Backup Server (172.16.40.60)
```bash
# SSH into backup server
ssh qt@172.16.40.60

# Navigate to backend directory
cd ~/zoea-backend

# Pull latest changes or sync files
# (Same as Step 2)

# Rebuild and restart Docker container
docker-compose down
docker-compose up --build -d

# Check logs
docker-compose logs -f api
```

## Verification

### Check API Health
```bash
# Primary Server
curl https://zoea-africa.qtsoftwareltd.com/api/docs

# Or check Swagger UI
open https://zoea-africa.qtsoftwareltd.com/api/docs
```

### Verify Sorting Endpoint
```bash
# Test sorting parameter
curl "https://zoea-africa.qtsoftwareltd.com/api/listings?sortBy=rating_desc&limit=5"
```

### Check Docker Container Status
```bash
# On server
docker ps
docker-compose logs api
```

## Rollback (if needed)

```bash
# On server
cd ~/zoea-backend
git checkout <previous-commit-hash>
docker-compose down
docker-compose up --build -d
```

## Server Information

- **Primary Server**: 172.16.40.61
- **Backup Server**: 172.16.40.60
- **Domain**: https://zoea-africa.qtsoftwareltd.com
- **API Docs**: https://zoea-africa.qtsoftwareltd.com/api/docs
- **Backend Directory**: ~/zoea-backend
- **Container Name**: zoea-api
- **Port**: 3000

## Important Notes

1. **Database Migrations**: No database migrations required for this deployment
2. **Environment Variables**: Ensure `.env` file on servers has correct values
3. **Prisma Client**: Will be regenerated during Docker build
4. **Build Time**: ~2-3 minutes for Docker build
5. **Downtime**: ~30 seconds during container restart

