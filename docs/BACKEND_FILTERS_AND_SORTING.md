# Backend Filters and Sorting Parameters

## Listings API (`GET /api/listings`)

### Supported Filters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | number | Page number (default: 1) | `?page=1` |
| `limit` | number | Items per page (default: 20) | `?limit=20` |
| `type` | string | Listing type | `?type=hotel` |
| `status` | string | Listing status | `?status=active` |
| `cityId` | UUID | Filter by city | `?cityId=uuid` |
| `countryId` | UUID | Filter by country | `?countryId=uuid` |
| `categoryId` | UUID | Filter by category | `?categoryId=uuid` |
| `search` | string | Search in name/description | `?search=hotel` |
| `minPrice` | number | Minimum price filter | `?minPrice=50` |
| `maxPrice` | number | Maximum price filter | `?maxPrice=500` |
| `rating` | number | Minimum rating filter | `?rating=4.0` |
| `isFeatured` | boolean | Featured listings only | `?isFeatured=true` |

### Listing Types
- `hotel`
- `restaurant`
- `attraction`
- `activity`
- `rental`
- `nightlife`
- `spa`

### Listing Statuses
- `draft`
- `pending_review`
- `active`
- `inactive`

### Sorting

**⚠️ IMPORTANT: Sorting is HARDCODED in the backend**

The backend does **NOT** accept a `sortBy` parameter. Results are always sorted by:
1. `isFeatured` (descending) - Featured listings first
2. `rating` (descending) - Higher ratings first
3. `createdAt` (descending) - Newest first

**Code Reference:**
```typescript
orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }, { createdAt: 'desc' }]
```

### Additional Filters (Not in DTO, but supported in service)

The service also supports `amenities` filter (array of amenity IDs), but it's **NOT exposed** in the controller/DTO:
```typescript
amenities?: string[]; // Array of amenity UUIDs
```

### Special Endpoints

#### Featured Listings
- **Endpoint:** `GET /api/listings/featured`
- **Parameters:** `limit` (optional, default: 10)
- **Sorting:** By rating (descending)

#### Nearby Listings
- **Endpoint:** `GET /api/listings/nearby`
- **Required:** `latitude`, `longitude`
- **Optional:** `radius` (km, default: 10), `limit` (default: 20)
- **Sorting:** By distance (ascending)

#### Random Listings
- **Endpoint:** `GET /api/listings/random`
- **Parameters:** `limit` (optional, default: 10)
- **Sorting:** Random

#### Listings by Type
- **Endpoint:** `GET /api/listings/type/:type`
- **Parameters:** `page`, `limit`, `cityId`
- **Sorting:** Same as main endpoint (featured → rating → createdAt)

---

## Reviews API (`GET /api/reviews`)

### Supported Filters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | number | Page number (default: 1) | `?page=1` |
| `limit` | number | Items per page (default: 20) | `?limit=20` |
| `listingId` | UUID | Filter by listing | `?listingId=uuid` |
| `eventId` | UUID | Filter by event | `?eventId=uuid` |
| `tourId` | UUID | Filter by tour | `?tourId=uuid` |
| `userId` | UUID | Filter by user | `?userId=uuid` |
| `status` | string | Review status | `?status=approved` |

### Review Statuses
- `pending` (default for new reviews)
- `approved` (default for public listings)
- `rejected`

### Sorting

**⚠️ IMPORTANT: Sorting is HARDCODED in the backend**

Reviews are always sorted by:
- `createdAt` (descending) - Newest first

**Code Reference:**
```typescript
orderBy: { createdAt: 'desc' }
```

---

## Search API (`GET /api/search`)

### Supported Parameters

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `q` | string | **Yes** | Search query | `?q=hotel` |
| `type` | string | No | Content type | `?type=listing` |
| `cityId` | UUID | No | Filter by city | `?cityId=uuid` |
| `countryId` | UUID | No | Filter by country | `?countryId=uuid` |
| `page` | number | No | Page number (default: 1) | `?page=1` |
| `limit` | number | No | Items per page (default: 20) | `?limit=20` |

### Search Types
- `all` (default) - Search all content types
- `listing` - Search listings only
- `event` - Search events only
- `tour` - Search tours only

### Search Results Structure
When `type=all`, returns:
- `listings` - Up to 5 listings
- `events` - Up to 5 events
- `tours` - Up to 5 tours

When `type` is specific (listing/event/tour), returns paginated results for that type only.

### Sorting

**Listings & Tours:**
- `isFeatured` (descending)
- `rating` (descending)

**Events:**
- `startDate` (ascending) - Upcoming events first

---

## Events API (`GET /api/events`)

### Supported Filters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | number | Page number (default: 1) | `?page=1` |
| `limit` | number | Items per page (default: 25) | `?limit=25` |
| `status` | string | Event status (default: 'published') | `?status=published` |
| `cityId` | UUID | Filter by city | `?cityId=uuid` |
| `countryId` | UUID | Filter by country | `?countryId=uuid` |
| `category` | UUID | Event context/category ID | `?category=uuid` |
| `startDate` | date | Filter events starting from date | `?startDate=2025-01-01` |
| `endDate` | date | Filter events ending before date | `?endDate=2025-12-31` |
| `search` | string | Search in name/description | `?search=concert` |

### Event Statuses
- `draft`
- `published`
- `cancelled`
- `completed`

### Sorting

**⚠️ IMPORTANT: Sorting is HARDCODED in the backend**

Events are always sorted by:
- `startDate` (ascending) - Upcoming events first

**Code Reference:**
```typescript
orderBy: [{ startDate: 'asc' }]
```

---

## Tours API (`GET /api/tours`)

### Supported Filters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | number | Page number (default: 1) | `?page=1` |
| `limit` | number | Items per page (default: 20) | `?limit=20` |
| `status` | string | Tour status (default: 'active') | `?status=active` |
| `cityId` | UUID | Filter by city | `?cityId=uuid` |
| `countryId` | UUID | Filter by country | `?countryId=uuid` |
| `categoryId` | UUID | Filter by category | `?categoryId=uuid` |
| `type` | string | Tour type | `?type=wildlife` |
| `difficulty` | string | Difficulty level | `?difficulty=moderate` |
| `minPrice` | number | Minimum price filter | `?minPrice=100` |
| `maxPrice` | number | Maximum price filter | `?maxPrice=1000` |
| `search` | string | Search in name/description | `?search=safari` |

### Tour Types
- `wildlife`
- `cultural`
- `adventure`
- `hiking`
- `city`
- `beach`
- `safari`

### Difficulty Levels
- `easy`
- `moderate`
- `challenging`

### Tour Statuses
- `draft`
- `active`
- `inactive`

### Sorting

**⚠️ IMPORTANT: Sorting is HARDCODED in the backend**

Tours are always sorted by:
1. `isFeatured` (descending) - Featured tours first
2. `rating` (descending) - Higher ratings first

**Code Reference:**
```typescript
orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }]
```

---

## Summary: Sorting Limitations

### ⚠️ Critical Finding: No Dynamic Sorting

**None of the main APIs support dynamic sorting parameters.** All sorting is hardcoded:

| API | Sorting Order |
|-----|---------------|
| **Listings** | `isFeatured` ↓ → `rating` ↓ → `createdAt` ↓ |
| **Events** | `startDate` ↑ |
| **Tours** | `isFeatured` ↓ → `rating` ↓ |
| **Reviews** | `createdAt` ↓ |
| **Search (Listings/Tours)** | `isFeatured` ↓ → `rating` ↓ |
| **Search (Events)** | `startDate` ↑ |

### Recommendations for Frontend

1. **Filter UI**: Implement all supported filters (price range, rating, location, category, etc.)
2. **Sort UI**: Since backend doesn't support sorting, you have two options:
   - **Option A**: Sort results client-side after fetching (limited to current page)
   - **Option B**: Request backend team to add `sortBy` parameter support
3. **Popular Tab**: The "Popular" tab in category screens can use `isFeatured=true` filter or client-side sorting by rating
4. **Amenities Filter**: Not exposed in API, but service supports it - may need backend update to expose

### Filter Implementation Priority

**High Priority:**
- ✅ Price range (`minPrice`, `maxPrice`)
- ✅ Rating minimum (`rating`)
- ✅ Location (`cityId`, `countryId`)
- ✅ Category (`categoryId`)
- ✅ Search (`search`)

**Medium Priority:**
- ⚠️ Amenities (needs backend support)
- ⚠️ Featured only (`isFeatured`)

**Low Priority:**
- Status filters (mainly for admin/merchant use)
