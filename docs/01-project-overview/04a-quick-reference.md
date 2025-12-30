# Quick Reference Guide

## Project Location

**Main Directory**: `/Users/macbookpro/projects/flutter/zoea2`

## Applications

| App | Location | Tech | Git Repo |
|-----|----------|------|----------|
| Consumer Mobile | `mobile/` | Flutter | `zoea.mobile.2.git` |
| Merchant Mobile | `merchant-mobile/` | Flutter | `zoea-partner-mobile.git` |
| Backend | `backend/` | NestJS | `zoea2-apis.git` |
| Admin | `admin/` | Next.js | (to be configured) |
| Consumer Web | `web/` | Next.js | (to be configured) |
| Merchant Web | `merchant-web/` | Next.js | (to be configured) |

## Quick Commands

### Consumer Mobile
```bash
cd mobile
flutter pub get && flutter run
```

### Merchant Mobile
```bash
cd merchant-mobile
flutter pub get && flutter run
```

### Backend
```bash
cd backend
npm install && npm run start:dev
```

### Admin
```bash
cd admin
npm install && npm run dev
```

## API Base URL

**Production**: `https://zoea-africa.qtsoftwareltd.com/api`  
**Docs**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

## Key Features by App

### Consumer Mobile
- Browse listings, Book accommodations/restaurants, Favorites, Reviews, Search

### Merchant Mobile
- Business dashboard, Manage listings, Manage bookings, Analytics, Revenue tracking

### Backend
- All API endpoints, Business logic, Database operations, Authentication

### Admin
- Dashboard, User/Listing/Booking management, Analytics, Moderation

## Common Flows

### Booking Flow
1. User selects listing → 2. Choose dates/details → 3. Submit booking → 4. Payment → 5. Confirmation

### Authentication Flow
1. Login/Register → 2. Receive tokens → 3. Store tokens → 4. Auto-refresh on expiry

## Who Does What

- **Mobile**: UI, user interactions, API calls
- **Backend**: Business logic, data storage, API provision
- **Admin**: Management UI, moderation, analytics
- **Web**: Public information, marketing (future)

## Documentation

See `docs/README.md` for complete documentation index.

