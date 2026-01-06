# Near Me Section - Restaurants Only Update

**Date:** January 5, 2026  
**Change Type:** Feature Modification  
**Status:** ✅ **COMPLETED & DEPLOYED**

---

## Change Summary

Modified the "Near Me" section in the mobile app to display **only restaurant listings** instead of random listings of all types.

---

## What Was Changed

### Backend Changes

#### 1. Updated Service Method
**File:** `backend/src/modules/listings/listings.service.ts`

**Before:**
```typescript
const listings = await this.prisma.$queryRaw<Array<{ id: string }>>`
  SELECT l.id
  FROM listings l
  WHERE l.status = 'active' 
    AND l.deleted_at IS NULL
  ORDER BY RANDOM()
  LIMIT ${limit}
`;
```

**After:**
```typescript
const listings = await this.prisma.$queryRaw<Array<{ id: string }>>`
  SELECT l.id
  FROM listings l
  WHERE l.status = 'active' 
    AND l.deleted_at IS NULL
    AND l.type = 'restaurant'  // ✨ NEW FILTER
  ORDER BY RANDOM()
  LIMIT ${limit}
`;
```

#### 2. Updated API Documentation
**File:** `backend/src/modules/listings/listings.controller.ts`

Updated the endpoint description to reflect that it returns only restaurants:
- Summary: "Get random **restaurant** listings"
- Description: "Only returns active **restaurant** listings"

---

## API Endpoint

### GET `/listings/random`

**Query Parameters:**
- `limit` (optional): Number of restaurants to return (default: 10)

**Response Example:**
```json
[
  {
    "id": "...",
    "name": "Asian Kitchen",
    "type": "restaurant",
    "category": {...},
    "city": {...},
    "images": [...]
  },
  {
    "id": "...",
    "name": "About Thyme Restaurant",
    "type": "restaurant",
    "category": {...},
    "city": {...},
    "images": [...]
  }
]
```

---

## Verification

### Test Command:
```bash
curl "https://zoea-africa.qtsoftwareltd.com/api/listings/random?limit=5"
```

### Result:
✅ All returned listings have `"type": "restaurant"`

**Sample Results:**
- Asian Kitchen
- Quick Homes Rwanda
- MIMI'S RICH FOODZ KIGALI (Nigerian restaurant)
- About Thyme Restaurant
- Kigali so food

---

## Mobile App Impact

### Current Behavior
The mobile app's "Near Me" section (`mobile/lib/features/explore/screens/explore_screen.dart`) already uses `randomListingsProvider(5)` which calls this endpoint.

**No mobile app changes needed!** The mobile app will automatically start showing only restaurants.

---

## Why This Change?

1. **Better User Experience:** The "Near Me" section now focuses on dining options, making it more useful for users looking for places to eat
2. **More Relevant:** Mixing hotels, attractions, and activities with "Near Me" was confusing
3. **Consistent with User Expectations:** Users typically expect "Near Me" to show nearby restaurants and dining options

---

## Future Considerations

This is still a **temporary solution** until proper geolocation is implemented. The plan is to:

1. ✅ Currently: Show random restaurants (DONE)
2. 🔄 Phase 2: Implement actual geolocation-based "near me" functionality
3. 🔄 Phase 3: Allow users to filter by different listing types (restaurants, hotels, attractions, etc.)

---

## Deployment Details

### Build & Deploy Steps:
1. ✅ Modified backend service and controller
2. ✅ Built backend: `npm run build`
3. ✅ Synced to server: `rsync -avz ./src/ qt@172.16.40.61:~/zoea-backend/src/`
4. ✅ Rebuilt Docker container: `docker-compose down && docker-compose up --build -d`
5. ✅ Tested API endpoint
6. ✅ Updated documentation

**Deployment Time:** ~2 minutes  
**Downtime:** ~10 seconds (during container restart)

---

## Files Modified

### Backend
- `backend/src/modules/listings/listings.service.ts` - Added restaurant type filter
- `backend/src/modules/listings/listings.controller.ts` - Updated API documentation

### Documentation
- `docs/14-troubleshooting/02-temporary-changes.md` - Updated to reflect restaurant-only change
- `docs/14-troubleshooting/02a-temporary-changes.md` - Updated to reflect restaurant-only change

### No Changes Needed
- ✅ Mobile app code (already using the endpoint correctly)
- ✅ Database schema
- ✅ API route paths

---

## Testing Checklist

- [x] Backend builds successfully
- [x] API returns only restaurants
- [x] API returns correct number of listings
- [x] All returned listings have `type: 'restaurant'`
- [x] Listings have proper relations (category, city, images)
- [x] Documentation updated

---

**Implemented By:** AI Assistant  
**Deployed:** January 5, 2026, 9:30 AM UTC  
**Server:** 172.16.40.61 (Primary)

