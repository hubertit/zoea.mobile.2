# Quick Start Guide - Zoea Backend API

Get the Zoea Backend API up and running in minutes!

## Prerequisites

Before you begin, ensure you have:

- ✅ **Node.js** (v18 or higher) - [Download Node.js](https://nodejs.org/)
- ✅ **npm** or **pnpm** (package manager)
- ✅ **PostgreSQL 16** with **PostGIS** extension
- ✅ **Git**

### Check Your Setup

```bash
node --version  # Should be v18+
npm --version
psql --version  # Should be 16+
```

---

## Installation (10 minutes)

### Step 1: Clone the Repository

```bash
git clone https://github.com/zoea-africa/zoea2-apis.git
cd zoea2-apis/backend
```

### Step 2: Install Dependencies

```bash
npm install
# or
pnpm install
```

### Step 3: Set Up Environment Variables

```bash
cp env.example .env
```

Edit `.env` with your configuration:

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/zoea_db?schema=public"

# JWT
JWT_SECRET="your-super-secret-jwt-key-change-this"
JWT_REFRESH_SECRET="your-super-secret-refresh-key-change-this"

# App
PORT=3000
NODE_ENV=development

# Optional: External APIs
SINC_API_KEY="your-sinc-api-key"
```

### Step 4: Set Up Database

```bash
# Create database
createdb zoea_db

# Enable PostGIS extension
psql zoea_db -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# Run migrations
npx prisma migrate dev

# Generate Prisma Client
npx prisma generate

# (Optional) Seed database
npm run seed
```

---

## Running the API (2 minutes)

### Development Mode (with hot reload)

```bash
npm run start:dev
```

The API will be available at: `http://localhost:3000/api`

### Production Mode

```bash
npm run build
npm run start:prod
```

### Debug Mode

```bash
npm run start:debug
```

---

## Verify Installation

### Check API Health

```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-01-02T10:30:00.000Z"
}
```

### View Swagger Documentation

Open your browser and navigate to:
```
http://localhost:3000/api/docs
```

This provides interactive API documentation where you can test endpoints.

---

## Test the API

### 1. Register a User

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "firstName": "Test",
    "lastName": "User",
    "phone": "+250788123456"
  }'
```

### 2. Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'
```

Save the `access_token` from the response.

### 3. Get Listings

```bash
curl http://localhost:3000/api/listings \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Key Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout

### Listings
- `GET /api/listings` - Get all listings (with filters & sorting)
- `GET /api/listings/:id` - Get listing details
- `POST /api/listings` - Create listing (merchant only)
- `PATCH /api/listings/:id` - Update listing

### Bookings
- `POST /api/bookings/accommodation` - Book accommodation
- `POST /api/bookings/restaurant` - Book restaurant
- `GET /api/bookings` - Get user bookings
- `PATCH /api/bookings/:id/cancel` - Cancel booking

### Reviews
- `GET /api/reviews` - Get reviews
- `POST /api/reviews` - Create review
- `PATCH /api/reviews/:id` - Update review
- `POST /api/reviews/:id/helpful` - Mark helpful

### Search
- `GET /api/search?q=keyword` - Global search

See [Swagger Docs](http://localhost:3000/api/docs) for complete endpoint list.

---

## Database Management

### View Database with Prisma Studio

```bash
npx prisma studio
```

Opens a web interface at `http://localhost:5555` to browse and edit data.

### Create a Migration

```bash
# After modifying schema.prisma
npx prisma migrate dev --name description_of_changes
```

### Reset Database (⚠️ Deletes all data)

```bash
npx prisma migrate reset
```

### Backup Database

```bash
pg_dump zoea_db > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
psql zoea_db < backup_20250102.sql
```

---

## Project Structure Overview

```
backend/
├── src/
│   ├── modules/
│   │   ├── auth/           # Authentication module
│   │   ├── users/          # Users management
│   │   ├── listings/       # Listings CRUD
│   │   ├── bookings/       # Booking system
│   │   ├── reviews/        # Reviews & ratings
│   │   ├── favorites/      # Favorites management
│   │   ├── categories/     # Categories
│   │   ├── events/         # Events integration
│   │   └── ...
│   ├── common/
│   │   ├── decorators/     # Custom decorators
│   │   ├── filters/        # Exception filters
│   │   ├── guards/         # Auth guards
│   │   ├── interceptors/   # Interceptors
│   │   └── pipes/          # Validation pipes
│   ├── prisma/
│   │   └── prisma.service.ts
│   ├── app.module.ts       # Root module
│   └── main.ts            # Application entry point
├── prisma/
│   ├── schema.prisma       # Database schema
│   └── migrations/         # Migration files
├── test/                   # E2E tests
└── package.json
```

---

## Development Tips

### Watch Mode
The API automatically reloads when you make changes in `npm run start:dev`.

### Logging
Control log levels in `.env`:
```env
LOG_LEVEL=debug  # Options: error, warn, log, debug, verbose
```

### CORS Configuration
Edit `src/main.ts` to configure CORS:
```typescript
app.enableCors({
  origin: ['http://localhost:3000', 'https://yourdomain.com'],
  credentials: true,
});
```

---

## Common Issues & Solutions

### Issue: "Can't reach database server"
**Solution**: 
- Ensure PostgreSQL is running: `pg_isready`
- Check DATABASE_URL in `.env`
- Test connection: `psql $DATABASE_URL`

### Issue: "Prisma Client not generated"
**Solution**:
```bash
npx prisma generate
```

### Issue: Port 3000 already in use
**Solution**: 
- Change PORT in `.env`
- Or kill process: `lsof -ti:3000 | xargs kill -9`

### Issue: Migration fails
**Solution**:
```bash
# Check current migration status
npx prisma migrate status

# If needed, reset and try again
npx prisma migrate reset
npx prisma migrate dev
```

---

## Testing

### Run Unit Tests

```bash
npm run test
```

### Run E2E Tests

```bash
npm run test:e2e
```

### Run Tests with Coverage

```bash
npm run test:cov
```

---

## Code Quality

### Lint Code

```bash
npm run lint
```

### Format Code

```bash
npm run format
```

### Type Check

```bash
npm run build
```

---

## Deployment

### Build for Production

```bash
npm run build
```

### Run Production Build

```bash
npm run start:prod
```

### Docker Deployment

```bash
# Build image
docker build -t zoea-api .

# Run container
docker run -p 3000:3000 --env-file .env zoea-api
```

### Using Docker Compose

```bash
docker-compose up -d
```

---

## Environment Variables Reference

```env
# Required
DATABASE_URL=postgresql://user:password@localhost:5432/zoea_db
JWT_SECRET=your-jwt-secret
JWT_REFRESH_SECRET=your-refresh-secret

# Optional
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug

# External APIs
SINC_API_KEY=your-sinc-key
SINC_API_URL=https://api.sinc.rw

# Email (if enabled)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# File Upload
MAX_FILE_SIZE=5242880  # 5MB
UPLOAD_PATH=./uploads
```

---

## API Authentication

The API uses JWT Bearer tokens:

```bash
# Include token in requests
curl http://localhost:3000/api/protected-endpoint \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Token Expiration
- **Access Token**: 15 minutes
- **Refresh Token**: 7 days

Use the refresh endpoint to get new access tokens.

---

## Helpful Commands

```bash
# Generate new migration
npx prisma migrate dev --name add_new_field

# Format Prisma schema
npx prisma format

# Validate schema
npx prisma validate

# View all routes
npm run start:dev -- --preview

# Check dependencies
npm audit

# Update dependencies
npm update
```

---

## Production URLs

- **API Base**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Swagger Docs**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

---

## Need Help?

- 📖 **Documentation**: [/docs/05-backend/](../docs/05-backend/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/zoea-africa/zoea2-apis/issues)
- 💬 **NestJS Docs**: [docs.nestjs.com](https://docs.nestjs.com)
- 🗄️ **Prisma Docs**: [prisma.io/docs](https://www.prisma.io/docs)

---

**Happy Building! 🚀**

