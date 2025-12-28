# API Reference Quick Guide

## Base URL

**Production**: `https://zoea-africa.qtsoftwareltd.com/api`  
**Local**: `http://localhost:3000/api`  
**Documentation**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

## Authentication

All protected endpoints require JWT token in header:
```
Authorization: Bearer <accessToken>
```

---

## Endpoints Quick Reference

### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/register` | Register new user | ❌ Public |
| POST | `/auth/login` | Login | ❌ Public |
| POST | `/auth/refresh` | Refresh token | ❌ Public |
| GET | `/auth/profile` | Get profile | ✅ Required |

### Users

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/users/me` | Get current user | ✅ Required |
| PUT | `/users/me` | Update profile | ✅ Required |
| PUT | `/users/me/password` | Change password | ✅ Required |
| PUT | `/users/me/email` | Update email | ✅ Required |
| PUT | `/users/me/phone` | Update phone | ✅ Required |
| DELETE | `/users/me` | Delete account | ✅ Required |

### Listings

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/listings` | Get listings (filtered) | ❌ Public |
| GET | `/listings/:id` | Get listing details | ❌ Public |
| POST | `/listings` | Create listing | ✅ Admin |
| PUT | `/listings/:id` | Update listing | ✅ Admin |
| DELETE | `/listings/:id` | Delete listing | ✅ Admin |

**Query Parameters** (GET /listings):
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20)
- `type`: Listing type (hotel, restaurant, etc.)
- `categoryId`: Category UUID
- `cityId`: City UUID
- `search`: Search query
- `minPrice`, `maxPrice`: Price range
- `sortBy`: Sort field

### Categories

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/categories` | Get categories | ❌ Public |
| GET | `/categories/:id` | Get category | ❌ Public |
| POST | `/categories` | Create category | ✅ Admin |

**Query Parameters** (GET /categories):
- `parentId`: Get subcategories
- `includeInactive`: Include inactive categories

### Bookings

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/bookings` | Get my bookings | ✅ Required |
| GET | `/bookings/upcoming` | Get upcoming | ✅ Required |
| GET | `/bookings/:id` | Get booking details | ✅ Required |
| POST | `/bookings` | Create booking | ✅ Required |
| PUT | `/bookings/:id` | Update booking | ✅ Required |
| POST | `/bookings/:id/cancel` | Cancel booking | ✅ Required |
| POST | `/bookings/:id/confirm-payment` | Confirm payment | ✅ Required |

**Query Parameters** (GET /bookings):
- `page`, `limit`: Pagination
- `status`: pending, confirmed, completed, cancelled
- `type`: hotel, restaurant, event, tour

### Reviews

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/reviews` | Get reviews | ❌ Public |
| GET | `/reviews/my` | Get my reviews | ✅ Required |
| POST | `/reviews` | Create review | ✅ Required |
| PUT | `/reviews/:id` | Update review | ✅ Required |
| DELETE | `/reviews/:id` | Delete review | ✅ Required |
| POST | `/reviews/:id/helpful` | Mark helpful | ✅ Required |

**Query Parameters** (GET /reviews):
- `listingId`: Filter by listing
- `eventId`: Filter by event
- `tourId`: Filter by tour
- `page`, `limit`: Pagination

### Favorites

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/favorites` | Get favorites | ✅ Required |
| POST | `/favorites` | Add favorite | ✅ Required |
| DELETE | `/favorites` | Remove favorite | ✅ Required |
| POST | `/favorites/toggle` | Toggle favorite | ✅ Required |
| GET | `/favorites/check` | Check if favorited | ✅ Required |

**Query Parameters** (DELETE /favorites):
- `listingId`: Remove listing favorite
- `eventId`: Remove event favorite
- `tourId`: Remove tour favorite

### Search

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/search` | Global search | ❌ Public |

**Query Parameters**:
- `q`: Search query (required)
- `category`: Filter by category
- `type`: Filter by type
- `city`: Filter by city
- `latitude`, `longitude`, `radius`: Location search

---

## Request/Response Examples

### Create Hotel Booking

**Request**:
```json
POST /bookings
{
  "bookingType": "hotel",
  "listingId": "uuid-here",
  "roomTypeId": "uuid-here",
  "checkInDate": "2025-12-01",
  "checkOutDate": "2025-12-05",
  "guestCount": 2,
  "adults": 2,
  "children": 0,
  "specialRequests": "Late checkout"
}
```

**Response**:
```json
{
  "id": "booking-uuid",
  "bookingNumber": "BK-2025-001",
  "status": "pending",
  "totalAmount": 150000,
  "currency": "RWF",
  "checkInDate": "2025-12-01",
  "checkOutDate": "2025-12-05",
  "createdAt": "2025-12-28T08:00:00Z"
}
```

### Create Restaurant Booking

**Request**:
```json
POST /bookings
{
  "bookingType": "restaurant",
  "listingId": "uuid-here",
  "bookingDate": "2025-12-01",
  "bookingTime": "19:00",
  "partySize": 4,
  "guests": [{
    "fullName": "John Doe",
    "email": "john@example.com",
    "phone": "+250788000000",
    "isPrimary": true
  }]
}
```

---

## Error Responses

### Standard Error Format

```json
{
  "message": "Error message or array of validation errors",
  "error": "Error type",
  "statusCode": 400
}
```

### Common Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `409` - Conflict (e.g., booking unavailable)
- `500` - Internal Server Error

---

## Pagination

### Request
```
GET /listings?page=1&limit=20
```

### Response
```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

## Filtering & Sorting

### Listings Filter Example
```
GET /listings?categoryId=uuid&type=hotel&minPrice=50000&maxPrice=200000&sortBy=rating
```

### Available Sort Fields
- `rating` - Sort by rating
- `price` - Sort by price
- `createdAt` - Sort by creation date
- `name` - Sort alphabetically

---

## Full API Documentation

For complete API documentation with request/response schemas, visit:
- **Swagger UI**: `https://zoea-africa.qtsoftwareltd.com/api/docs`
- **Local**: `http://localhost:3000/api/docs` (when backend is running)

