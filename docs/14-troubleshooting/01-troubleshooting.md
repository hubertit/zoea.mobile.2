# Troubleshooting Guide

## Common Issues and Solutions

### Mobile App Issues

#### Issue: "Failed to load listings" or API errors

**Symptoms**:
- Network errors in console
- "Failed to fetch" messages
- 401 Unauthorized errors

**Solutions**:
1. **Check API URL**:
   ```dart
   // In lib/core/config/app_config.dart
   static const String apiBaseUrl = 'https://zoea-africa.qtsoftwareltd.com/api';
   ```

2. **Check Authentication**:
   - Verify user is logged in
   - Check token storage: `TokenStorageService`
   - Try logging out and back in

3. **Check Network**:
   - Verify internet connection
   - Check if backend is running (for local dev)
   - Check VPN connection (if required)

4. **Check Backend Status**:
   ```bash
   curl https://zoea-africa.qtsoftwareltd.com/api/docs
   ```

#### Issue: App crashes on launch

**Solutions**:
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

#### Issue: Build errors

**Solutions**:
```bash
# Clean build
flutter clean
rm -rf build/
flutter pub get
flutter build apk  # or ios
```

---

### Backend API Issues

#### Issue: Database connection failed

**Symptoms**:
```
PrismaClientInitializationError: Can't reach database server
```

**Solutions**:
1. **Check PostgreSQL is running**:
   ```bash
   pg_isready
   # or
   psql -U postgres -c "SELECT 1"
   ```

2. **Verify DATABASE_URL in .env**:
   ```env
   DATABASE_URL=postgresql://user:password@host:5432/database
   ```

3. **Check database exists**:
   ```bash
   psql -U postgres -l | grep zoea
   ```

4. **Check network/firewall**:
   - Verify PostgreSQL port (5432) is accessible
   - Check firewall rules
   - Verify VPN connection (if database is remote)

#### Issue: Port 3000 already in use

**Solutions**:
```bash
# Find process
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in .env
PORT=3001
```

#### Issue: Prisma migration errors

**Solutions**:
```bash
# Reset database (development only - deletes data!)
npx prisma migrate reset

# Or create new migration
npx prisma migrate dev --name fix_migration
```

#### Issue: npm install fails

**Solutions**:
```bash
# Clear cache
npm cache clean --force

# Delete and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

### Admin Dashboard Issues

#### Issue: Cannot connect to API

**Solutions**:
1. **Check API URL**:
   ```env
   # In .env.local
   NEXT_PUBLIC_API_URL=https://zoea-africa.qtsoftwareltd.com/api
   ```

2. **Check backend is running** (for local dev)

3. **Check CORS settings** in backend

#### Issue: Build fails

**Solutions**:
```bash
# Clear Next.js cache
rm -rf .next node_modules
npm install
npm run build
```

---

### Deployment Issues

#### Issue: Docker build fails

**Symptoms**:
- `npm ci` errors
- Module not found errors

**Solutions**:
1. **Ensure package-lock.json is committed**:
   ```bash
   git add package-lock.json
   git commit -m "Update package-lock.json"
   ```

2. **Check Dockerfile**:
   - Verify CMD path matches build output
   - Check Node version matches

3. **Clear Docker cache**:
   ```bash
   docker system prune -a
   ```

#### Issue: Deployment script fails

**Solutions**:
1. **Check disk space on server**:
   ```bash
   df -h
   ```

2. **Check SSH connection**:
   ```bash
   ssh qt@172.16.40.61
   ```

3. **Check file permissions**:
   ```bash
   chmod +x sync-all-environments.sh
   ```

---

### Database Issues

#### Issue: Migration fails

**Solutions**:
```bash
# Check migration status
npx prisma migrate status

# Resolve conflicts
npx prisma migrate resolve --applied <migration_name>

# Or reset (development only)
npx prisma migrate reset
```

#### Issue: Data not appearing

**Solutions**:
1. **Check database connection**
2. **Verify migrations applied**:
   ```bash
   npx prisma migrate status
   ```
3. **Check data in Prisma Studio**:
   ```bash
   npx prisma studio
   ```

---

### Authentication Issues

#### Issue: "Unauthorized" errors

**Solutions**:
1. **Check token is being sent**:
   - Verify `Authorization` header in requests
   - Check token storage

2. **Check token validity**:
   - Token may be expired
   - Try logging out and back in

3. **Check backend JWT secret**:
   - Verify `JWT_SECRET` in backend `.env`
   - Ensure it matches between environments

#### Issue: Token refresh fails

**Solutions**:
1. **Check refresh token is stored**
2. **Verify refresh endpoint works**:
   ```bash
   curl -X POST https://zoea-africa.qtsoftwareltd.com/api/auth/refresh \
     -H "Content-Type: application/json" \
     -d '{"refreshToken": "your-token"}'
   ```

---

### Performance Issues

#### Issue: Slow API responses

**Solutions**:
1. **Check database indexes**:
   ```sql
   -- Check indexes
   \d+ table_name
   ```

2. **Check query performance**:
   - Use Prisma query logging
   - Check slow query log

3. **Check network latency**:
   - Verify database location
   - Check VPN connection quality

#### Issue: Mobile app is slow

**Solutions**:
1. **Check image loading**:
   - Use `CachedNetworkImage`
   - Optimize image sizes

2. **Check API calls**:
   - Reduce unnecessary calls
   - Implement pagination
   - Use caching

---

## Getting Help

### Debug Steps

1. **Check Logs**:
   - Mobile: Flutter console output
   - Backend: Terminal output or logs
   - Admin: Browser console + terminal

2. **Enable Debug Mode**:
   - Mobile: Already in debug mode
   - Backend: `NODE_ENV=development`
   - Admin: Check browser DevTools

3. **Check Network**:
   - Use browser DevTools Network tab
   - Check API responses
   - Verify request/response format

### Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# Check Node version
node --version
npm --version

# Check PostgreSQL
psql --version
pg_isready

# Check Docker
docker --version
docker ps
```

### Contact Points

- **Backend Issues**: Backend team
- **Mobile Issues**: Mobile team
- **Admin Issues**: Admin team
- **Database Issues**: Backend team + DBA
- **Infrastructure**: DevOps team

---

## Prevention

### Best Practices

1. **Always test locally** before deploying
2. **Check logs** regularly
3. **Monitor error rates**
4. **Keep dependencies updated**
5. **Follow coding standards**
6. **Write tests**
7. **Document changes**

### Regular Maintenance

- Update dependencies monthly
- Review error logs weekly
- Check database performance
- Monitor API response times
- Review security updates

