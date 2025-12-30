# Zoea V2 API Codebase Analysis

**Date:** December 27, 2024  
**API Base URL:** `https://zoea-africa.qtsoftwareltd.com/api`  
**API Documentation:** [https://zoea-africa.qtsoftwareltd.com/api/docs](https://zoea-africa.qtsoftwareltd.com/api/docs)  
**Flutter App Version:** 2.0.0

---

## Executive Summary

The Zoea V2 API is a NestJS-based RESTful API that provides comprehensive endpoints for a travel and tourism platform focused on Rwanda. The API follows RESTful conventions and uses JWT-based authentication. The Flutter app has partially integrated with the API, with authentication fully implemented and events using an external SINC API.

**Current Integration Status:**
- ✅ **Authentication:** Fully integrated
- ✅ **Events:** Using SINC API (external service)
- ❌ **All Other Services:** Not yet implemented

---

## 1. API Architecture

### 1.1 Technology Stack (Inferred from API Structure)

Based on the API endpoints and documentation structure:

- **Framework:** NestJS (TypeScript)
- **Database:** PostgreSQL + PostGIS (geospatial data)
- **ORM:** Prisma (inferred from migration context)
- **Authentication:** JWT (access + refresh tokens)
- **Documentation:** Swagger/OpenAPI
- **Cache:** Redis (likely, for performance)
- **Message Queue:** RabbitMQ (likely, for async operations)

### 1.2 API Structure

```
Base URL: https://zoea-africa.qtsoftwareltd.com/api

Endpoints are organized by resource:
- /auth/*          - Authentication
- /users/*         - User management
- /listings/*      - Business listings (hotels, restaurants, tours)
- /tour/*          - Tour-specific endpoints
- /event/*         - Event management
- /booking/*       - Booking management
- /review/*        - Reviews and ratings
- /favorite/*      - User favorites
- /search/*        - Search functionality
- /notification/*  - Notifications
- /upload/*        - File uploads
- /zoea-card/*     - Payment card management
- /transaction/*   - Transaction history
```

### 1.3 Authentication Flow

**JWT-Based Authentication:**
1. User registers/logs in → Receives `accessToken` and `refreshToken`
2. `accessToken` included in `Authorization: Bearer {token}` header
3. On 401 Unauthorized → Use `refreshToken` to get new `accessToken`
4. Tokens stored securely in Flutter app (SharedPreferences)

**Token Lifecycle:**
- Access tokens: Short-lived (typically 15-60 minutes)
- Refresh tokens: Long-lived (typically 7-30 days)
- Automatic refresh on 401 errors

---

## 2. Endpoint Analysis

### 2.1 Authentication Endpoints ✅ IMPLEMENTED

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| POST | `/api/auth/register` | Register new user | ✅ Implemented |
| POST | `/api/auth/login` | Login with email/phone | ✅ Implemented |
| POST | `/api/auth/refresh` | Refresh access token | ✅ Implemented |
| GET | `/api/auth/profile` | Get current user profile | ✅ Implemented |

**Request/Response Patterns:**

**Login:**
```json
POST /api/auth/login
{
  "identifier": "email@example.com" | "+250788123456",
  "password": "password"
}

Response:
{
  "user": { ... },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

**Register:**
```json
POST /api/auth/register
{
  "email": "email@example.com",
  "phoneNumber": "+250788123456",
  "password": "password",
  "fullName": "User Name"
}
```

---

### 2.2 User Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/users/me` | Get current user profile | 🔴 High |
| PUT | `/api/users/me` | Update user profile | 🔴 High |
| DELETE | `/api/users/me` | Delete account (soft) | 🟡 Medium |
| PUT | `/api/users/me/email` | Update email | 🟡 Medium |
| PUT | `/api/users/me/phone` | Update phone | 🟡 Medium |
| PUT | `/api/users/me/password` | Change password | 🔴 High |
| PUT | `/api/users/me/profile-image` | Update profile image | 🟡 Medium |
| PUT | `/api/users/me/background-image` | Update background image | 🟢 Low |
| GET | `/api/users/me/preferences` | Get preferences | 🟡 Medium |
| PUT | `/api/users/me/preferences` | Update preferences | 🟡 Medium |
| GET | `/api/users/me/stats` | Get user statistics | 🟢 Low |
| GET | `/api/users/me/visited-places` | Get visited places | 🟢 Low |
| GET | `/api/users/me/businesses` | Get my businesses | 🔴 High |
| POST | `/api/users/me/businesses` | Create business | 🔴 High |
| GET | `/api/users/me/businesses/{id}` | Get business by ID | 🔴 High |
| PUT | `/api/users/me/businesses/{id}` | Update business | 🔴 High |
| DELETE | `/api/users/me/businesses/{id}` | Delete business | 🟡 Medium |
| GET | `/api/users/me/organizer-profiles` | Get organizer profiles | 🟡 Medium |
| POST | `/api/users/me/organizer-profiles` | Create organizer profile | 🟡 Medium |
| GET | `/api/users/username/{username}` | Get user by username | 🟢 Low |
| GET | `/api/users/{id}` | Get user by ID | 🟢 Low |

**Key Features:**
- Multi-profile support (business, organizer, tour operator)
- User preferences management
- Profile image uploads
- Statistics tracking

---

### 2.3 Listings Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/listings` | Get all listings (filtered) | 🔴 High |
| POST | `/api/listings` | Create new listing | 🔴 High |
| GET | `/api/listings/featured` | Get featured listings | 🔴 High |
| GET | `/api/listings/nearby` | Get nearby listings | 🔴 High |
| GET | `/api/listings/type/{type}` | Get by type | 🔴 High |
| GET | `/api/listings/slug/{slug}` | Get by slug | 🔴 High |
| GET | `/api/listings/merchant/{merchantId}` | Get merchant listings | 🟡 Medium |
| GET | `/api/listings/{id}` | Get listing by ID | 🔴 High |
| PUT | `/api/listings/{id}` | Update listing | 🟡 Medium |
| DELETE | `/api/listings/{id}` | Delete listing | 🟡 Medium |
| GET | `/api/listings/{id}/room` | Get room types (hotel) | 🔴 High |
| POST | `/api/listings/{id}/room` | Create room type | 🟡 Medium |
| GET | `/api/listings/{id}/table` | Get tables (restaurant) | 🔴 High |
| POST | `/api/listings/{id}/table` | Create table | 🟡 Medium |
| GET | `/api/listings/{id}/availability` | Check availability | 🔴 High |
| POST | `/api/listings/{id}/submit` | Submit for review | 🟡 Medium |
| POST | `/api/listings/{id}/image` | Add image | 🟡 Medium |
| DELETE | `/api/listings/{id}/image/{imageId}` | Remove image | 🟡 Medium |
| PUT | `/api/listings/{id}/image/reorder` | Reorder images | 🟢 Low |
| PUT | `/api/listings/{id}/amenities` | Set amenities | 🟡 Medium |

**Listing Types:**
- Hotels (with room types)
- Restaurants (with tables)
- Tours
- Experiences

**Key Features:**
- Geospatial queries (nearby listings)
- Availability checking
- Image management
- Review workflow (submit for review)

---

### 2.4 Events Endpoints ✅ IMPLEMENTED (SINC API)

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| GET | `/api/event` | Get all events | ⚠️ Using SINC |
| GET | `/api/event/explore-event` | Explore events | ⚠️ Using SINC |
| GET | `/api/event/upcoming` | Upcoming events | ⚠️ Using SINC |
| GET | `/api/event/this-week` | This week events | ⚠️ Using SINC |
| GET | `/api/event/slug/{slug}` | Get by slug | ❌ Not implemented |
| GET | `/api/event/{id}` | Get by ID | ❌ Not implemented |
| POST | `/api/event/{id}/like` | Like/unlike event | ❌ Not implemented |
| GET | `/api/event/{id}/comment` | Get comments | ❌ Not implemented |
| POST | `/api/event/{id}/comment` | Add comment | ❌ Not implemented |

**Current Implementation:**
- Flutter app uses SINC API directly: `https://api-prod.sinc.today/events/v1/public`
- Main Zoea API has `/api/event/explore-event` endpoint (SINC-compatible)
- Decision: Continue using SINC API directly for now

**SINC API Endpoints Used:**
- `GET /explore-events` - Main events endpoint with filtering

---

### 2.5 Tours Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/tour` | Get all tours (filtered) | 🔴 High |
| POST | `/api/tour` | Create new tour | 🟡 Medium |
| GET | `/api/tour/featured` | Get featured tours | 🔴 High |
| GET | `/api/tour/slug/{slug}` | Get by slug | 🔴 High |
| GET | `/api/tour/{id}` | Get tour by ID | 🔴 High |
| PUT | `/api/tour/{id}` | Update tour | 🟡 Medium |
| DELETE | `/api/tour/{id}` | Delete tour | 🟡 Medium |
| GET | `/api/tour/{id}/schedule` | Get schedules | 🔴 High |

---

### 2.6 Bookings Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/booking` | Get my bookings | 🔴 High |
| POST | `/api/booking` | Create booking | 🔴 High |
| GET | `/api/booking/upcoming` | Get upcoming bookings | 🔴 High |
| GET | `/api/booking/{id}` | Get booking by ID | 🔴 High |
| PUT | `/api/booking/{id}` | Update booking | 🟡 Medium |
| DELETE | `/api/booking/{id}` | Cancel booking | 🔴 High |
| GET | `/api/booking/{id}/invoice` | Get invoice | 🟡 Medium |

**Booking Types:**
- Hotel bookings (with room selection)
- Restaurant bookings (with table selection)
- Tour bookings (with schedule selection)
- Event bookings (if applicable)

---

### 2.7 Reviews Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/review` | Get reviews (filtered) | 🟡 Medium |
| POST | `/api/review` | Create review | 🟡 Medium |
| GET | `/api/review/{id}` | Get review by ID | 🟢 Low |
| PUT | `/api/review/{id}` | Update review | 🟡 Medium |
| DELETE | `/api/review/{id}` | Delete review | 🟡 Medium |

**Review Targets:**
- Listings (hotels, restaurants, tours)
- Events
- Users (merchant reviews)

---

### 2.8 Favorites Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/favorite` | Get my favorites | 🟡 Medium |
| POST | `/api/favorite` | Add to favorites | 🟡 Medium |
| DELETE | `/api/favorite/{id}` | Remove from favorites | 🟡 Medium |

---

### 2.9 Search Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/search` | Global search | 🔴 High |
| GET | `/api/search/listings` | Search listings | 🔴 High |
| GET | `/api/search/events` | Search events | 🟡 Medium |
| GET | `/api/search/tours` | Search tours | 🟡 Medium |

**Search Features:**
- Full-text search
- Category filtering
- Location-based search
- Autocomplete suggestions

---

### 2.10 Notifications Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/notification` | Get notifications | 🟡 Medium |
| PUT | `/api/notification/{id}/read` | Mark as read | 🟡 Medium |
| PUT | `/api/notification/read-all` | Mark all as read | 🟡 Medium |
| DELETE | `/api/notification/{id}` | Delete notification | 🟢 Low |

---

### 2.11 Upload Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| POST | `/api/upload` | Upload file | 🔴 High |
| POST | `/api/upload/image` | Upload image | 🔴 High |
| POST | `/api/upload/multiple` | Upload multiple files | 🟡 Medium |

**Upload Types:**
- Profile images
- Listing images
- Event images
- Document uploads

---

### 2.12 Zoea Card Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/zoea-card` | Get card info | 🟡 Medium |
| POST | `/api/zoea-card` | Create/activate card | 🟡 Medium |
| PUT | `/api/zoea-card` | Update card | 🟡 Medium |
| GET | `/api/zoea-card/balance` | Get balance | 🟡 Medium |
| POST | `/api/zoea-card/top-up` | Top up card | 🟡 Medium |

---

### 2.13 Transactions Endpoints ❌ NOT IMPLEMENTED

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| GET | `/api/transaction` | Get transactions | 🟡 Medium |
| GET | `/api/transaction/{id}` | Get transaction by ID | 🟢 Low |

---

## 3. Flutter Integration Status

### 3.1 Implemented Services ✅

**1. AuthService (`lib/core/services/auth_service.dart`)**
- ✅ Login with email/phone
- ✅ Registration
- ✅ Token refresh
- ✅ Profile fetching
- ✅ Token interceptor
- ✅ Automatic token refresh on 401
- ✅ Error handling

**2. EventsService (`lib/core/services/events_service.dart`)**
- ✅ Get events (using SINC API)
- ✅ Get trending events
- ✅ Get nearby events
- ✅ Get this week events
- ✅ Search events

**3. TokenStorageService (`lib/core/services/token_storage_service.dart`)**
- ✅ Secure token storage
- ✅ User data caching
- ✅ Login state management

### 3.2 Missing Services ❌

**High Priority:**
- ❌ UserService - Profile management, preferences, businesses
- ❌ ListingsService - Browse, search, filter listings
- ❌ BookingsService - Create, manage bookings
- ❌ SearchService - Global search functionality

**Medium Priority:**
- ❌ ReviewsService - Reviews and ratings
- ❌ FavoritesService - Favorite management
- ❌ NotificationsService - Push notifications
- ❌ UploadService - File/image uploads

**Low Priority:**
- ❌ ToursService - Tour-specific operations
- ❌ ZoeaCardService - Payment card management
- ❌ TransactionsService - Transaction history

---

## 4. Implementation Patterns

### 4.1 Service Structure Pattern

Based on `AuthService` and `EventsService`, the pattern is:

```dart
class ServiceName {
  final Dio _dio = AppConfig.dioInstance(); // or custom Dio instance
  
  // Methods return typed models
  Future<ModelType> methodName({...params}) async {
    try {
      final response = await _dio.get/post/put/delete(
        '${AppConfig.endpoint}/path',
        queryParameters: {...},
        data: {...},
      );
      
      if (response.statusCode == 200) {
        return ModelType.fromJson(response.data);
      } else {
        throw Exception('Error message');
      }
    } on DioException catch (e) {
      // Handle network errors
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
```

### 4.2 Error Handling Pattern

```dart
try {
  // API call
} on DioException catch (e) {
  // Network/HTTP errors
  if (e.response?.statusCode == 401) {
    // Handle unauthorized (token refresh)
  } else if (e.response?.statusCode == 404) {
    // Handle not found
  } else {
    // Generic error
  }
} catch (e) {
  // Other errors
}
```

### 4.3 Token Management Pattern

```dart
// Automatic token injection via interceptor
_dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _tokenStorage?.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // Refresh token and retry
      }
      handler.next(error);
    },
  ),
);
```

---

## 5. Data Models

### 5.1 User Model

```dart
class User {
  String id;
  String email;
  String? phoneNumber;
  String fullName;
  String? profileImage;
  DateTime createdAt;
  DateTime updatedAt;
  bool isVerified;
  UserRole role; // explorer, merchant, eventOrganizer, admin
  UserPreferences? preferences;
}
```

### 5.2 Listing Model

```dart
class Listing {
  String id;
  String name;
  String slug;
  ListingType type; // hotel, restaurant, tour
  String? description;
  Location location; // with coordinates
  List<String> images;
  double? rating;
  int? reviewCount;
  PriceRange? priceRange;
  List<Amenity> amenities;
  // ... more fields
}
```

### 5.3 Booking Model

```dart
class Booking {
  String id;
  String bookingNumber;
  String listingId;
  DateTime checkInDate;
  DateTime? checkOutDate;
  int guestCount;
  BookingStatus status;
  double totalAmount;
  // ... more fields
}
```

---

## 6. API Response Patterns

### 6.1 Standard Success Response

```json
{
  "data": { ... },
  "message": "Success message",
  "statusCode": 200
}
```

### 6.2 Paginated Response

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### 6.3 Error Response

```json
{
  "message": "Error message",
  "error": "Error type",
  "statusCode": 400
}
```

---

## 7. Integration Recommendations

### 7.1 Priority Order

**Phase 1: Core Functionality (High Priority)**
1. ✅ Authentication - **COMPLETE**
2. User Profile Service - Get/update profile, change password
3. Listings Service - Browse, search, filter listings
4. Bookings Service - Create and manage bookings

**Phase 2: Enhanced Features (Medium Priority)**
5. Search Service - Global search
6. Reviews Service - Reviews and ratings
7. Favorites Service - Favorite management
8. Upload Service - Image/file uploads

**Phase 3: Additional Features (Low Priority)**
9. Notifications Service
10. Zoea Card Service
11. Transactions Service

### 7.2 Implementation Checklist

For each service:

- [ ] Create service class in `lib/core/services/`
- [ ] Define data models in `lib/core/models/`
- [ ] Implement API methods
- [ ] Add error handling
- [ ] Add loading states
- [ ] Create providers (Riverpod)
- [ ] Update UI screens to use service
- [ ] Test with real API
- [ ] Handle edge cases
- [ ] Add offline support (if needed)

### 7.3 Best Practices

1. **Consistent Error Handling:**
   - Use try-catch blocks
   - Provide user-friendly error messages
   - Handle network errors gracefully

2. **Loading States:**
   - Show loading indicators during API calls
   - Use Riverpod AsyncValue for state management

3. **Caching:**
   - Cache user data (already implemented)
   - Cache listings data (consider implementing)
   - Cache search results (optional)

4. **Pagination:**
   - Implement infinite scroll
   - Load more on scroll
   - Show loading indicators

5. **Offline Support:**
   - Cache critical data
   - Show cached data when offline
   - Queue actions for when online

---

## 8. Testing Strategy

### 8.1 Unit Tests

- Test service methods
- Test error handling
- Test data parsing

### 8.2 Integration Tests

- Test API calls with mock server
- Test authentication flow
- Test token refresh

### 8.3 E2E Tests

- Test complete user flows
- Test error scenarios
- Test offline scenarios

---

## 9. Security Considerations

### 9.1 Token Security

- ✅ Tokens stored in SharedPreferences (consider upgrading to flutter_secure_storage)
- ✅ Automatic token refresh
- ✅ Token cleanup on logout

### 9.2 API Security

- ✅ HTTPS only
- ✅ JWT authentication
- ✅ Token expiration handling

### 9.3 Data Security

- ✅ Sensitive data not logged
- ✅ Error messages don't expose sensitive info
- ✅ Input validation

---

## 10. Performance Optimization

### 10.1 API Calls

- Use pagination for large datasets
- Implement request debouncing for search
- Cache frequently accessed data

### 10.2 Image Loading

- Use image caching
- Implement lazy loading
- Optimize image sizes

### 10.3 Network Optimization

- Batch requests when possible
- Use compression
- Implement retry logic

---

## 11. Next Steps

### Immediate Actions

1. **Implement User Service**
   - Get/update profile
   - Change password
   - Update preferences

2. **Implement Listings Service**
   - Browse listings
   - Search and filter
   - Get listing details

3. **Implement Bookings Service**
   - Create bookings
   - View bookings
   - Cancel bookings

### Future Enhancements

1. Implement remaining services
2. Add offline support
3. Implement push notifications
4. Add analytics
5. Optimize performance

---

## 12. Conclusion

The Zoea V2 API is a well-structured RESTful API with comprehensive endpoints for a travel and tourism platform. The Flutter app has successfully integrated authentication and is using SINC API for events. The next priority should be implementing the core services (User, Listings, Bookings) to enable the main app functionality.

**Key Takeaways:**
- ✅ Authentication fully integrated
- ✅ Token management working correctly
- ✅ Events using SINC API (as intended)
- ❌ Most other services need implementation
- 📋 Clear implementation pattern established
- 🎯 Priority order defined for next steps

---

**Last Updated:** December 27, 2024  
**Analysis Based On:**
- API Documentation (Swagger)
- Flutter App Integration Status
- Implemented Services (Auth, Events)
- API Response Patterns

