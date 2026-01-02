# Pre-Deployment Checklist - Ask Zoea Feature

**Date**: January 2, 2026  
**Feature**: Ask Zoea AI Assistant

---

## ✅ Code Quality Checks

- [x] **Backend compiles**: `npm run build` ✅
- [x] **No TypeScript errors**: All files compile successfully ✅
- [x] **Linter passes**: No critical linting issues ✅
- [x] **Dependencies installed**: `openai@6.15.0`, `@nestjs/schedule@6.1.0` ✅

---

## ✅ Database Checks

- [x] **Tables created**: 4 new tables exist in production database ✅
  - `integrations`
  - `assistant_conversations`
  - `assistant_messages`
  - `assistant_message_cards`

- [x] **OpenAI config**: API key configured and active ✅
- [x] **Database connection**: Production DB accessible ✅

---

## ✅ Backend Checks

- [x] **Server running**: Backend running on localhost:3000 ✅
- [x] **All endpoints registered**: 4 assistant endpoints + 5 integrations endpoints ✅
- [x] **OpenAI initialized**: "OpenAI initialized successfully" in logs ✅
- [x] **Health check passes**: `/api/health` returns 200 OK ✅

---

## ✅ Mobile Checks

- [x] **No compilation errors**: Flutter app builds successfully ✅
- [x] **No linter errors**: All new files pass linting ✅
- [x] **Routes configured**: `/ask-zoea` and `/tour/:id` routes added ✅
- [x] **5th tab added**: Ask Zoea in center position with animation ✅

---

## ✅ Documentation

- [x] **Implementation doc**: `ASK_ZOEA_IMPLEMENTATION.md` created ✅
- [x] **Deployment guide**: `DEPLOY_ASK_ZOEA.md` created ✅
- [x] **Deployment script**: `deploy-now.sh` created and executable ✅

---

## ⚠️ Pre-Deployment Actions

### 1. Verify Production Database
```bash
PGPASSWORD="Zoea2025Secure" psql -h 172.16.40.61 -U admin -d main -c "
SELECT name, is_active FROM integrations WHERE name = 'openai';
"
```
**Expected**: `openai | t` (active)

### 2. Check OpenAI Credits
- Visit: https://platform.openai.com/usage
- Ensure sufficient credits available
- Set up billing alerts if not already done

### 3. Backup Database (Optional but Recommended)
```bash
PGPASSWORD="Zoea2025Secure" pg_dump -h 172.16.40.61 -U admin -d main > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 4. Notify Team
- [ ] Inform team of deployment window
- [ ] Expected downtime: ~30 seconds per server
- [ ] Estimated completion: ~10 minutes

---

## 🚀 Ready to Deploy?

If all checks above are ✅, proceed with deployment:

### Quick Deploy (Automated):
```bash
cd /Users/macbookpro/projects/flutter/zoea2/backend
./deploy-now.sh
```

### Manual Deploy:
Follow steps in `DEPLOY_ASK_ZOEA.md`

---

## 📊 What to Monitor After Deployment

### Immediate (0-5 minutes):
- [ ] API health check returns 200 OK
- [ ] Swagger docs accessible
- [ ] Assistant endpoints visible in Swagger
- [ ] Docker containers running
- [ ] No errors in Docker logs

### Short-term (5-30 minutes):
- [ ] Test chat endpoint with real request
- [ ] Verify OpenAI responses
- [ ] Check database for new conversations
- [ ] Monitor OpenAI API usage

### Long-term (1-24 hours):
- [ ] Monitor error rates
- [ ] Check OpenAI costs
- [ ] Verify cron job runs (at 2 AM)
- [ ] Monitor database size growth
- [ ] Check user feedback

---

## 🐛 Known Issues / Considerations

1. **OpenAI Rate Limits**: GPT-4 has rate limits. Monitor usage.
2. **Response Time**: First request may be slower (cold start).
3. **Database Growth**: Monitor `assistant_messages` table size.
4. **API Costs**: Each chat request costs ~$0.01-0.05 depending on length.

---

## 🔙 Rollback Plan

If deployment fails:
1. SSH into servers
2. Run: `git checkout <previous-commit>`
3. Run: `docker-compose down && docker-compose up --build -d`
4. Verify health check

**Note**: Database tables will remain (no harm, can be dropped if needed)

---

## ✅ Final Checklist

Before running `./deploy-now.sh`:

- [ ] All code checks passed
- [ ] Database verified
- [ ] OpenAI credits confirmed
- [ ] Team notified
- [ ] Backup created (optional)
- [ ] Deployment script tested (`chmod +x deploy-now.sh`)
- [ ] Ready to monitor post-deployment

---

## 🎯 Success Criteria

Deployment is successful when:
1. Health check returns 200 OK
2. Swagger shows assistant endpoints
3. Test chat request works
4. No errors in logs
5. OpenAI initialization confirmed

---

**Ready to deploy? Run:**
```bash
cd /Users/macbookpro/projects/flutter/zoea2/backend
./deploy-now.sh
```

Good luck! 🚀

