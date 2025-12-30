# Search Feature Analysis

**Date**: December 28, 2024  
**Status**: ✅ Backend Ready, ⚠️ Mobile Needs Implementation

---

## Executive Summary

The backend **already supports** search history with automatic saving and endpoints for fetching recent/popular searches. The mobile app needs to be updated to:
1. Use authenticated API calls to pass `userId` for search history tracking
2. Fetch and display real search history from the API
3. Fetch and display trending searches from the API

---

## 1. Backend Analysis

### 1.1 Search Endpoint

**Endpoint**: `GET /api/search?q=query&type=all&cityId=...&countryId=...&page=1&limit=20`

**Status**: ✅ **FULLY IMPLEMENTED**

**Features**:
- Searches across listings, events, and tours
- Supports filtering by type, city, country
- **Automatically saves search history** if:
  - `userId` is provided (from JWT token), OR
  - Query length > 2 characters
- Returns: `{listings: [...], events: [...], tours: [...]}`

**Implementation**: `backend/src/modules/search/search.service.ts:8-108`

### 1.2 Search History Endpoints

**Status**: ✅ **FULLY IMPLEMENTED**

#### Get Search History
- **Endpoint**: `GET /api/search/history?limit=10`
- **Auth**: ✅ Required (JwtAuthGuard)
- **Returns**: Array of search history items with `query`, `createdAt`, `filters`
- **Implementation**: `backend/src/modules/search/search.controller.ts:45-52`

#### Clear Search History
- **Endpoint**: `DELETE /api/search/history`
- **Auth**: ✅ Required (JwtAuthGuard)
- **Returns**: `{success: true}`
- **Implementation**: `backend/src/modules/search/search.controller.ts:54-60`

### 1.3 Trending Searches Endpoint

**Status**: ✅ **FULLY IMPLEMENTED**

- **Endpoint**: `GET /api/search/trending?cityId=...&countryId=...`
- **Auth**: ❌ Not required (public)
- **Returns**: 
  ```json
  {
    "trendingSearches": ["query1", "query2", ...],
    "featuredListings": [...],
    "upcomingEvents": [...],
    "popularTours": [...]
  }
  ```
- **Logic**: Groups searches from last 7 days, orders by count
- **Implementation**: `backend/src/modules/search/search.controller.ts:37-43`

### 1.4 Database Schema

**Status**: ✅ **READY**

**Model**: `SearchHistory` in `backend/prisma/schema.prisma:1164-1176`

```prisma
model SearchHistory {
  id          String    @id @default(uuid_generate_v4())
  userId      String?   @map("user_id")
  sessionId   String?   @map("session_id")
  query       String
  filters     Json?
  resultCount Int?      @map("result_count")
  location    Unsupported("geography")?
  createdAt   DateTime? @default(now()) @map("created_at")
  user        User?     @relation(...)
}
```

**Fields**:
- ✅ `userId` - Links to user (nullable for anonymous searches)
- ✅ `query` - Search query string
- ✅ `filters` - JSON object with type, cityId, countryId
- ✅ `createdAt` - Timestamp (automatically set)
- ✅ `resultCount` - Optional count of results

---

## 2. Mobile Analysis

### 2.1 Current Implementation

**SearchService** (`mobile/lib/core/services/search_service.dart`):
- ✅ Basic search functionality implemented
- ❌ Uses unauthenticated Dio instance
- ❌ Doesn't pass `userId` (so search history not saved for logged-in users)
- ❌ Missing methods for:
  - `getSearchHistory()`
  - `getTrendingSearches()`
  - `clearSearchHistory()`

**SearchScreen** (`mobile/lib/features/search/screens/search_screen.dart`):
- ✅ UI for recent/popular searches exists
- ❌ Uses mock data (`_getRecentSearches()`, `_getPopularSearches()`)
- ❌ Doesn't fetch real data from API
- ✅ Search functionality works (but doesn't save history for logged-in users)

**SearchProvider** (`mobile/lib/core/providers/search_provider.dart`):
- ✅ Basic search provider exists
- ❌ Missing providers for:
  - Search history
  - Trending searches

### 2.2 What Needs to Be Implemented

1. **Update SearchService**:
   - Use authenticated Dio instance
   - Add `getSearchHistory(limit)` method
   - Add `getTrendingSearches(cityId?, countryId?)` method
   - Add `clearSearchHistory()` method
   - Update `search()` to use authenticated Dio (so userId is passed automatically)

2. **Update SearchProvider**:
   - Add `searchHistoryProvider` (FutureProvider)
   - Add `trendingSearchesProvider` (FutureProvider)

3. **Update SearchScreen**:
   - Replace mock data with real API calls
   - Fetch search history on screen load
   - Fetch trending searches on screen load
   - Add "Clear History" functionality
   - Show timestamps for recent searches

---

## 3. Implementation Plan

### Phase 1: Update SearchService ✅
- [ ] Change to use `AppConfig.authenticatedDioInstance()`
- [ ] Add `getSearchHistory(limit)` method
- [ ] Add `getTrendingSearches(cityId?, countryId?)` method
- [ ] Add `clearSearchHistory()` method

### Phase 2: Update SearchProvider ✅
- [ ] Add `searchHistoryProvider`
- [ ] Add `trendingSearchesProvider`

### Phase 3: Update SearchScreen ✅
- [ ] Replace `_getRecentSearches()` with API call
- [ ] Replace `_getPopularSearches()` with API call
- [ ] Add "Clear History" button/action
- [ ] Display timestamps for recent searches
- [ ] Handle loading/error states

### Phase 4: Testing ✅
- [ ] Test search with logged-in user (should save history)
- [ ] Test search with anonymous user (should still work)
- [ ] Test fetching search history
- [ ] Test fetching trending searches
- [ ] Test clearing search history

---

## 4. API Endpoints Summary

| Method | Endpoint | Auth | Purpose | Status |
|--------|----------|------|---------|--------|
| GET | `/api/search?q=query` | Optional | Search listings/events/tours | ✅ Ready |
| GET | `/api/search/history?limit=10` | Required | Get user's search history | ✅ Ready |
| DELETE | `/api/search/history` | Required | Clear user's search history | ✅ Ready |
| GET | `/api/search/trending` | Optional | Get trending searches | ✅ Ready |

---

## 5. Data Flow

### 5.1 Search Flow (with History)
1. User types in search box
2. Mobile calls `GET /api/search?q=query` with authenticated Dio
3. Backend extracts `userId` from JWT token
4. Backend performs search
5. Backend saves search to `SearchHistory` table (if userId exists or query > 2 chars)
6. Backend returns search results
7. Mobile displays results

### 5.2 Recent Searches Flow
1. User opens search screen
2. Mobile calls `GET /api/search/history?limit=10` with authenticated Dio
3. Backend returns user's recent searches (ordered by createdAt DESC)
4. Mobile displays in "Recent Searches" section

### 5.3 Trending Searches Flow
1. User opens search screen
2. Mobile calls `GET /api/search/trending` (no auth required)
3. Backend groups searches from last 7 days, orders by count
4. Backend returns `trendingSearches` array
5. Mobile displays in "Popular Searches" section

---

## 6. Conclusion

✅ **Backend is fully ready** - All endpoints exist and work correctly  
⚠️ **Mobile needs implementation** - Service and UI need to be updated to use real data

**Estimated Effort**: Low-Medium (2-3 hours)
- Service updates: ~30 minutes
- Provider updates: ~15 minutes
- UI updates: ~1 hour
- Testing: ~30 minutes

**No backend changes needed** - Everything is already implemented!

