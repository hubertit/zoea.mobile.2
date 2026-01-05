# Temporary Changes

This document tracks temporary changes made to the codebase that need to be reverted or updated in the future.

## Near Me Section - Random Restaurants (Temporary)

**Date:** December 28, 2025  
**Updated:** January 5, 2026  
**Status:** Temporary - To be replaced with geolocation implementation

### Overview

The "Near Me" section on the explore screen currently displays **random restaurant listings** instead of actual geolocation-based nearby listings. This is a temporary solution until proper geolocation functionality is implemented.

### What Was Changed

#### Backend Changes

1. **New Endpoint:** `GET /listings/random`
   - **File:** `backend/src/modules/listings/listings.controller.ts`
   - **Method:** `getRandom(@Query('limit') limit?: string)`
   - Returns random active **restaurant** listings using PostgreSQL's `RANDOM()` function
   - Default limit: 10 listings
   - **Filter:** Only returns listings where `type = 'restaurant'`

2. **New Service Method:** `getRandom(limit = 10)`
   - **File:** `backend/src/modules/listings/listings.service.ts`
   - Uses `ORDER BY RANDOM()` in PostgreSQL to fetch random restaurant listings
   - Filters by `status: 'active'`, `deletedAt: null`, and `type: 'restaurant'`
   - Includes full relations (category, city, images)

#### Flutter Changes

1. **New Service Method:** `getRandomListings({int limit = 10})`
   - **File:** `mobile/lib/core/services/listings_service.dart`
   - Calls `GET /listings/random` endpoint
   - Includes error handling

2. **New Provider:** `randomListingsProvider`
   - **File:** `mobile/lib/core/providers/listings_provider.dart`
   - FutureProvider that accepts a limit parameter
   - Fetches random listings from the API

3. **Updated Explore Screen:**
   - **File:** `mobile/lib/features/explore/screens/explore_screen.dart`
   - Changed `_buildNearMeSection()` to use `randomListingsProvider(10)` instead of `nearbyListingsProvider`
   - Removed dependency on `NearbyListingsParams` and coordinates

### Why This Change Was Made

- Geolocation functionality is not yet implemented
- Users need to see listings in the "Near Me" section
- Random restaurant listings provide a temporary solution to populate the section with relevant dining options
- **Update (Jan 5, 2026):** Changed from all listing types to restaurants only to make the "Near Me" section more focused and relevant
- Better user experience than showing an empty section

### How to Revert When Geolocation is Ready

When geolocation is implemented, follow these steps:

1. **Update Explore Screen:**
   ```dart
   // In mobile/lib/features/explore/screens/explore_screen.dart
   // Change from:
   final nearbyAsync = ref.watch(randomListingsProvider(10));
   
   // Back to:
   final nearbyAsync = ref.watch(
     nearbyListingsProvider(
       NearbyListingsParams(
         latitude: userLatitude,  // Get from geolocation
         longitude: userLongitude, // Get from geolocation
         radiusKm: 10.0,
         limit: 10,
       ),
     ),
   );
   ```

2. **Optional: Keep Random Endpoint**
   - The `/listings/random` endpoint can be kept for other use cases
   - Or removed if not needed elsewhere

3. **Remove Temporary Code (if desired):**
   - Remove `randomListingsProvider` from `listings_provider.dart`
   - Remove `getRandomListings()` from `listings_service.dart`
   - Remove `getRandom()` from backend service
   - Remove `GET /listings/random` endpoint from controller

### Current Implementation Details

- **Number of Listings:** 10 random listings
- **Selection Method:** PostgreSQL `RANDOM()` function
- **Filtering:** Only active, non-deleted listings
- **Refresh:** New random listings on each API call

### Related Files

- `backend/src/modules/listings/listings.controller.ts` - Random endpoint
- `backend/src/modules/listings/listings.service.ts` - Random service method
- `mobile/lib/core/services/listings_service.dart` - Random service method
- `mobile/lib/core/providers/listings_provider.dart` - Random provider
- `mobile/lib/features/explore/screens/explore_screen.dart` - UI implementation

### Notes

- The existing `nearbyListingsProvider` and `getNearbyListings()` methods remain intact and functional
- The backend `getNearby()` method is still available and working
- This change only affects the "Near Me" section on the explore screen
- When geolocation is ready, simply switch back to using `nearbyListingsProvider` with actual coordinates

