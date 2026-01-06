# Featured Listings Country Filter Fix

## Date
January 5, 2026

## Issue
The "Add from Recommendations" screen in the itinerary feature was showing "No listings" even though the Explore screen's recommendations section was working fine and showing featured listings.

## Root Cause
The backend's `getFeatured()` method was filtering by `countryId` directly on the `listings` table:

```typescript
// BEFORE (WRONG):
where: { 
  isFeatured: true, 
  status: 'active', 
  deletedAt: null,
  ...(countryId && { countryId }), // Only matches if listing.countryId is populated
}
```

**Problem**: The `countryId` field in the `listings` table is often NULL/not populated, even though every listing has a `cityId`, and every city has a `countryId`. This meant:
- Listings with `countryId` populated: ✅ Matched the filter
- Listings with `countryId` NULL but valid `city.countryId`: ❌ Did NOT match the filter

## Solution
Updated the country filter to check BOTH the direct `countryId` field AND the country through the city relation:

```typescript
// AFTER (CORRECT):
where: { 
  isFeatured: true, 
  status: 'active', 
  deletedAt: null,
  ...(countryId && { 
    OR: [
      { countryId }, // Direct country ID if populated
      { city: { countryId } }, // Through city relation (most common case)
    ]
  }),
}
```

This ensures that listings are found regardless of whether their `countryId` field is populated directly or only through their city relationship.

## Files Modified

### 1. `backend/src/modules/listings/listings.service.ts`

#### Updated `getFeatured()` method:
- ✅ Changed country filter to use OR condition
- ✅ Checks both direct `countryId` and `city.countryId`
- ✅ Added explanatory comment

#### Updated `findAll()` method:
- ✅ Applied same fix for consistency
- ✅ All listing queries now properly filter by country

## Why This Happened

The database schema has `countryId` as an optional field on listings:

```prisma
model Listing {
  countryId  String?  @map("country_id") @db.Uuid  // Optional!
  cityId     String?  @map("city_id") @db.Uuid
  
  country    Country? @relation(fields: [countryId], references: [id])
  city       City?    @relation(fields: [cityId], references: [id])
}
```

When listings are created, they typically only set the `cityId`, not the `countryId`. The country is then accessible through `listing.city.country`, but the direct `listing.countryId` remains NULL.

## Testing

### Before Fix:
```bash
# Request featured listings for Rwanda
GET /api/listings/featured?countryId=<rwanda-uuid>

# Response: [] (empty array)
# Even though there ARE featured listings in Rwandan cities!
```

### After Fix:
```bash
# Request featured listings for Rwanda
GET /api/listings/featured?countryId=<rwanda-uuid>

# Response: [{ id: "...", name: "Safari Lodge", city: { name: "Kigali" }, ... }]
# Now returns all featured listings where city.countryId matches!
```

### Mobile App Testing:
1. ✅ Open Itineraries → Create Itinerary
2. ✅ Click "Add from Recommendations"
3. ✅ Verify featured listings appear (filtered by selected country)
4. ✅ Change country in app settings
5. ✅ Verify recommendations update to show listings from new country

## Impact

This fix affects ALL endpoints that filter listings by country:
- ✅ `GET /api/listings/featured?countryId=...`
- ✅ `GET /api/listings?countryId=...`
- ✅ Any other listing query with country filter

## Alternative Solutions Considered

### Option 1: Populate countryId on all listings (NOT CHOSEN)
```sql
UPDATE listings l
SET country_id = c.country_id
FROM cities c
WHERE l.city_id = c.id
  AND l.country_id IS NULL;
```

**Why not**: This would work but requires a migration and ongoing maintenance. The OR filter is more robust and handles both cases.

### Option 2: Remove countryId from listings table (NOT CHOSEN)
**Why not**: The field may be useful for performance optimization or cases where listings span multiple cities.

### Option 3: Use OR filter (CHOSEN ✅)
**Why yes**: 
- No database migration needed
- Works with existing data
- Handles both populated and NULL countryId cases
- Backward compatible

## Related Issues

This fix is related to:
- `ITINERARY_ENDPOINTS_FIX.md` - Route ordering fix
- `ITINERARY_ADD_FROM_FIX.md` - Data extraction fix for favorites

Together, these three fixes ensure the complete itinerary creation flow works correctly.

## Summary

The country filter for featured listings (and all listings) now properly checks both the direct `countryId` field and the country through the city relation. This ensures listings are found regardless of how they were created or whether their `countryId` field was populated.

**Result**: The "Add from Recommendations" screen now shows featured listings filtered by the selected country, matching the behavior of the Explore screen's recommendations section.

