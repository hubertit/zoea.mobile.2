# Environment Setup Guide

## Complete Setup Instructions

This guide walks you through setting up the entire Zoea development environment.

## Prerequisites

### Required Software
- **Node.js**: v18+ ([Download](https://nodejs.org/))
- **Flutter**: Latest stable ([Download](https://flutter.dev/docs/get-started/install))
- **PostgreSQL**: 14+ ([Download](https://www.postgresql.org/download/))
- **Git**: Latest version
- **Docker**: Optional, for containerized development

### Recommended Tools
- **VS Code** or **Android Studio** (for Flutter)
- **Postman** or **Insomnia** (for API testing)
- **DBeaver** or **pgAdmin** (for database management)

---

## Step-by-Step Setup

### 1. Clone Repositories

```bash
# Navigate to project root
cd /Users/macbookpro/projects/flutter/zoea2

# Each app has its own git repo - pull latest
cd mobile && git pull && cd ..
cd backend && git pull && cd ..
cd admin && git pull && cd ..
```

### 2. Backend Setup

#### 2.1 Install Dependencies

```bash
cd backend
npm install
```

#### 2.2 Database Setup

1. **Create PostgreSQL Database**:
```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE zoea_v2;
\q
```

2. **Configure Environment**:
```bash
cd backend
cp env.example .env
```

Edit `.env`:
```env
DATABASE_URL=postgresql://username:password@localhost:5432/zoea_v2
JWT_SECRET=your-super-secret-jwt-key-change-this
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-this
PORT=3000
NODE_ENV=development
```

3. **Run Migrations**:
```bash
npx prisma generate
npx prisma migrate dev
```

4. **Seed Database** (if seed script exists):
```bash
npm run seed  # If available
```

#### 2.3 Start Backend

```bash
npm run start:dev
```

Backend should be running at `http://localhost:3000`  
API docs at `http://localhost:3000/api/docs`

---

### 3. Mobile Setup

#### 3.1 Install Dependencies

```bash
cd mobile
flutter pub get
```

#### 3.2 Configure API URL

Edit `lib/core/config/app_config.dart` if needed:
```dart
static const String apiBaseUrl = 'http://localhost:3000/api';  // For local dev
// or
static const String apiBaseUrl = 'https://zoea-africa.qtsoftwareltd.com/api';  // For production
```

#### 3.3 Run Mobile App

```bash
# Check connected devices
flutter devices

# Run on device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>
```

---

### 4. Admin Setup

#### 4.1 Install Dependencies

```bash
cd admin
npm install
# or
pnpm install
```

#### 4.2 Configure Environment (if needed)

Create `.env.local`:
```env
NEXT_PUBLIC_API_URL=http://localhost:3000/api
```

#### 4.3 Start Admin Dashboard

```bash
npm run dev
```

Admin should be running at `http://localhost:3000` (or configured port)

---

### 5. Verify Setup

#### Test Backend
```bash
curl http://localhost:3000/api/docs
# Should return Swagger UI
```

#### Test Mobile
- App should launch
- Login screen should appear
- API calls should work (check network logs)

#### Test Admin
- Dashboard should load
- Should be able to login
- API calls should work

---

## Environment Variables Reference

### Backend (.env)

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string | ✅ Yes | `postgresql://user:pass@localhost:5432/db` |
| `JWT_SECRET` | JWT signing secret | ✅ Yes | `your-secret-key` |
| `JWT_REFRESH_SECRET` | Refresh token secret | ✅ Yes | `your-refresh-secret` |
| `PORT` | Server port | ❌ No | `3000` (default) |
| `NODE_ENV` | Environment | ❌ No | `development` |

### Mobile (app_config.dart)

| Variable | Description | Location |
|----------|-------------|----------|
| `apiBaseUrl` | API base URL | `lib/core/config/app_config.dart` |

### Admin (.env.local)

| Variable | Description | Required |
|----------|-------------|----------|
| `NEXT_PUBLIC_API_URL` | Backend API URL | ❌ No |

---

## Common Setup Issues

### Issue: Database Connection Failed

**Solution**:
1. Verify PostgreSQL is running: `pg_isready`
2. Check DATABASE_URL in `.env`
3. Verify database exists: `psql -l`
4. Check network/firewall settings

### Issue: Port Already in Use

**Solution**:
```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in .env
PORT=3001
```

### Issue: Flutter Dependencies Failed

**Solution**:
```bash
flutter clean
flutter pub get
flutter doctor  # Check for issues
```

### Issue: npm install Failed

**Solution**:
```bash
# Clear cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

---

## Development Workflow

### Daily Development

1. **Start Backend**:
   ```bash
   cd backend
   npm run start:dev
   ```

2. **Start Mobile** (in new terminal):
   ```bash
   cd mobile
   flutter run
   ```

3. **Start Admin** (in new terminal, if needed):
   ```bash
   cd admin
   npm run dev
   ```

### Database Changes

1. Edit `backend/prisma/schema.prisma`
2. Create migration: `npx prisma migrate dev --name migration_name`
3. Generate client: `npx prisma generate`

### Testing Changes

- **Backend**: `npm test`
- **Mobile**: `flutter test`
- **Admin**: `npm test` (if configured)

---

## Production Setup

See `DEVELOPMENT_GUIDE.md` for detailed deployment instructions.

---

## Next Steps

After setup:
1. ✅ Read `docs/PROJECT_OVERVIEW.md`
2. ✅ Review `docs/FEATURES.md`
3. ✅ Check `docs/USER_FLOWS.md`
4. ✅ Start developing!

