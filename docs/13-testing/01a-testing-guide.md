# Testing Guide

## Overview

This guide covers testing strategies, best practices, and examples for all Zoea applications.

## Testing Philosophy

- **Test Early**: Write tests alongside code
- **Test Often**: Run tests frequently during development
- **Test Everything**: Cover critical paths and edge cases
- **Maintain Tests**: Keep tests updated with code changes

---

## Mobile App Testing (Flutter)

### Test Types

#### 1. Unit Tests
Test individual functions, methods, and classes in isolation.

**Location**: `mobile/test/unit/`

**Example**:
```dart
// test/unit/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zoea2/core/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('login should return user data on success', () async {
      // Arrange
      final service = AuthService();
      
      // Act
      final result = await service.login(
        email: 'test@example.com',
        password: 'password123',
      );
      
      // Assert
      expect(result, isNotNull);
      expect(result['email'], equals('test@example.com'));
    });
    
    test('login should throw on invalid credentials', () async {
      // Arrange
      final service = AuthService();
      
      // Act & Assert
      expect(
        () => service.login(
          email: 'wrong@example.com',
          password: 'wrong',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

#### 2. Widget Tests
Test individual widgets and their interactions.

**Location**: `mobile/test/widget/`

**Example**:
```dart
// test/widget/listing_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zoea2/features/listings/widgets/listing_card.dart';

void main() {
  testWidgets('ListingCard displays listing information', (tester) async {
    // Arrange
    final listing = {
      'id': '123',
      'name': 'Test Hotel',
      'rating': 4.5,
      'address': 'Kigali, Rwanda',
    };
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ListingCard(listing: listing),
      ),
    );
    
    // Assert
    expect(find.text('Test Hotel'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('Kigali, Rwanda'), findsOneWidget);
  });
  
  testWidgets('ListingCard calls onTap when tapped', (tester) async {
    // Arrange
    bool tapped = false;
    final listing = {'id': '123', 'name': 'Test'};
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: ListingCard(
          listing: listing,
          onTap: () => tapped = true,
        ),
      ),
    );
    
    await tester.tap(find.byType(ListingCard));
    await tester.pump();
    
    // Assert
    expect(tapped, isTrue);
  });
}
```

#### 3. Integration Tests
Test complete user flows across multiple screens.

**Location**: `mobile/integration_test/`

**Example**:
```dart
// integration_test/booking_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zoea2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Booking Flow', () {
    testWidgets('complete hotel booking flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // Login
      await tester.enterText(find.byKey(Key('email')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // Navigate to listing
      await tester.tap(find.text('Hotels'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListingCard).first);
      await tester.pumpAndSettle();
      
      // Book
      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();
      
      // Fill booking form
      await tester.tap(find.byKey(Key('check_in_date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      
      // Submit
      await tester.tap(find.text('Confirm Booking'));
      await tester.pumpAndSettle();
      
      // Verify success
      expect(find.text('Booking Confirmed'), findsOneWidget);
    });
  });
}
```

### Running Tests

```bash
cd mobile

# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/auth_service_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Coverage Goals

- **Unit Tests**: 80%+ coverage for services and utilities
- **Widget Tests**: All custom widgets
- **Integration Tests**: Critical user flows

### Mocking

Use `mockito` for mocking:

```dart
// test/mocks/mock_auth_service.dart
@GenerateMocks([AuthService])
import 'mock_auth_service.mocks.dart';

void main() {
  test('test with mock', () {
    final mockAuth = MockAuthService();
    when(mockAuth.login(any, any))
        .thenAnswer((_) async => {'email': 'test@example.com'});
    
    // Use mockAuth in tests
  });
}
```

---

## Backend API Testing (NestJS)

### Test Types

#### 1. Unit Tests
Test individual services, controllers, and utilities.

**Location**: `backend/src/**/*.spec.ts`

**Example**:
```typescript
// src/modules/listings/listings.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { ListingsService } from './listings.service';
import { PrismaService } from '../prisma/prisma.service';

describe('ListingsService', () => {
  let service: ListingsService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ListingsService,
        {
          provide: PrismaService,
          useValue: {
            listing: {
              findMany: jest.fn(),
              findUnique: jest.fn(),
              create: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<ListingsService>(ListingsService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return paginated listings', async () => {
      const mockListings = [
        { id: '1', name: 'Hotel 1' },
        { id: '2', name: 'Hotel 2' },
      ];

      jest.spyOn(prisma.listing, 'findMany').mockResolvedValue(mockListings);

      const result = await service.findAll({ page: 1, limit: 20 });

      expect(result.data).toEqual(mockListings);
      expect(result.meta.page).toBe(1);
    });
  });
});
```

#### 2. E2E Tests
Test complete API endpoints and request/response flows.

**Location**: `backend/test/`

**Example**:
```typescript
// test/listings.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('ListingsController (e2e)', () => {
  let app: INestApplication;
  let authToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Login to get token
    const loginResponse = await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'test@example.com',
        password: 'password123',
      });

    authToken = loginResponse.body.accessToken;
  });

  it('/listings (GET)', () => {
    return request(app.getHttpServer())
      .get('/listings')
      .expect(200)
      .expect((res) => {
        expect(res.body.data).toBeInstanceOf(Array);
        expect(res.body.meta).toHaveProperty('page');
      });
  });

  it('/listings/:id (GET)', () => {
    return request(app.getHttpServer())
      .get('/listings/123')
      .expect(200)
      .expect((res) => {
        expect(res.body).toHaveProperty('id');
        expect(res.body).toHaveProperty('name');
      });
  });

  it('/listings (POST) - requires auth', () => {
    return request(app.getHttpServer())
      .post('/listings')
      .send({ name: 'New Listing' })
      .expect(401);
  });

  it('/listings (POST) - with auth', () => {
    return request(app.getHttpServer())
      .post('/listings')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        name: 'New Listing',
        type: 'hotel',
        categoryId: 'category-uuid',
      })
      .expect(201)
      .expect((res) => {
        expect(res.body).toHaveProperty('id');
        expect(res.body.name).toBe('New Listing');
      });
  });

  afterAll(async () => {
    await app.close();
  });
});
```

### Running Tests

```bash
cd backend

# Run all tests
npm test

# Run with coverage
npm run test:cov

# Run e2e tests
npm run test:e2e

# Run in watch mode
npm run test:watch

# Run specific test file
npm test -- listings.service.spec.ts
```

### Test Database

Use a separate test database:

```typescript
// test/setup.ts
process.env.DATABASE_URL = 'postgresql://user:pass@localhost:5432/zoea_test';
```

### Test Coverage Goals

- **Unit Tests**: 80%+ coverage
- **E2E Tests**: All API endpoints
- **Integration Tests**: Critical business flows

---

## Admin Dashboard Testing (Next.js)

### Test Types

#### 1. Component Tests
Test React components in isolation.

**Example**:
```typescript
// __tests__/components/Dashboard.test.tsx
import { render, screen } from '@testing-library/react';
import Dashboard from '@/components/Dashboard';

describe('Dashboard', () => {
  it('renders dashboard title', () => {
    render(<Dashboard />);
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
  });

  it('displays statistics', async () => {
    render(<Dashboard />);
    
    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('Total Bookings')).toBeInTheDocument();
    });
  });
});
```

#### 2. API Route Tests
Test Next.js API routes.

**Example**:
```typescript
// __tests__/api/listings.test.ts
import { createMocks } from 'node-mocks-http';
import handler from '@/pages/api/listings';

describe('/api/listings', () => {
  it('returns listings', async () => {
    const { req, res } = createMocks({
      method: 'GET',
    });

    await handler(req, res);

    expect(res._getStatusCode()).toBe(200);
    const data = JSON.parse(res._getData());
    expect(data).toHaveProperty('listings');
  });
});
```

### Running Tests

```bash
cd admin

# Run tests
npm test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```

---

## Test Data Management

### Fixtures

Create reusable test data:

```dart
// mobile/test/fixtures/listings_fixture.dart
class ListingsFixture {
  static Map<String, dynamic> hotelListing() => {
    'id': 'hotel-123',
    'name': 'Test Hotel',
    'type': 'hotel',
    'rating': 4.5,
    'price': 50000,
  };
}
```

```typescript
// backend/test/fixtures/listings.fixture.ts
export const mockListing = {
  id: 'listing-123',
  name: 'Test Hotel',
  type: 'hotel',
  rating: 4.5,
  price: 50000,
};
```

### Test Database Seeding

```typescript
// backend/test/seed.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function seed() {
  // Create test users
  await prisma.user.create({
    data: {
      email: 'test@example.com',
      password: 'hashed_password',
    },
  });

  // Create test listings
  await prisma.listing.createMany({
    data: [
      { name: 'Test Hotel 1', type: 'hotel' },
      { name: 'Test Hotel 2', type: 'hotel' },
    ],
  });
}

seed();
```

---

## Continuous Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  mobile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: cd mobile && flutter test
      - run: cd mobile && flutter test --coverage

  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd backend && npm ci
      - run: cd backend && npm test
      - run: cd backend && npm run test:cov
```

---

## Best Practices

### 1. Test Organization
- Group related tests using `describe`/`group`
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

### 2. Test Independence
- Each test should be independent
- Don't rely on test execution order
- Clean up after tests

### 3. Mock External Dependencies
- Mock API calls
- Mock database operations
- Mock file system operations

### 4. Test Edge Cases
- Empty inputs
- Null values
- Invalid data
- Error conditions

### 5. Keep Tests Fast
- Use mocks instead of real services
- Use in-memory databases for tests
- Parallelize test execution

### 6. Maintain Tests
- Update tests when code changes
- Remove obsolete tests
- Refactor tests for clarity

---

## Test Checklist

Before submitting code:

- [ ] All tests pass
- [ ] New features have tests
- [ ] Bug fixes have regression tests
- [ ] Test coverage meets goals
- [ ] Tests are fast and reliable
- [ ] Tests are well-documented
- [ ] CI/CD pipeline passes

---

## Resources

- **Flutter Testing**: https://flutter.dev/docs/testing
- **NestJS Testing**: https://docs.nestjs.com/fundamentals/testing
- **Next.js Testing**: https://nextjs.org/docs/testing
- **Jest Documentation**: https://jestjs.io/docs/getting-started

