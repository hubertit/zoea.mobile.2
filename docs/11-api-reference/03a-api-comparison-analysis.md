# API Comparison Analysis: Codebase vs Documentation

## Executive Summary

**API Documentation URL:** [https://zoea-africa.qtsoftwareltd.com/api/docs](https://zoea-africa.qtsoftwareltd.com/api/docs)

**Status:** ⚠️ **MISMATCH DETECTED** - The codebase API configuration does not match the documented API.

---

## 1. Base URL Comparison

### API Documentation
- **Base URL:** `https://zoea-africa.qtsoftwareltd.com/api`
- **No version prefix** (no `/v1`)

### Codebase Configuration
- **Configured Base URL:** `https://api.zoea.africa/v1` (in `app_config.dart`)
- **Events Service Base URL:** `https://api-prod.sinc.today/events/v1/public` (in `events_service.dart`)

### Issues Identified
1. ❌ **Different domains:**
   - Documentation: `zoea-africa.qtsoftwareltd.com`
   - Codebase: `api.zoea.africa`
   - Events: `api-prod.sinc.today`

2. ❌ **Version mismatch:**
   - Documentation: No `/v1` prefix
   - Codebase: Uses `/v1` prefix

3. ✅ **Events API uses SINC service (INTENTIONAL):**
   - Events are fetched from SINC API (`api-prod.sinc.today`) - This is the intended design
   - Main Zoea API has `/api/event/explore-event` endpoint that's SINC-compatible, but SINC API is being used directly

---

## 2. Endpoint Comparison

### 2.1 Authentication Endpoints

#### API Documentation Endpoints:
```
POST   /api/auth/register      - Register a new user
POST   /api/auth/login         - Login user
POST   /api/auth/refresh       - Refresh access token
GET    /api/auth/profile       - Get current user profile
```

#### Codebase Configuration:
```dart
// In app_config.dart
static const String authEndpoint = '/auth';
// Expected: /v1/auth (with base URL)
```

#### Codebase Implementation:
```dart
// In auth_service.dart - MOCK IMPLEMENTATION
// No actual API calls - uses hardcoded test accounts
```

**Status:** ❌ **NOT IMPLEMENTED** - Auth service uses mock data, not real API

**Expected Implementation:**
- Should call: `POST https://zoea-africa.qtsoftwareltd.com/api/auth/login`
- Should call: `POST https://zoea-africa.qtsoftwareltd.com/api/auth/register`
- Should call: `POST https://zoea-africa.qtsoftwareltd.com/api/auth/refresh`

---

### 2.2 User Endpoints

#### API Documentation Endpoints:
```
GET    /api/users/me                    - Get current user profile
PUT    /api/users/me                    - Update current user profile
DELETE /api/users/me                    - Delete account (soft delete)
PUT    /api/users/me/email              - Update email address
PUT    /api/users/me/phone              - Update phone number
PUT    /api/users/me/password           - Change password
PUT    /api/users/me/profile-image      - Update profile image
PUT    /api/users/me/background-image  - Update background image
GET    /api/users/me/preferences       - Get user preferences
PUT    /api/users/me/preferences       - Update user preferences
GET    /api/users/me/stats             - Get user statistics
GET    /api/users/me/visited-places     - Get visited places
GET    /api/users/me/businesses        - Get all my businesses (merchant profile)
POST   /api/users/me/businesses        - Create a new business
GET    /api/users/me/businesses/{id}   - Get specific business by ID
PUT    /api/users/me/businesses/{id}   - Update a business
DELETE /api/users/me/businesses/{id}   - Delete a business
GET    /api/users/me/organizer-profiles - Get all my organizer profiles
POST   /api/users/me/organizer-profiles - Create organizer profile
GET    /api/users/me/organizer-profiles/{id} - Get specific organizer profile
PUT    /api/users/me/organizer-profiles/{id} - Update organizer profile
DELETE /api/users/me/organizer-profiles/{id} - Delete organizer profile
GET    /api/users/me/tour-operator-profiles - Get all my tour operator profiles
POST   /api/users/me/tour-operator-profiles - Create tour operator profile
GET    /api/users/me/tour-operator-profiles/{id} - Get specific tour operator profile
PUT    /api/users/me/tour-operator-profiles/{id} - Update tour operator profile
DELETE /api/users/me/tour-operator-profiles/{id} - Delete tour operator profile
GET    /api/users/username/{username}   - Get user by username (public profile)
GET    /api/users/{id}                 - Get user by ID (public profile)
```

#### Codebase Configuration:
```dart
// In app_config.dart
static const String usersEndpoint = '/users';
```

#### Codebase Implementation:
- ❌ **NOT IMPLEMENTED** - No user service found
- Profile screens exist but don't make API calls

**Status:** ❌ **MISSING** - User endpoints are not implemented

---

### 2.3 Listings Endpoints

#### API Documentation Endpoints:
```
GET    /api/listings                    - Get all listings with filter
POST   /api/listings                   - Create a new listing
GET    /api/listings/featured          - Get featured listings
GET    /api/listings/nearby            - Get nearby listings based on coordinates
GET    /api/listings/type/{type}        - Get listings by type
GET    /api/listings/slug/{slug}       - Get listing by slug
GET    /api/listings/merchant/{merchantId} - Get all listings for a merchant/business
GET    /api/listings/{id}              - Get listing by ID
PUT    /api/listings/{id}              - Update a listing
DELETE /api/listings/{id}              - Delete a listing (soft delete)
GET    /api/listings/{id}/room         - Get room types for a hotel listing
POST   /api/listings/{id}/room        - Create room type for hotel
GET    /api/listings/{id}/table        - Get tables for a restaurant listing
POST   /api/listings/{id}/table       - Create table for restaurant
GET    /api/listings/{id}/availability - Check room availability for date
POST   /api/listings/{id}/submit      - Submit listing for review
POST   /api/listings/{id}/image       - Add image to listing
DELETE /api/listings/{id}/image/{imageId} - Remove image from listing
PUT    /api/listings/{id}/image/reorder - Reorder listing images
PUT    /api/listings/{id}/amenities   - Set listing amenities
PUT    /api/listings/room/{roomTypeId} - Update room type
DELETE /api/listings/room/{roomTypeId} - Delete room type (soft delete)
PUT    /api/listings/table/{tableId}  - Update table
DELETE /api/listings/table/{tableId}  - Delete table (soft delete)
```

#### Codebase Configuration:
```dart
// In app_config.dart
static const String listingsEndpoint = '/listings';
static const String hotelsEndpoint = '/hotels';
static const String restaurantsEndpoint = '/restaurants';
static const String toursEndpoint = '/tours';
```

#### Codebase Implementation:
- ❌ **NOT IMPLEMENTED** - No listings service found
- Listings screens exist but likely use mock data

**Status:** ❌ **MISSING** - Listings endpoints are not implemented

---

### 2.4 Events Endpoints

#### API Documentation Endpoints:
```
GET    /api/event                      - Get all events (explore-events compatible)
GET    /api/event/explore-event        - Get events for explore (SINC API compatible)
GET    /api/event/upcoming             - Get upcoming events
GET    /api/event/this-week            - Get events happening this week
GET    /api/event/slug/{slug}          - Get event by slug
GET    /api/event/{id}                 - Get event by ID
POST   /api/event/{id}/like            - Like/unlike an event
GET    /api/event/{id}/comment         - Get event comments
POST   /api/event/{id}/comment         - Add a comment to an event
```

#### Codebase Configuration:
```dart
// In app_config.dart
static const String eventsEndpoint = '/events';
```

#### Codebase Implementation:
```dart
// In events_service.dart
static const String _baseUrl = 'https://api-prod.sinc.today/events/v1/public';

// Endpoints used:
GET /explore-events (with query parameters)
```

**Status:** ✅ **IMPLEMENTED (Using SINC API - As Intended)**

**Current Implementation:**
- ✅ Fetches events from SINC API (intentional design decision)
- ✅ Supports pagination, filtering, search
- ✅ Fully functional events service
- ⚠️ Missing like/comment functionality (can be added later if needed)

**Note:** The main Zoea API has `/api/event/explore-event` endpoint that's SINC-compatible, but the decision has been made to use SINC API directly for now.

---

### 2.5 Tours Endpoints

#### API Documentation Endpoints:
```
GET    /api/tour                       - Get all tours with filter
POST   /api/tour                       - Create a new tour
GET    /api/tour/featured              - Get featured tours
GET    /api/tour/slug/{slug}           - Get tour by slug
GET    /api/tour/{id}                  - Get tour by ID
PUT    /api/tour/{id}                  - Update a tour
DELETE /api/tour/{id}                  - Delete a tour
GET    /api/tour/{id}/schedule         - Get available schedules for a tour
```

#### Codebase Configuration:
```dart
// In app_config.dart
static const String toursEndpoint = '/tours';
```

#### Codebase Implementation:
- ❌ **NOT IMPLEMENTED** - No tours service found

**Status:** ❌ **MISSING** - Tours endpoints are not implemented

---

### 2.6 Bookings Endpoints

#### API Documentation Endpoints:
```
GET    /api/booking                    - Get my bookings
POST   /api/booking                    - Create a booking
GET    /api/booking/upcoming           - Get upcoming bookings
GET    /api/booking/{id}               - Get booking by ID
PUT    /api/booking/{id}               - Update a booking
DELETE /api/booking/{id}               - Cancel a booking
GET    /api/booking/{id}/invoice       - Get booking invoice
```

#### Codebase Configuration:
```dart
// In app_config.dart
static const String bookingsEndpoint = '/bookings';
```

#### Codebase Implementation:
- ❌ **NOT IMPLEMENTED** - No bookings service found
- Booking screens exist but don't make API calls

**Status:** ❌ **MISSING** - Bookings endpoints are not implemented

---

### 2.7 Other Endpoints (From Documentation)

The API documentation also includes endpoints for:
- **Reviews** - `/api/review/*`
- **Favorites** - `/api/favorite/*`
- **Search** - `/api/search/*`
- **Notifications** - `/api/notification/*`
- **Upload** - `/api/upload/*`
- **Zoea Card** - `/api/zoea-card/*`
- **Transactions** - `/api/transaction/*`
- **Recommendations** - Likely exists but not visible in snapshot

#### Codebase Configuration:
```dart
// In app_config.dart - These endpoints are defined but not used
static const String reviewsEndpoint = '/reviews';
static const String searchEndpoint = '/search';
static const String notificationsEndpoint = '/notifications';
static const String uploadEndpoint = '/upload';
static const String zoeaCardEndpoint = '/zoea-card';
static const String transactionsEndpoint = '/transactions';
static const String recommendationsEndpoint = '/recommendations';
```

**Status:** ❌ **MISSING** - These endpoints are configured but not implemented

---

## 3. Summary of Mismatches

### 3.1 Base URL Issues

| Aspect | Documentation | Codebase | Status |
|--------|--------------|----------|--------|
| Domain | `zoea-africa.qtsoftwareltd.com` | `api.zoea.africa` | ❌ Different |
| Version | No `/v1` | `/v1` | ❌ Mismatch |
| Events API | Has `/api/event/explore-event` | Uses `api-prod.sinc.today` | ✅ Intentional (SINC API) |

### 3.2 Implementation Status

| Feature | Documentation Endpoints | Codebase Status |
|---------|------------------------|-----------------|
| Authentication | ✅ `/api/auth/*` | ❌ Mock implementation |
| Users | ✅ `/api/users/*` | ❌ Not implemented |
| Listings | ✅ `/api/listings/*` | ❌ Not implemented |
| Events | ✅ `/api/event/*` | ✅ Uses SINC API (intentional) |
| Tours | ✅ `/api/tour/*` | ❌ Not implemented |
| Bookings | ✅ `/api/booking/*` | ❌ Not implemented |
| Reviews | ✅ `/api/review/*` | ❌ Not implemented |
| Favorites | ✅ `/api/favorite/*` | ❌ Not implemented |
| Search | ✅ `/api/search/*` | ❌ Not implemented |
| Notifications | ✅ `/api/notification/*` | ❌ Not implemented |
| Upload | ✅ `/api/upload/*` | ❌ Not implemented |
| Zoea Card | ✅ `/api/zoea-card/*` | ❌ Not implemented |
| Transactions | ✅ `/api/transaction/*` | ❌ Not implemented |

---

## 4. Required Changes

### 4.1 Immediate Actions

1. **Update Base URL:**
   ```dart
   // In app_config.dart - CHANGE FROM:
   static const String apiBaseUrl = 'https://api.zoea.africa/v1';
   
   // TO:
   static const String apiBaseUrl = 'https://zoea-africa.qtsoftwareltd.com/api';
   ```

2. **Remove `/v1` prefix from all endpoints:**
   ```dart
   // Current (WRONG):
   static const String authEndpoint = '/auth';  // Becomes /v1/auth
   
   // Should be:
   static const String authEndpoint = '/auth';  // Becomes /api/auth
   ```

3. **Events Service (No Change Required):**
   ```dart
   // In events_service.dart - KEEP AS IS:
   static const String _baseUrl = 'https://api-prod.sinc.today/events/v1/public';
   
   // Note: Using SINC API directly is the intended design
   // Main API has /api/event/explore-event but SINC is being used for now
   ```

### 4.2 Implementation Priority

**High Priority:**
1. ✅ Implement Authentication Service (`/api/auth/*`)
2. ✅ Implement User Service (`/api/users/*`)
3. ✅ Implement Bookings Service (`/api/booking/*`)
4. ⏸️ Events Service - Already implemented using SINC API (no changes needed)

**Medium Priority:**
5. ✅ Implement Listings Service (`/api/listings/*`)
6. ✅ Implement Search Service (`/api/search/*`)
7. ✅ Implement Favorites Service (`/api/favorite/*`)

**Low Priority:**
8. ✅ Implement Reviews Service (`/api/review/*`)
9. ✅ Implement Notifications Service (`/api/notification/*`)
10. ✅ Implement Upload Service (`/api/upload/*`)

---

## 5. Authentication Flow

### Current (Mock):
```dart
// Hardcoded test accounts
if (email == 'explorer@zoea.africa' && password == 'Pass123') {
  // Return mock user
}
```

### Expected (Real API):
```dart
// POST https://zoea-africa.qtsoftwareltd.com/api/auth/login
{
  "email": "user@example.com",
  "password": "password"
}

// Response:
{
  "accessToken": "...",
  "refreshToken": "...",
  "user": { ... }
}
```

---

## 6. Recommendations

### 6.1 Configuration Management
- Create environment-specific configs (dev/staging/prod)
- Use environment variables for base URLs
- Implement feature flags for API migration

### 6.2 Service Layer Refactoring
- Create base service class with common functionality
- Implement proper error handling
- Add request/response interceptors for auth tokens
- Implement token refresh mechanism

### 6.3 Migration Strategy
1. **Phase 1:** Update base URL and test connectivity
2. **Phase 2:** Implement authentication service
3. **Phase 3:** Implement remaining services incrementally
4. **Phase 4:** Remove mock implementations
5. **Note:** Events service will continue using SINC API (no migration needed)

### 6.4 Testing
- Create API integration tests
- Mock API responses for unit tests
- Test error scenarios
- Verify authentication flow

---

## 7. Conclusion

**The codebase API configuration does NOT match the documented API.**

**Key Findings:**
- ❌ Different base URL domain
- ❌ Version prefix mismatch
- ❌ Most endpoints not implemented
- ✅ Events use SINC API (intentional design decision)
- ❌ Authentication is mocked, not real

**Action Required:**
1. Update base URL to match documentation
2. Implement missing services
3. Replace mock authentication with real API calls
4. ✅ Events service - No changes needed (using SINC API as intended)

**Estimated Effort:**
- Base URL update: 1-2 hours
- Authentication service: 4-8 hours
- User service: 8-16 hours
- Other services: 40-80 hours total
- Events service: ✅ Already complete (using SINC API)

---

**Analysis Date:** December 27, 2024  
**API Documentation:** [https://zoea-africa.qtsoftwareltd.com/api/docs](https://zoea-africa.qtsoftwareltd.com/api/docs)  
**Codebase Version:** 2.0.15+1

