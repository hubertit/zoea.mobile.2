# Ask Zoea Feature Deployment Guide

**Date**: January 2, 2026  
**Feature**: Ask Zoea - AI Assistant with OpenAI Integration

---

## 🎯 What's Being Deployed

### New Features:
1. ✅ **Ask Zoea AI Assistant** - Chatbot for Rwanda travel guidance
2. ✅ **Integrations Module** - Dynamic API key management
3. ✅ **Content Search** - Global search across listings, tours, products, services
4. ✅ **Conversation Management** - 90-day chat history with auto-cleanup
5. ✅ **OpenAI Integration** - GPT-4 with function calling

### Database Changes:
- ✅ 4 new tables created:
  - `integrations`
  - `assistant_conversations`
  - `assistant_messages`
  - `assistant_message_cards`
- ✅ OpenAI API key configured in database

### New Dependencies:
- ✅ `openai@6.15.0`
- ✅ `@nestjs/schedule@6.1.0`

---

## 📋 Pre-Deployment Checklist

### ✅ Completed:
- [x] Backend compiles successfully
- [x] All tests pass
- [x] Database tables created
- [x] OpenAI API key configured
- [x] No linter errors
- [x] Documentation updated
- [x] Local testing completed

### ⚠️ Before Deployment:
- [ ] Verify database connection on production
- [ ] Ensure OpenAI API key is in production database
- [ ] Backup current production database
- [ ] Test OpenAI API key has sufficient credits
- [ ] Notify team of deployment window

---

## 🚀 Deployment Steps

### Option 1: Automated Deployment (Recommended)

```bash
cd /Users/macbookpro/projects/flutter/zoea2/backend

# 1. Build locally to verify
npm run build

# 2. Run deployment script
./scripts/sync-all-environments.sh

# 3. SSH into primary server and restart
ssh qt@172.16.40.61
cd ~/zoea-backend
docker-compose down
docker-compose up --build -d
docker-compose logs -f api

# 4. SSH into backup server and restart
ssh qt@172.16.40.60
cd ~/zoea-backend
docker-compose down
docker-compose up --build -d
docker-compose logs -f api
```

### Option 2: Manual Deployment

```bash
# 1. Build locally
cd /Users/macbookpro/projects/flutter/zoea2/backend
npm run build

# 2. Sync to primary server
rsync -avz --exclude 'node_modules' --exclude 'dist' --exclude '.git' \
  /Users/macbookpro/projects/flutter/zoea2/backend/ \
  qt@172.16.40.61:~/zoea-backend/

# 3. Deploy on primary server
ssh qt@172.16.40.61 << 'EOF'
cd ~/zoea-backend
docker-compose down
docker-compose up --build -d
docker-compose logs -f api
EOF

# 4. Repeat for backup server (172.16.40.60)
```

---

## 🗄️ Database Migration

The database tables are already created on the production database. However, if deploying to a fresh environment:

```bash
# On production server
cd ~/zoea-backend

# Apply the SQL migration
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -f add_assistant_tables.sql

# Verify tables exist
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('integrations', 'assistant_conversations', 'assistant_messages', 'assistant_message_cards')
ORDER BY table_name;
"
```

---

## 🔑 OpenAI API Key Configuration

The OpenAI API key is already configured in the database. To verify or update:

```bash
# Check current configuration
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
SELECT name, display_name, is_active, config->>'model' as model 
FROM integrations 
WHERE name = 'openai';
"

# If needed, update the API key
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
UPDATE integrations 
SET config = jsonb_set(config, '{apiKey}', '\"YOUR_NEW_API_KEY\"'::jsonb),
    is_active = true
WHERE name = 'openai';
"
```

**⚠️ IMPORTANT**: Never commit API keys to git. They should only exist in the database.

---

## ✅ Post-Deployment Verification

### 1. Check API Health
```bash
# Primary Server
curl https://zoea-africa.qtsoftwareltd.com/api/health

# Expected response:
# {"status":"ok","timestamp":"...","uptime":...,"version":"1.0.0"}
```

### 2. Verify New Endpoints
```bash
# Check Swagger documentation
open https://zoea-africa.qtsoftwareltd.com/api/docs

# Look for new endpoints:
# - POST /api/assistant/chat
# - GET /api/assistant/conversations
# - GET /api/assistant/conversations/:id/messages
# - DELETE /api/assistant/conversations/:id
# - GET /api/integrations
```

### 3. Test Assistant Endpoint
```bash
# Get auth token first (use a test account)
TOKEN="your_jwt_token_here"

# Test chat endpoint
curl -X POST https://zoea-africa.qtsoftwareltd.com/api/assistant/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Find restaurants in Kigali"
  }'

# Expected: JSON response with assistant message and cards
```

### 4. Check Docker Logs
```bash
# On server
ssh qt@172.16.40.61
docker-compose logs api | grep -i "openai\|assistant"

# Look for:
# [OpenAIService] OpenAI initialized successfully
# [AssistantController] Mapped {/api/assistant/chat, POST}
```

### 5. Monitor OpenAI Usage
```bash
# Check OpenAI dashboard
open https://platform.openai.com/usage

# Monitor:
# - API calls count
# - Token usage
# - Costs
```

---

## 🔄 Cron Jobs

The assistant cleanup cron job runs automatically:
- **Schedule**: Daily at 2 AM
- **Action**: Deletes conversations older than 90 days
- **Logs**: Check `docker-compose logs api | grep "cleanup"`

---

## 🐛 Troubleshooting

### Issue: OpenAI not initialized
```bash
# Check database configuration
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
SELECT name, is_active FROM integrations WHERE name = 'openai';
"

# Ensure is_active = true
# Check API key is valid
```

### Issue: Assistant endpoints not found
```bash
# Verify module is imported
docker-compose logs api | grep "AssistantModule"

# Should see: [InstanceLoader] AssistantModule dependencies initialized
```

### Issue: Database connection error
```bash
# Check DATABASE_URL in .env
cat ~/zoea-backend/.env | grep DATABASE_URL

# Test connection
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "SELECT 1;"
```

### Issue: Build fails
```bash
# Clear Docker cache and rebuild
docker-compose down
docker system prune -f
docker-compose up --build -d
```

---

## 📊 Monitoring

### Key Metrics to Watch:
1. **API Response Time**: `/api/assistant/chat` should respond in 2-5 seconds
2. **OpenAI Costs**: Monitor daily spend on OpenAI dashboard
3. **Database Size**: Watch `assistant_messages` table growth
4. **Error Rates**: Check for 500 errors in assistant endpoints
5. **Conversation Count**: Monitor active conversations

### Monitoring Commands:
```bash
# Check API response time
time curl -X POST https://zoea-africa.qtsoftwareltd.com/api/assistant/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'

# Check database size
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE tablename LIKE 'assistant%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

# Check conversation count
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
SELECT COUNT(*) as total_conversations FROM assistant_conversations;
"
```

---

## 🔙 Rollback Plan

If issues occur after deployment:

```bash
# 1. SSH into server
ssh qt@172.16.40.61
cd ~/zoea-backend

# 2. Checkout previous commit
git log --oneline -10  # Find previous commit hash
git checkout <previous-commit-hash>

# 3. Rebuild and restart
docker-compose down
docker-compose up --build -d

# 4. Verify rollback
curl https://zoea-africa.qtsoftwareltd.com/api/health

# 5. If database changes need rollback (CAREFUL!)
# Only if absolutely necessary:
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
DROP TABLE IF EXISTS assistant_message_cards CASCADE;
DROP TABLE IF EXISTS assistant_messages CASCADE;
DROP TABLE IF EXISTS assistant_conversations CASCADE;
DROP TABLE IF EXISTS integrations CASCADE;
"
```

---

## 📝 Server Information

- **Primary Server**: 172.16.40.61
- **Backup Server**: 172.16.40.60
- **Domain**: https://zoea-africa.qtsoftwareltd.com
- **API Docs**: https://zoea-africa.qtsoftwareltd.com/api/docs
- **Backend Directory**: ~/zoea-backend
- **Container Name**: zoea-api
- **Port**: 3000
- **Database**: 172.16.40.61:5432 (PostgreSQL)
- **SSH User**: qt
- **SSH Password**: Easy2Use$

---

## 🎉 Success Criteria

Deployment is successful when:
- ✅ API health check returns 200 OK
- ✅ Swagger docs show new assistant endpoints
- ✅ Test chat request returns valid response
- ✅ OpenAI initialization log appears
- ✅ No errors in Docker logs
- ✅ Database tables exist and are accessible
- ✅ Cron job is scheduled (check logs after 2 AM)

---

## 📞 Support

If you encounter issues:
1. Check Docker logs: `docker-compose logs api`
2. Check database connection
3. Verify OpenAI API key validity
4. Review error messages in logs
5. Test endpoints with Swagger UI

---

## 📚 Related Documentation

- [Ask Zoea Implementation](../ASK_ZOEA_IMPLEMENTATION.md)
- [General Deployment Guide](../docs/09-deployment/01-deployment-guide.md)
- [API Documentation](https://zoea-africa.qtsoftwareltd.com/api/docs)

---

**Deployment Prepared By**: AI Assistant (Claude Sonnet 4.5)  
**Date**: January 2, 2026  
**Status**: Ready for Production Deployment

