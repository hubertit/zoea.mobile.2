# Itinerary "Add From" Features Fix

## Date
January 5, 2026

## Issues Found

### 1. "Add from Favorites" Showing "Unknown"
When users tried to add items from their favorites to an itinerary, all items displayed as "Unknown" with no details.

### 2. "Add from Recommendations" Showing "No Listings"
The recommendations screen showed an empty state even though there should be featured listings.

## Root Causes

### Issue 1: Data Structure Mismatch in Favorites

**Problem**: The favorites API returns a nested structure, but the mobile app was trying to read fields directly from the top level.

**Backend API Response**:
```json
{
  "data": [
    {
      "id": "favorite-uuid",
      "userId": "user-uuid",
      "listingId": "listing-uuid",
      "listing": {
        "id": "listing-uuid",
        "name": "Safari Lodge",
        "slug": "safari-lodge",
        "images": [...],
        "city": { "name": "Kigali" }
      },
      "event": null,
      "tour": null
    }
  ],
  "meta": { "total": 10, "page": 1, "limit": 20 }
}
```

**What the Mobile App Was Doing** (WRONG):
```dart
final name = favorite['name']; // Returns null - name is inside favorite['listing']!
final itemId = favorite['id']; // Returns favorite UUID, not listing UUID!
```

**What It Should Do** (CORRECT):
```dart
final item = favorite['listing']; // Extract the nested item
final name = item['name']; // Now we get the actual name
final itemId = item['id']; // Now we get the listing UUID
```

### Issue 2: No Featured Listings in Database

**Problem**: The recommendations screen is working correctly, but there are no listings marked as `isFeatured: true` in the database, so it returns an empty array.

**Backend Query**:
```typescript
this.prisma.listing.findMany({
  where: { 
    isFeatured: true,  // No listings have this flag set!
    status: 'active', 
    deletedAt: null,
  },
  ...
})
```

## Solutions

### Fix 1: Update add_from_favorites_screen.dart

Added `_extractItem()` method to properly extract the nested listing/event/tour from the favorite object:

```dart
/// Extract the actual item (listing, event, or tour) from the favorite object
Map<String, dynamic> _extractItem(Map<String, dynamic> favorite) {
  // Favorites API returns: { listing: {...}, event: {...}, tour: {...} }
  if (favorite['listing'] != null) {
    return favorite['listing'] as Map<String, dynamic>;
  }
  if (favorite['event'] != null) {
    return favorite['event'] as Map<String, dynamic>;
  }
  if (favorite['tour'] != null) {
    return favorite['tour'] as Map<String, dynamic>;
  }
  // Fallback to the favorite object itself (shouldn't happen)
  return favorite;
}
```

Updated all methods to use the extracted item:
- `_buildFavoriteCard()` - Now extracts item before reading name/image/location
- `_getImageUrl()` - Updated to handle both `images` (listings/tours) and `attachments` (events)
- `_getLocation()` - Updated to handle `address` (listings), `locationName` (events), and `city`
- ListView builder - Now extracts item to get correct ID and type
- `_addSelectedItems()` - Now returns the actual item, not the favorite wrapper

### Fix 2: Set Featured Listings (Database Task)

**Action Required**: Run a database update to mark some listings as featured:

```sql
-- Example: Mark top-rated listings as featured
UPDATE listings 
SET is_featured = true 
WHERE rating >= 4.5 
  AND status = 'active' 
  AND deleted_at IS NULL
LIMIT 20;
```

Or use the admin panel to manually mark listings as "Featured".

## Testing

### Test "Add from Favorites"
1. ✅ Add some listings/events to favorites
2. ✅ Go to Itineraries → Create Itinerary
3. ✅ Click "Add from Favorites"
4. ✅ Verify items show correct names, images, and locations (not "Unknown")
5. ✅ Select items and add them
6. ✅ Verify they appear in the itinerary

### Test "Add from Recommendations"
1. ⚠️ **Requires featured listings in database**
2. Mark some listings as `isFeatured: true`
3. Go to Itineraries → Create Itinerary
4. Click "Add from Recommendations"
5. Verify featured listings appear
6. Select items and add them
7. Verify they appear in the itinerary

## Files Modified

1. ✅ `mobile/lib/features/itineraries/screens/add_from_favorites_screen.dart`
   - Added `_extractItem()` method
   - Updated `_buildFavoriteCard()` to extract item first
   - Updated `_getImageUrl()` to handle events and listings
   - Updated `_getLocation()` to handle different location fields
   - Updated ListView builder to extract item and determine type
   - Updated `_addSelectedItems()` to return actual item data

## Summary

The "Add from Favorites" feature is now **fixed** - it properly extracts data from the nested API response structure.

The "Add from Recommendations" feature is **working correctly** - it's just showing the empty state because there are no featured listings in the database. This requires a database update to mark some listings as featured.

## Related Issues

This fix relates to the earlier route ordering fix documented in `ITINERARY_ENDPOINTS_FIX.md`. Together, these fixes ensure:
1. Routes navigate to the correct screens (not trying to load them as API endpoints)
2. Data displays correctly when loaded (proper extraction from API responses)

