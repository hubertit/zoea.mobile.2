# Itinerary Endpoints Fix

## Issue
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

## Solution
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

## Result
Now the endpoints return proper 404 responses with clear messages instead of 500 errors:

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
`add-from-favorites` and `add-from-recommendations` are client-side navigation routes in the mobile app, not API endpoints. The mobile app uses:
- `favoritesProvider` for favorites
- `featuredListingsProvider` for recommendations

These backend routes exist only to return a helpful 404 if accidentally called as API endpoints.

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

## Date
January 5, 2026

