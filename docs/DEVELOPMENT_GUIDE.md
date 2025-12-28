# Development Guide

## Getting Started

### Prerequisites

- **Node.js**: v18+ (for backend, admin, web)
- **Flutter**: Latest stable (for mobile)
- **PostgreSQL**: 14+ (for backend database)
- **Git**: Latest version
- **Docker**: (optional, for backend deployment)

### Initial Setup

#### 1. Clone Repositories

```bash
# Navigate to project root
cd /Users/macbookpro/projects/flutter/zoea2

# Each app has its own git repo
cd mobile && git pull
cd ../backend && git pull
cd ../admin && git pull
```

#### 2. Consumer Mobile Setup

```bash
cd mobile
flutter pub get
flutter doctor  # Check for issues
```

#### 3. Merchant Mobile Setup

```bash
cd merchant-mobile
flutter pub get
flutter doctor  # Check for issues
```

#### 4. Backend Setup

```bash
cd backend
npm install
cp env.example .env
# Edit .env with database credentials
npx prisma generate
npx prisma migrate dev
npm run start:dev
```

#### 5. Admin Setup

```bash
cd admin
npm install
# Configure environment variables if needed
npm run dev
```

---

## Development Workflows

### Consumer Mobile Development

**Location**: `/Users/macbookpro/projects/flutter/zoea2/mobile`

**Key Commands**:
```bash
# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for production
flutter build apk  # Android
flutter build ios  # iOS

# Analyze code
flutter analyze

# Run tests
flutter test
```

**Key Files**:
- `lib/core/services/` - API services
- `lib/core/providers/` - State management (Riverpod)
- `lib/features/` - Feature modules
- `lib/core/router/` - Navigation

**API Integration**:
- Base URL: `https://zoea-africa.qtsoftwareltd.com/api`
- Config: `lib/core/config/app_config.dart`
- Services: `lib/core/services/*_service.dart`

---

### Merchant Mobile Development

**Location**: `/Users/macbookpro/projects/flutter/zoea2/merchant-mobile`

**Key Commands**:
```bash
# Run app
flutter run

# Run on specific device
flutter run -d <device-id>

# Build for production
flutter build apk  # Android
flutter build ios  # iOS

# Analyze code
flutter analyze

# Run tests
flutter test
```

**Key Files**:
- `lib/core/services/` - API services (merchant-specific)
- `lib/core/providers/` - State management (Riverpod)
- `lib/features/` - Merchant feature modules
  - `dashboard/` - Business dashboard
  - `listings/` - Listing management
  - `bookings/` - Booking management
  - `analytics/` - Business analytics
- `lib/core/router/` - Navigation

**API Integration**:
- Base URL: `https://zoea-africa.qtsoftwareltd.com/api`
- Merchant endpoints: `/merchant/*`
- Config: `lib/core/config/app_config.dart`

---

### Backend Development

**Location**: `/Users/macbookpro/projects/flutter/zoea2/backend`

**Key Commands**:
```bash
# Development
npm run start:dev

# Production build
npm run build
npm run start:prod

# Database
npx prisma studio  # Database GUI
npx prisma migrate dev  # Create migration
npx prisma generate  # Generate Prisma client

# Testing
npm test
npm run test:e2e
```

**Key Files**:
- `src/modules/` - Feature modules
- `src/common/` - Shared utilities
- `prisma/schema.prisma` - Database schema
- `src/main.ts` - Application entry

**API Documentation**:
- Swagger UI: `http://localhost:3000/api/docs` (when running)

---

### Admin Development

**Location**: `/Users/macbookpro/projects/flutter/zoea2/admin`

**Key Commands**:
```bash
# Development
npm run dev

# Production build
npm run build
npm run start

# Linting
npm run lint
```

**Key Files**:
- `src/app/` - Next.js app directory
- `src/lib/` - Utilities and API clients
- `src/types/` - TypeScript types

---

## Code Organization

### Consumer Mobile Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/       # App configuration
│   │   ├── services/     # API services
│   │   ├── providers/    # State management
│   │   ├── models/       # Data models
│   │   ├── router/       # Navigation
│   │   └── theme/        # App theming
│   └── features/
│       ├── auth/         # Authentication
│       ├── explore/      # Explore screen
│       ├── listings/     # Listings
│       ├── booking/      # Bookings
│       └── profile/      # User profile
├── android/              # Android platform
├── ios/                  # iOS platform
└── pubspec.yaml          # Dependencies
```

### Merchant Mobile Structure

```
merchant-mobile/
├── lib/
│   ├── core/
│   │   ├── config/       # App configuration
│   │   ├── services/     # API services (merchant)
│   │   ├── providers/    # State management
│   │   ├── models/       # Data models
│   │   ├── router/       # Navigation
│   │   └── theme/        # App theming
│   └── features/
│       ├── auth/         # Merchant authentication
│       ├── dashboard/    # Business dashboard
│       ├── listings/     # Listing management
│       ├── bookings/     # Booking management
│       ├── analytics/    # Business analytics
│       └── revenue/      # Revenue tracking
├── android/              # Android platform
├── ios/                  # iOS platform
└── pubspec.yaml          # Dependencies
```

### Backend Structure

```
backend/
├── src/
│   ├── modules/          # Feature modules
│   │   ├── auth/
│   │   ├── users/
│   │   ├── listings/
│   │   ├── bookings/
│   │   └── ...
│   ├── common/           # Shared code
│   │   ├── decorators/
│   │   ├── guards/
│   │   └── filters/
│   └── main.ts           # Entry point
├── prisma/
│   ├── schema.prisma     # Database schema
│   └── migrations/       # Database migrations
└── test/                 # Tests
```

---

## API Development

### Creating a New Endpoint

#### Backend (NestJS)

1. **Create DTO**:
```typescript
// src/modules/feature/dto/create-feature.dto.ts
export class CreateFeatureDto {
  @IsString()
  name: string;
  
  @IsOptional()
  @IsString()
  description?: string;
}
```

2. **Create Service**:
```typescript
// src/modules/feature/feature.service.ts
@Injectable()
export class FeatureService {
  async create(data: CreateFeatureDto) {
    // Business logic
  }
}
```

3. **Create Controller**:
```typescript
// src/modules/feature/feature.controller.ts
@Controller('features')
export class FeatureController {
  @Post()
  async create(@Body() data: CreateFeatureDto) {
    return this.service.create(data);
  }
}
```

#### Mobile (Flutter)

1. **Create Service Method**:
```dart
// lib/core/services/feature_service.dart
Future<Map<String, dynamic>> createFeature({
  required String name,
  String? description,
}) async {
  final response = await _dio.post(
    '/features',
    data: {
      'name': name,
      'description': description,
    },
  );
  return response.data;
}
```

2. **Create Provider**:
```dart
// lib/core/providers/feature_provider.dart
final featureProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, id) async {
    final service = ref.read(featureServiceProvider);
    return await service.getFeature(id);
  },
);
```

---

## Testing

### Mobile Testing

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

### Backend Testing

```bash
# Unit tests
npm test

# E2E tests
npm run test:e2e

# Test specific file
npm test -- feature.spec.ts
```

---

## Deployment

### Backend Deployment

**Script**: `backend/sync-all-environments.sh`

```bash
cd backend
./sync-all-environments.sh
```

**Manual Deployment**:
```bash
# On server
cd ~/zoea-backend
docker-compose down
docker-compose up --build -d
```

### Mobile Deployment

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
# Then use Xcode for App Store submission
```

### Admin Deployment

```bash
npm run build
# Deploy dist/ folder to hosting service
```

---

## Environment Variables

### Backend (.env)

```env
DATABASE_URL=postgresql://user:password@host:5432/database
JWT_SECRET=your-secret
JWT_REFRESH_SECRET=your-refresh-secret
PORT=3000
```

### Mobile

Configuration in `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'https://zoea-africa.qtsoftwareltd.com/api';
```

---

## Common Tasks

### Adding a New Feature

1. **Backend**: Create module, DTOs, service, controller
2. **Mobile**: Create service, provider, UI screens
3. **Admin**: Add management UI (if needed)
4. **Documentation**: Update docs

### Database Migration

```bash
cd backend
# Edit prisma/schema.prisma
npx prisma migrate dev --name migration_name
npx prisma generate
```

### Updating Dependencies

**Mobile**:
```bash
cd mobile
flutter pub upgrade
```

**Backend**:
```bash
cd backend
npm update
```

**Admin**:
```bash
cd admin
npm update
```

---

## Troubleshooting

### Common Issues

#### Mobile: API Connection Errors
- Check `app_config.dart` base URL
- Verify network connectivity
- Check token validity

#### Backend: Database Connection
- Verify `.env` DATABASE_URL
- Check PostgreSQL is running
- Verify network access

#### Backend: Port Already in Use
```bash
# Find process
lsof -i :3000
# Kill process
kill -9 <PID>
```

---

## Best Practices

### Code Style

- **Mobile**: Follow Flutter style guide
- **Backend**: Follow NestJS conventions
- **Admin**: Follow Next.js conventions

### Git Workflow

- Each app has its own repository
- Use feature branches
- Commit frequently
- Write descriptive commit messages

### API Design

- Use RESTful conventions
- Consistent error responses
- Proper HTTP status codes
- API versioning (if needed)

### Security

- Never commit `.env` files
- Use environment variables
- Validate all inputs
- Sanitize user data
- Use HTTPS in production

