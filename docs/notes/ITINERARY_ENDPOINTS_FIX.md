# Itinerary Endpoints Fix

## Issue 1: Backend Route Ordering (FIXED)
The mobile app was receiving 500 Internal Server errors when navigating to:
- `/itineraries/add-from-favorites`
- `/itineraries/add-from-recommendations`

### Root Cause
The backend controller had a **route ordering problem**. The specific routes `add-from-favorites` and `add-from-recommendations` were defined AFTER the parameterized route `:id`.

In NestJS/Express, routes are matched in order, so:
```
GET /itineraries/:id               <- This matched first
GET /itineraries/add-from-favorites  <- Never reached
```

When the app made a request to `/itineraries/add-from-favorites`, the router matched it to `GET /itineraries/:id` and tried to parse `add-from-favorites` as a UUID, causing this error:

```
Inconsistent column data: Error creating UUID, invalid character: 
expected an optional prefix of `urn:uuid:` followed by [0-9a-fA-F-], 
found `r` at 6
```

## Issue 2: Mobile App Route Ordering (FIXED - January 5, 2026)
After fixing the backend, the mobile app was still making unwanted API calls to:
- `GET /api/itineraries/add-from-recommendations` 
- `GET /api/itineraries/add-from-favorites`

These should be client-side navigation routes only, not API endpoints.

### Root Cause
The mobile app's `app_router.dart` had the SAME route ordering problem! The parameterized route `/itineraries/:id` was defined BEFORE the specific routes:

```dart
// WRONG ORDER:
GoRoute(path: '/itineraries/:id', ...) // This matched first!
GoRoute(path: '/itineraries/add-from-favorites', ...)
GoRoute(path: '/itineraries/add-from-recommendations', ...)
```

When a user navigated to `/itineraries/add-from-recommendations`:
1. GoRouter matched it to `/itineraries/:id` (with `id` = `"add-from-recommendations"`)
2. This loaded `ItineraryDetailScreen`  
3. `ItineraryDetailScreen` called the itinerary service to fetch itinerary with ID `"add-from-recommendations"`
4. Service made API call: `GET /api/itineraries/add-from-recommendations`
5. Backend returned 404 error: "This is a client-side route"

## Solution - Backend
Moved the specific routes BEFORE the parameterized `:id` route in `itineraries.controller.ts`:

```typescript
@Get('my')
async getMyItineraries() { ... }

// These MUST come BEFORE :id route
@Get('add-from-favorites')
async addFromFavorites() {
  throw new NotFoundException('This is a client-side route. Use /favorites endpoint instead.');
}

@Get('add-from-recommendations')
async addFromRecommendations() {
  throw new NotFoundException('This is a client-side route. Use /listings/featured endpoint instead.');
}

// Parameterized route comes AFTER specific routes
@Get(':id')
async getItinerary(@Param('id') id: string) { ... }
```

## Solution - Mobile App
Moved the specific routes BEFORE the parameterized `:id` route in `mobile/lib/core/router/app_router.dart`:

```dart
// CORRECT ORDER:
GoRoute(
  path: '/itineraries',
  builder: (context, state) => const ItinerariesScreen(),
),
GoRoute(
  path: '/itineraries/create',
  builder: (context, state) {
    final itinerary = state.extra as Itinerary?;
    return ItineraryCreateScreen(itinerary: itinerary);
  },
),
// IMPORTANT: Specific routes MUST come BEFORE parameterized `:id` route
GoRoute(
  path: '/itineraries/add-from-favorites',
  builder: (context, state) => const AddFromFavoritesScreen(),
),
GoRoute(
  path: '/itineraries/add-from-recommendations',
  builder: (context, state) => const AddFromRecommendationsScreen(),
),
// Parameterized route comes AFTER specific routes
GoRoute(
  path: '/itineraries/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ItineraryDetailScreen(itineraryId: id);
  },
),
```

## Result
Now the endpoints return proper 404 responses with clear messages instead of 500 errors, and the mobile app correctly routes to the client-side screens without making unnecessary API calls:

```json
{
  "message": "This is a client-side route. Use /favorites endpoint instead.",
  "error": "Not Found",
  "statusCode": 404
}
```

## Tested Endpoints ✅

All itinerary endpoints are working correctly:

1. **POST /api/itineraries** - Create new itinerary ✅
2. **GET /api/itineraries/my** - Get user's itineraries ✅
3. **GET /api/itineraries/:id** - Get specific itinerary ✅
4. **PUT /api/itineraries/:id** - Update itinerary ✅
5. **DELETE /api/itineraries/:id** - Delete itinerary ✅
6. **POST /api/itineraries/:id/share** - Share itinerary ✅
7. **GET /api/itineraries/shared/:token** - Get shared itinerary (public) ✅
8. **GET /api/itineraries/add-from-favorites** - Returns 404 with helpful message ✅
9. **GET /api/itineraries/add-from-recommendations** - Returns 404 with helpful message ✅

## Note
`add-from-favorites` and `add-from-recommendations` are client-side navigation routes in the mobile app, not API endpoints.

### How They Actually Work:
1. **User clicks "Add from Favorites" or "Add from Recommendations"** in the itinerary create screen
2. **Mobile app navigates** to `/itineraries/add-from-favorites` or `/itineraries/add-from-recommendations`
3. **Screen displays** a list of favorites or featured listings using:
   - `favoritesProvider` (calls `/api/favorites`)
   - `featuredListingsProvider` (calls `/api/listings/featured`)
4. **User selects items** from the list
5. **Screen returns** the selected items back to the create screen
6. **No API calls** to `/api/itineraries/add-from-*` should ever happen

The backend routes exist only to return a helpful 404 message if something mistakenly tries to call them as API endpoints.

## Deployment
- ✅ Primary server (172.16.40.61)
- ✅ Backup server (172.16.40.60)
- ✅ Committed and pushed to Git

## Additional Fix: Swagger Documentation
After deployment, we discovered that these routes were still appearing in the Swagger/OpenAPI documentation at `/api/docs-json`, which could cause automated tools or monitoring systems to attempt calling them.

### Solution
Added `@ApiExcludeEndpoint()` decorator to both routes to hide them from Swagger documentation:

```typescript
import { ApiExcludeEndpoint } from '@nestjs/swagger';

@Get('add-from-favorites')
@ApiExcludeEndpoint()  // Hide from Swagger docs
async addFromFavorites() {
  throw new NotFoundException('This is a client-side route. Use /favorites endpoint instead.');
}

@Get('add-from-recommendations')
@ApiExcludeEndpoint()  // Hide from Swagger docs
async addFromRecommendations() {
  throw new NotFoundException('This is a client-side route. Use /listings/featured endpoint instead.');
}
```

### Verification
Before fix - routes appeared in Swagger:
```
"/api/itineraries/add-from-favorites"
"/api/itineraries/add-from-recommendations"
```

After fix - routes excluded from Swagger:
```
"/api/itineraries"
"/api/itineraries/my"
"/api/itineraries/shared/{token}"
"/api/itineraries/{id}"
"/api/itineraries/{id}/share"
```

Routes still function correctly (returning 404 with helpful message) but are no longer advertised in API documentation.

## Summary
This issue occurred in BOTH the backend AND the mobile app due to the same root cause: **route ordering**. In both routing systems (NestJS and GoRouter), specific routes must be defined BEFORE parameterized routes to avoid incorrect matches.

## Dates
- **Backend Fix**: January 5, 2026 (morning)
- **Mobile App Fix**: January 5, 2026 (afternoon)

