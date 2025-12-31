# Admin Portal API Analysis

## Overview
This document provides a comprehensive analysis of all available admin APIs in the backend, what's implemented, and what's missing for the admin portal.

## ✅ Implemented Admin APIs

### 1. Users Management (`/admin/users`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/users` - List users with filters and pagination
  - Query params: `page`, `limit`, `search`, `role`, `verificationStatus`, `isActive`
  - Returns: `{ data: User[], meta: { total, page, limit, totalPages } }`
- `GET /admin/users/:id` - Get detailed user profile
- `PATCH /admin/users/:id/status` - Update user status (isActive, isBlocked, verificationStatus)
- `PATCH /admin/users/:id/roles` - Update user roles

**Missing:**
- ❌ Create user endpoint (POST)
- ❌ Delete user endpoint (soft delete)
- ❌ Bulk operations (bulk status update, bulk role update)

---

### 2. Listings Management (`/admin/listings`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/listings` - List listings with filters/pagination
  - Query params: `page`, `limit`, `search`, `status`, `type`, `isFeatured`, `isVerified`, `merchantId`, `countryId`, `cityId`
  - Returns: `{ data: Listing[], meta: { total, page, limit, totalPages } }`
- `GET /admin/listings/:id` - Get listing detail
- `POST /admin/listings` - Create listing on behalf of merchant
- `PUT /admin/listings/:id` - Update listing content
- `PATCH /admin/listings/:id/status` - Update listing moderation/feature state
- `DELETE /admin/listings/:id` - Soft delete listing
- `PATCH /admin/listings/:id/restore` - Restore soft-deleted listing

**Missing:**
- ❌ Bulk operations (bulk status update, bulk delete)

---

### 3. Events Management (`/admin/events`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/events` - List events
  - Query params: `page`, `limit`, `search`, `status`, `organizerId`, `cityId`
  - Returns: `{ data: Event[], meta: { total, page, limit, totalPages } }`
- `GET /admin/events/:id` - Get event detail
- `POST /admin/events` - Create event on behalf of organizer
- `PUT /admin/events/:id` - Update event content
- `PATCH /admin/events/:id/status` - Update event moderation state
- `DELETE /admin/events/:id` - Soft delete event
- `PATCH /admin/events/:id/restore` - Restore soft-deleted event

**Missing:**
- ❌ Bulk operations

---

### 4. Bookings Management (`/admin/bookings`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/bookings` - List bookings with filters
  - Query params: `page`, `limit`, `search`, `status`, `paymentStatus`, `merchantId`, `userId`, `startDate`, `endDate`
  - Returns: `{ data: Booking[], meta: { total, page, limit, totalPages } }`
- `GET /admin/bookings/:id` - Get booking detail
- `POST /admin/bookings` - Create booking on behalf of user
- `PUT /admin/bookings/:id` - Update booking details (notes, guest counts)
- `PATCH /admin/bookings/:id/status` - Update booking status/payment state

**Missing:**
- ❌ Delete booking endpoint
- ❌ Bulk operations
- ❌ Export bookings (CSV/Excel)

---

### 5. Merchants Management (`/admin/merchants`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/merchants` - List merchant profiles with filters
  - Query params: `page`, `limit`, `search`, `status`, `isVerified`, `countryId`, `cityId`
  - Returns: `{ data: Merchant[], meta: { total, page, limit, totalPages } }`
- `GET /admin/merchants/:id` - Get merchant profile detail
- `POST /admin/merchants` - Create merchant profile on behalf of a user
- `PUT /admin/merchants/:id` - Update merchant profile details
- `PATCH /admin/merchants/:id/status` - Update merchant registration status
- `PATCH /admin/merchants/:id/settings` - Update merchant commission, payout & verification settings
- `DELETE /admin/merchants/:id` - Soft delete merchant profile
- `PATCH /admin/merchants/:id/restore` - Restore soft-deleted merchant profile

**Missing:**
- ❌ Bulk operations

---

### 6. Payments Management (`/admin/payments`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/payments/transactions` - List financial transactions
  - Query params: `page`, `limit`, `search`, `status`, `type`, `paymentMethod`, `startDate`, `endDate`, `userId`, `merchantId`
  - Returns: `{ data: Transaction[], meta: { total, page, limit, totalPages } }`
- `GET /admin/payments/transactions/:id` - Get transaction detail
- `PATCH /admin/payments/transactions/:id/status` - Update transaction status
- `GET /admin/payments/payouts` - List merchant payouts
  - Query params: `page`, `limit`, `search`, `status`, `startDate`, `endDate`, `merchantId`
  - Returns: `{ data: Payout[], meta: { total, page, limit, totalPages } }`
- `GET /admin/payments/payouts/:id` - Get payout detail
- `PATCH /admin/payments/payouts/:id/status` - Update payout status / reference

**Missing:**
- ❌ Create payout endpoint
- ❌ Bulk payout processing
- ❌ Export transactions/payouts (CSV/Excel)
- ❌ Refund transaction endpoint

---

### 7. Notifications Management (`/admin/notifications`)
**Status:** ✅ Fully Implemented

**Endpoints:**
- `GET /admin/notifications/requests` - List notification/broadcast requests
  - Query params: `page`, `limit`, `status`, `type`, `startDate`, `endDate`
  - Returns: `{ data: NotificationRequest[], meta: { total, page, limit, totalPages } }`
- `PATCH /admin/notifications/requests/:id/status` - Approve or reject notification request
- `POST /admin/notifications/broadcast` - Create immediate/scheduled broadcast message

**Missing:**
- ❌ Get notification request detail
- ❌ Delete notification request
- ❌ List sent notifications/broadcasts
- ❌ Analytics for notifications (open rates, click rates)

---

## ❌ Missing Admin APIs

### 1. Dashboard/Analytics
**Status:** ❌ Not Implemented

**Missing Endpoints:**
- `GET /admin/dashboard/stats` - Overall platform statistics
  - Should return: users count, listings count, events count, bookings count, revenue, etc.
- `GET /admin/analytics/overview` - Platform analytics overview
- `GET /admin/analytics/revenue` - Revenue analytics with date ranges
- `GET /admin/analytics/users` - User growth analytics
- `GET /admin/analytics/bookings` - Booking trends
- `GET /admin/analytics/listings` - Listing performance

**Note:** Currently, dashboard stats are fetched by making multiple API calls to individual endpoints. A dedicated dashboard endpoint would be more efficient.

---

### 2. Reports & Exports
**Status:** ❌ Not Implemented

**Missing Endpoints:**
- `GET /admin/reports/users/export` - Export users to CSV/Excel
- `GET /admin/reports/bookings/export` - Export bookings to CSV/Excel
- `GET /admin/reports/transactions/export` - Export transactions to CSV/Excel
- `GET /admin/reports/revenue` - Revenue reports (PDF/Excel)
- `GET /admin/reports/analytics` - Analytics reports

---

### 3. System Settings
**Status:** ❌ Not Implemented

**Missing Endpoints:**
- `GET /admin/settings` - Get system settings
- `PUT /admin/settings` - Update system settings
- `GET /admin/settings/categories` - Manage categories
- `GET /admin/settings/cities` - Manage cities
- `GET /admin/settings/countries` - Manage countries

---

### 4. Media Management
**Status:** ⚠️ Partially Implemented (in Media module, not Admin module)

**Available (but not in admin module):**
- `GET /media/accounts` - Get storage accounts status (requires admin)

**Missing:**
- `GET /admin/media` - List all media files
- `DELETE /admin/media/:id` - Delete media file
- `GET /admin/media/stats` - Media storage statistics

---

### 5. Reviews Management
**Status:** ❌ Not Implemented

**Missing Endpoints:**
- `GET /admin/reviews` - List reviews with filters
- `GET /admin/reviews/:id` - Get review detail
- `PATCH /admin/reviews/:id/status` - Update review status (approve/reject)
- `DELETE /admin/reviews/:id` - Delete review

---

### 6. Categories Management
**Status:** ❌ Not Implemented

**Missing Endpoints:**
- `GET /admin/categories` - List categories
- `POST /admin/categories` - Create category
- `PUT /admin/categories/:id` - Update category
- `DELETE /admin/categories/:id` - Delete category

---

### 7. Activity Logs / Audit Trail
**Status:** ❌ Not Implemented

**Missing Endpoints:**
- `GET /admin/activity-logs` - List admin activity logs
- `GET /admin/activity-logs/:id` - Get activity log detail

---

## Summary

### ✅ What's Complete (7 modules):
1. Users Management - ✅ Complete (4 endpoints)
2. Listings Management - ✅ Complete (7 endpoints)
3. Events Management - ✅ Complete (7 endpoints)
4. Bookings Management - ✅ Complete (5 endpoints)
5. Merchants Management - ✅ Complete (8 endpoints)
6. Payments Management - ✅ Complete (6 endpoints)
7. Notifications Management - ✅ Complete (3 endpoints)

**Total Implemented Endpoints:** ~40 endpoints

### ❌ What's Missing (7 areas):
1. Dashboard/Analytics - ❌ No dedicated endpoints
2. Reports & Exports - ❌ No export functionality
3. System Settings - ❌ No settings management
4. Media Management - ⚠️ Partial (in Media module)
5. Reviews Management - ❌ No admin review management
6. Categories Management - ❌ No category management
7. Activity Logs - ❌ No audit trail

---

## Recommendations for Admin Portal Implementation

### Priority 1 (Critical):
1. **Create Dashboard API Service** - Build frontend service for existing endpoints
2. **Users Management Page** - Full CRUD interface
3. **Listings Management Page** - Full CRUD interface
4. **Bookings Management Page** - View and update bookings

### Priority 2 (Important):
5. **Events Management Page** - Full CRUD interface
6. **Merchants Management Page** - Full CRUD interface
7. **Payments Management Page** - View transactions and payouts
8. **Notifications Management Page** - Manage notification requests

### Priority 3 (Nice to Have):
9. **Dashboard Stats Endpoint** - Backend should create dedicated `/admin/dashboard/stats` endpoint
10. **Reports/Exports** - Add export functionality to backend
11. **System Settings Page** - If backend adds settings endpoints
12. **Reviews Management** - If backend adds review management endpoints

---

## Next Steps

1. ✅ **Create API Service Modules** (in progress)
   - Users API ✅
   - Listings API (next)
   - Events API
   - Bookings API
   - Merchants API
   - Payments API
   - Notifications API

2. **Build Management Pages** (after API services)
   - Start with Users Management (most critical)
   - Then Listings, Bookings, Events, Merchants, Payments, Notifications

3. **Request Backend Enhancements** (if needed)
   - Dashboard stats endpoint
   - Export endpoints
   - Bulk operations
   - Reviews management

