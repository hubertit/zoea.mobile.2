# Ask Zoea Tour Card Navigation Fix

## Date
January 5, 2026

## Issue
When users tapped on tour recommendation cards in the Ask Zoea chat interface, they were redirected to an error screen showing "Failed to load tour details" instead of the tour detail page.

## Root Cause

### Problem 1: Wrong Provider Used
The `TourDetailScreen` was using `tourBySlugProvider` to load tour data, but the route parameter `:id` contains a UUID (not a slug). The backend sends tour cards with UUID IDs in the `params.id` field.

**File**: `mobile/lib/features/explore/screens/tour_detail_screen.dart`
```dart
// BEFORE (WRONG):
final tourAsync = ref.watch(tourBySlugProvider(widget.tourId));
```

**Issue**: When a UUID is passed to `tourBySlugProvider`, it tries to find a tour with that UUID as a slug, which fails, resulting in the error screen.

### Problem 2: Navigation Logic Could Be More Robust
The card navigation was using a simple `replaceAll` which works but could be improved to handle multiple route parameters.

## Solution

### Fix 1: Use Correct Provider
Changed `TourDetailScreen` to use `tourByIdProvider` instead of `tourBySlugProvider`:

```dart
// AFTER (CORRECT):
final tourAsync = ref.watch(tourByIdProvider(widget.tourId));
```

This correctly loads tours by their UUID ID, which matches what the backend sends in the card `params.id` field.

### Fix 2: Improved Navigation Logic
Enhanced the card navigation in `ask_zoea_screen.dart` to handle route parameters more robustly:

```dart
// BEFORE:
final id = params['id'] as String;
context.push(route.replaceAll(':id', id));

// AFTER:
String navigationPath = route;
params.forEach((key, value) {
  if (value != null) {
    navigationPath = navigationPath.replaceAll(':$key', value.toString());
  }
});

// Fallback for :id if still present
if (navigationPath.contains(':id') && params['id'] != null) {
  navigationPath = navigationPath.replaceAll(':id', params['id'].toString());
}

context.push(navigationPath);
```

This handles:
- Multiple route parameters (not just `:id`)
- Null safety
- Fallback for common `:id` parameter

## Files Modified

1. ✅ `mobile/lib/features/explore/screens/tour_detail_screen.dart`
   - Changed from `tourBySlugProvider` to `tourByIdProvider`
   - Added comment explaining the change

2. ✅ `mobile/lib/features/assistant/screens/ask_zoea_screen.dart`
   - Enhanced navigation logic in `_buildCard()` method
   - Now handles all route parameters dynamically
   - Added fallback for `:id` parameter

## How It Works

### Backend Card Structure
When the AI assistant suggests a tour, the backend returns a card like:
```json
{
  "type": "tour",
  "id": "uuid-here",
  "title": "3-Day Nyungwe Forest Escape",
  "subtitle": "Kigali • Tour",
  "route": "/tour/:id",
  "params": {
    "id": "4cfefad8-f63c-42cd-8dd1-076750b999eb"
  }
}
```

### Navigation Flow
1. User taps tour card in Ask Zoea chat
2. `_buildCard()` extracts route and params
3. Navigation path is constructed: `/tour/:id` → `/tour/4cfefad8-f63c-42cd-8dd1-076750b999eb`
4. GoRouter navigates to `/tour/:id` route
5. `TourDetailScreen` receives the UUID as `tourId`
6. `tourByIdProvider` loads the tour by UUID
7. Tour details are displayed successfully ✅

## Testing

### Before Fix:
1. Open Ask Zoea
2. Ask: "recommend me some tours"
3. Tap on a tour card
4. ❌ Error: "Failed to load tour details"

### After Fix:
1. Open Ask Zoea
2. Ask: "recommend me some tours"
3. Tap on a tour card
4. ✅ Success: Tour detail screen loads with full tour information

## Related Routes

The fix ensures these routes work correctly:
- `/tour/:id` - Tour detail by UUID (from Ask Zoea cards)
- `/tour/:slug` - Tour detail by slug (if needed in future)

## Notes

- The route parameter name is `:id` but it can contain either a UUID or a slug
- For Ask Zoea cards, it's always a UUID
- The `tourByIdProvider` correctly handles UUIDs
- If slug-based navigation is needed in the future, we can add a check to detect UUID vs slug format

## Summary

The tour card navigation now works correctly! When users tap on tour recommendations in Ask Zoea, they are properly navigated to the tour detail screen with all tour information displayed.

