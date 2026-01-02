# Zoea Backend API

NestJS backend API serving all Zoea applications.

## Technology Stack

- **Framework**: NestJS
- **Language**: TypeScript
- **Database**: PostgreSQL + PostGIS
- **ORM**: Prisma
- **Authentication**: JWT
- **Documentation**: Swagger/OpenAPI

## Project Structure

```
backend/
├── src/
│   ├── modules/            # Feature modules
│   │   ├── auth/           # Authentication
│   │   ├── users/          # User management
│   │   ├── listings/       # Listings
│   │   ├── bookings/      # Bookings
│   │   ├── reviews/        # Reviews
│   │   ├── favorites/     # Favorites
│   │   ├── categories/     # Categories
│   │   └── ...
│   ├── common/             # Shared code
│   │   ├── decorators/
│   │   ├── guards/
│   │   ├── filters/
│   │   └── interceptors/
│   └── main.ts             # Application entry
├── prisma/
│   ├── schema.prisma       # Database schema
│   └── migrations/         # Database migrations
└── test/                   # Tests
```

## Getting Started

### Quick Start

**New to the project?** Check out the [Quick Start Guide](QUICKSTART.md) for a fast setup!

### Prerequisites

- Node.js v18+
- PostgreSQL 16+ with PostGIS
- npm or pnpm

### Installation

```bash
cd backend
npm install
cp env.example .env
# Edit .env with your database credentials
```

### Database Setup

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev

# Open Prisma Studio (database GUI)
npx prisma studio
```

### Running

```bash
# Development mode (with hot reload)
npm run start:dev

# Production build
npm run build
npm run start:prod
```

## API Documentation

When running, access Swagger documentation at:
- **Local**: `http://localhost:3000/api/docs`
- **Production**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

## Environment Variables

Create `.env` file:

```env
DATABASE_URL=postgresql://user:password@host:5432/database
JWT_SECRET=your-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key
PORT=3000
NODE_ENV=development
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login
- `POST /auth/refresh` - Refresh token

### Listings
- `GET /listings` - Get listings (with filters)
- `GET /listings/:id` - Get listing details
- `POST /listings` - Create listing (admin)
- `PUT /listings/:id` - Update listing (admin)

### Bookings
- `GET /bookings` - Get user bookings
- `POST /bookings` - Create booking
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id` - Update booking
- `POST /bookings/:id/cancel` - Cancel booking
- `POST /bookings/:id/confirm-payment` - Confirm payment

### Reviews
- `GET /reviews` - Get reviews
- `POST /reviews` - Create review
- `PUT /reviews/:id` - Update review
- `DELETE /reviews/:id` - Delete review

### Favorites
- `GET /favorites` - Get user favorites
- `POST /favorites` - Add favorite
- `DELETE /favorites` - Remove favorite
- `POST /favorites/toggle` - Toggle favorite

See Swagger docs for complete API reference.

## Database

### Schema

Database schema is defined in `prisma/schema.prisma`.

### Migrations

```bash
# Create new migration
npx prisma migrate dev --name migration_name

# Apply migrations
npx prisma migrate deploy

# Reset database (development only)
npx prisma migrate reset
```

## Testing

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## Deployment

### Using Deployment Script

```bash
./sync-all-environments.sh
```

This syncs code to all environments (primary and backup servers).

### Manual Deployment

```bash
# Build
npm run build

# On server
cd ~/zoea-backend
docker-compose down
docker-compose up --build -d
```

## Git Repository

**Remote**: `https://github.com/zoea-africa/zoea2-apis.git`

## Documentation

- **[Quick Start Guide](QUICKSTART.md)** - Get started quickly
- **[CHANGELOG](CHANGELOG.md)** - Version history and updates
- **[API Reference](https://zoea-africa.qtsoftwareltd.com/api/docs)** - Swagger documentation
- **[Full Documentation](../docs/05-backend/)** - Comprehensive backend docs
- `FEATURES.md` - Feature breakdown
- `USER_FLOWS.md` - User flows
- `DEVELOPMENT_GUIDE.md` - Development guide
