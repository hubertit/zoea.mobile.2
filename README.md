# Zoea Project

**Discover Rwanda Like Never Before**

This is the main Zoea project directory containing all related applications and services for the Zoea travel and tourism platform.

## Project Structure

```
zoea2/
├── mobile/          # Consumer mobile app (Flutter)
│   ├── lib/         # Flutter source code
│   ├── android/     # Android platform files
│   ├── ios/         # iOS platform files
│   ├── pubspec.yaml # Flutter dependencies
│   └── .git/        # Git repository
├── merchant-mobile/  # Merchant mobile app (Flutter)
│   ├── lib/         # Flutter source code
│   ├── android/     # Android platform files
│   ├── ios/         # iOS platform files
│   ├── pubspec.yaml # Flutter dependencies
│   └── .git/        # Git repository
├── backend/         # NestJS backend API
│   ├── src/         # Source code
│   ├── prisma/      # Database schema
│   └── .git/        # Git repository
├── admin/           # Admin and partners dashboard (Next.js)
│   ├── src/         # Source code
│   └── .git/        # Git repository
├── web/             # Consumer web app (Next.js)
│   └── .git/        # Git repository (ready for remote)
├── merchant-web/    # Merchant web portal (Next.js) - Future
│   └── .git/        # Git repository (ready for remote)
├── docs/            # Documentation
├── scripts/         # Shared scripts
├── migration/       # Database migration scripts
└── database/        # Database schemas and dumps
```

## Applications

### 1. Consumer Mobile App (`mobile/`)
- **Technology**: Flutter (Dart)
- **Platform**: iOS, Android
- **Purpose**: Consumer-facing mobile application
- **Status**: ✅ Active Development
- **Repository**: `https://github.com/hubertit/zoea.mobile.2.git`

### 2. Merchant Mobile App (`merchant-mobile/`)
- **Technology**: Flutter (Dart)
- **Platform**: iOS, Android
- **Purpose**: Merchant business management mobile app
- **Status**: ✅ Active Development
- **Repository**: `https://github.com/zoea-africa/zoea-partner-mobile.git`

### 3. Backend API (`backend/`)
- **Technology**: NestJS (TypeScript)
- **Database**: PostgreSQL 16 + PostGIS
- **ORM**: Prisma
- **Purpose**: RESTful API serving all applications
- **Status**: ✅ Production Ready
- **Repository**: `https://github.com/zoea-africa/zoea2-apis.git`
- **API Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Swagger Docs**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

### 4. Admin Dashboard (`admin/`)
- **Technology**: Next.js (React, TypeScript)
- **Purpose**: Admin and partners management dashboard
- **Status**: ✅ Active Development

### 5. Consumer Web App (`web/`)
- **Technology**: Next.js (planned)
- **Purpose**: Public-facing website for consumers
- **Status**: ⏳ Planned

### 6. Merchant Web Portal (`merchant-web/`)
- **Technology**: Next.js (planned)
- **Purpose**: Merchant business management web portal
- **Status**: ⏳ Planned

## Quick Start

### Consumer Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

### Merchant Mobile (Flutter)
```bash
cd merchant-mobile
flutter pub get
flutter run
```

### Backend (NestJS)
```bash
cd backend
npm install
cp env.example .env
# Edit .env with your database credentials
npx prisma generate
npx prisma migrate dev
npm run start:dev
```

### Admin (Next.js)
```bash
cd admin
npm install
npm run dev
```

## Technology Stack Summary

| Application | Framework | Language | Database | Key Libraries |
|------------|-----------|----------|----------|---------------|
| Consumer Mobile | Flutter | Dart | N/A (API client) | Riverpod, GoRouter, Dio |
| Merchant Mobile | Flutter | Dart | N/A (API client) | Riverpod, GoRouter, Dio |
| Backend | NestJS | TypeScript | PostgreSQL 16 + PostGIS | Prisma, JWT, Swagger |
| Admin | Next.js | TypeScript | MySQL (legacy) | React, Tailwind, ApexCharts |
| Consumer Web | Next.js (planned) | TypeScript | N/A (API client) | React, Tailwind |
| Merchant Web | Next.js (planned) | TypeScript | N/A (API client) | React, Tailwind |

## API Information

**Production Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`  
**Swagger Documentation**: `https://zoea-africa.qtsoftwareltd.com/api/docs`  
**Authentication**: JWT (Access Token + Refresh Token)

## Git Repositories

Each application maintains its own git repository:
- **mobile/**: `https://github.com/hubertit/zoea.mobile.2.git`
- **merchant-mobile/**: `https://github.com/zoea-africa/zoea-partner-mobile.git`
- **backend/**: `https://github.com/zoea-africa/zoea2-apis.git`
- **admin/**: (to be configured)
- **web/**: (to be configured)
- **merchant-web/**: (to be configured)

## Deployment

### Backend Deployment
```bash
cd backend
./sync-all-environments.sh
# Then SSH into servers and run:
# docker-compose down && docker-compose up --build -d
```

### Mobile Deployment
Standard Flutter deployment process:
- Android: `flutter build appbundle --release`
- iOS: `flutter build ios --release`

## Documentation

Comprehensive documentation is available in the `/docs/` directory:

### Key Documentation Files
- **[PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md)** - Complete project overview
- **[FEATURES.md](docs/FEATURES.md)** - Feature breakdown by application
- **[API_REFERENCE.md](docs/API_REFERENCE.md)** - Complete API endpoint reference
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System architecture details
- **[DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md)** - Development setup and guidelines
- **[USER_FLOWS.md](docs/USER_FLOWS.md)** - User flow documentation
- **[DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md)** - Database schema documentation

### Application-Specific Documentation
- **Mobile App**: See `mobile/README.md`
- **Backend API**: See `backend/README.md`
- **Admin Dashboard**: See `admin/README.md`

## Recent Updates

### Latest Features (December 2024)
- ✅ **Sorting Functionality**: Dynamic sorting for listings (rating, name, price, date, popularity)
- ✅ **Filtering**: Enhanced filters (rating, price range, featured status)
- ✅ **Share Functionality**: Share listings, events, accommodations, and referral codes
- ✅ **Search**: Search functionality for bookings
- ✅ **Skeleton Loaders**: Improved loading states with shimmer effects
- ✅ **HTML Entities Fix**: Fixed broken special characters in listings database
- ✅ **Enhanced Swagger Docs**: Comprehensive API documentation

## Project Location

**Project Root**: `/Users/macbookpro/projects/flutter/zoea2`

This is your main working directory. All development happens here.

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on contributing to the project.

## License

[Add license information here]
