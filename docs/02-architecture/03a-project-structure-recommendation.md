# Project Structure Recommendation

## Clarified Requirements

Based on your requirements:

1. **Zoea App** (Main Consumer App)
   - Mobile (Flutter)
   - Web (Public website)

2. **Merchant App** (Business Management)
   - Mobile (Flutter)
   - Web (Merchant portal)

3. **Admin & Partners** (Management & Reports)
   - Web only (Admin dashboard)

---

## Recommended Structure

### Option 1: Flat Structure (Recommended)

```
zoea2/
├── mobile/              # Main consumer app (Flutter)
│   └── For: End users (travelers, tourists)
│
├── web/                 # Main consumer web app
│   └── For: End users (public website)
│
├── merchant-mobile/     # Merchant mobile app (Flutter)
│   └── For: Merchants managing business on mobile
│
├── merchant-web/        # Merchant web portal
│   └── For: Merchants managing business on web
│
├── admin/              # Admin & Partners dashboard (Web)
│   └── For: Platform admins & partners
│
├── backend/            # Shared API (NestJS)
│   └── Serves all apps
│
├── docs/               # Documentation
├── scripts/            # Shared scripts
├── migration/          # Database migrations
└── database/           # Database schemas
```

### Option 2: Grouped Structure

```
zoea2/
├── consumer/           # Main consumer apps
│   ├── mobile/        # Flutter mobile app
│   └── web/           # Public web app
│
├── merchant/            # Merchant apps
│   ├── mobile/        # Merchant mobile app
│   └── web/           # Merchant web portal
│
├── admin/              # Admin & Partners
│   └── web/           # Admin dashboard (web only)
│
├── backend/            # Shared API
├── docs/
├── scripts/
├── migration/
└── database/
```

---

## Recommendation: **Option 1 (Flat Structure)**

### Why Flat Structure?

1. **Clarity**: Each app is at the same level, easy to find
2. **Independence**: Each app has its own git repo (as you mentioned)
3. **Deployment**: Easier to deploy independently
4. **Team Work**: Clear ownership per app
5. **Consistency**: Matches current structure (mobile, backend, admin, web)

---

## Detailed Structure

### 1. Main Consumer Apps

#### `mobile/` - Consumer Mobile App (Flutter)
```
mobile/
├── lib/
│   ├── core/           # Shared core
│   └── features/       # Consumer features
│       ├── explore/
│       ├── listings/
│       ├── bookings/
│       └── profile/
└── ...
```
**Purpose**: End users browsing and booking
**Users**: Travelers, tourists, locals
**Platform**: iOS, Android

#### `web/` - Consumer Web App
```
web/
├── src/
│   ├── app/            # Next.js app directory
│   ├── components/     # UI components
│   └── lib/            # Utilities
└── ...
```
**Purpose**: Public website for end users
**Users**: General public
**Platform**: Web browsers
**Domain**: `zoea.africa` or `www.zoea.africa`

---

### 2. Merchant Apps

#### `merchant-mobile/` - Merchant Mobile App (Flutter)
```
merchant-mobile/
├── lib/
│   ├── core/           # Shared core (different from consumer)
│   └── features/       # Merchant features
│       ├── dashboard/  # Business dashboard
│       ├── listings/   # Manage listings
│       ├── bookings/   # Manage bookings
│       ├── analytics/   # Business analytics
│       └── revenue/    # Revenue tracking
└── ...
```
**Purpose**: Merchants managing business on mobile
**Users**: Hotel owners, restaurant owners, tour operators
**Platform**: iOS, Android
**Domain**: `merchant.zoea.africa` (deep linking)

#### `merchant-web/` - Merchant Web Portal
```
merchant-web/
├── src/
│   ├── app/            # Next.js app directory
│   ├── components/     # Merchant UI components
│   └── lib/            # Utilities
└── ...
```
**Purpose**: Merchants managing business on web
**Users**: Merchants (desktop/web preferred)
**Platform**: Web browsers
**Domain**: `merchant.zoea.africa`

---

### 3. Admin & Partners

#### `admin/` - Admin & Partners Dashboard (Web)
```
admin/
├── src/
│   ├── app/
│   │   ├── admin/      # Admin features
│   │   └── partners/   # Partner features
│   ├── components/
│   └── lib/
└── ...
```
**Purpose**: Platform management and reports
**Users**: Platform admins, partners, analysts
**Platform**: Web browsers only
**Domain**: `admin.zoea.africa`

**Features**:
- Platform-wide analytics
- User management
- Merchant management
- Content moderation
- Reports and insights
- Partner dashboards

---

## API Structure

### Backend Endpoints

```
backend/
└── src/modules/
    ├── auth/           # Shared authentication
    ├── listings/       # Shared listings
    ├── bookings/       # Shared bookings
    ├── admin/          # Admin-only endpoints
    │   └── GET /admin/merchants
    │   └── GET /admin/analytics
    ├── merchant/        # Merchant-only endpoints
    │   └── GET /merchant/listings (own)
    │   └── GET /merchant/bookings (own)
    │   └── GET /merchant/analytics (own)
    └── consumer/       # Consumer endpoints
        └── GET /listings (public)
        └── GET /bookings (user's own)
```

---

## Git Repositories

Each app maintains its own repository:

```
zoea2/
├── mobile/            # git: zoea.mobile.2.git
├── web/               # git: (to be configured)
├── merchant-mobile/   # git: (to be configured)
├── merchant-web/      # git: (to be configured)
├── admin/             # git: (to be configured)
└── backend/           # git: zoea2-apis.git
```

---

## Domain Structure

```
zoea.africa              # Main consumer web app
www.zoea.africa          # Main consumer web app (alias)
merchant.zoea.africa     # Merchant web portal
admin.zoea.africa        # Admin & Partners dashboard
api.zoea.africa          # Backend API (or zoea-africa.qtsoftwareltd.com/api)
```

---

## Shared Resources

### What Can Be Shared?

1. **Backend API**: All apps use the same API
2. **Design System**: Shared UI components (if using same framework)
3. **Types**: Shared TypeScript types (if applicable)
4. **Utilities**: Shared utility functions

### What Should NOT Be Shared?

1. **Business Logic**: Different for each app
2. **UI Components**: Tailored per app
3. **Navigation**: Different user flows
4. **State Management**: App-specific

---

## Migration Plan

### Phase 1: Current State
```
✅ mobile/          # Consumer mobile (exists)
✅ backend/         # API (exists)
✅ admin/           # Admin dashboard (exists)
✅ web/             # Consumer web (exists, needs setup)
```

### Phase 2: Add Merchant Apps
```
1. Create merchant-mobile/ directory
2. Create merchant-web/ directory
3. Extract merchant features from admin/ (if any)
4. Build merchant-specific features
```

### Phase 3: Refine Admin
```
1. Focus admin/ on platform management
2. Remove merchant self-service (moved to merchant apps)
3. Add partner-specific features
```

---

## Technology Stack Summary

| App | Framework | Platform | Users |
|-----|-----------|----------|-------|
| **mobile/** | Flutter | iOS, Android | Consumers |
| **web/** | Next.js | Web | Consumers |
| **merchant-mobile/** | Flutter | iOS, Android | Merchants |
| **merchant-web/** | Next.js | Web | Merchants |
| **admin/** | Next.js | Web | Admins, Partners |
| **backend/** | NestJS | API | All apps |

---

## Benefits of This Structure

### 1. Clear Separation
- ✅ Each app has distinct purpose
- ✅ No confusion about which app does what
- ✅ Easy to find code

### 2. Independent Development
- ✅ Teams can work in parallel
- ✅ Different release cycles
- ✅ No merge conflicts

### 3. Independent Deployment
- ✅ Deploy consumer apps separately
- ✅ Deploy merchant apps separately
- ✅ Deploy admin separately
- ✅ Scale based on usage

### 4. Security
- ✅ Clear security boundaries
- ✅ Role-based access per app
- ✅ Different authentication flows

### 5. User Experience
- ✅ Tailored UX per user type
- ✅ Optimized for each platform
- ✅ Focused features

---

## File Structure Example

```
zoea2/
├── mobile/                    # Consumer mobile app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── web/                       # Consumer web app
│   ├── src/
│   ├── public/
│   └── package.json
│
├── merchant-mobile/            # Merchant mobile app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── merchant-web/               # Merchant web portal
│   ├── src/
│   ├── public/
│   └── package.json
│
├── admin/                     # Admin & Partners dashboard
│   ├── src/
│   ├── public/
│   └── package.json
│
├── backend/                   # Shared API
│   ├── src/
│   ├── prisma/
│   └── package.json
│
├── docs/                      # Documentation
├── scripts/                   # Shared scripts
├── migration/                 # Database migrations
└── database/                  # Database schemas
```

---

## Next Steps

1. ✅ **Create `merchant-mobile/` directory**
   - Initialize Flutter project
   - Set up merchant-specific features

2. ✅ **Create `merchant-web/` directory**
   - Initialize Next.js project
   - Set up merchant portal

3. ✅ **Update `admin/`**
   - Focus on platform management
   - Add partner features

4. ✅ **Update `web/`**
   - Set up consumer web app
   - Public-facing features

5. ✅ **Update IntelliJ configuration**
   - Add new modules
   - Update `.idea/modules.xml`

6. ✅ **Update documentation**
   - Project structure
   - Features per app
   - Deployment guides

---

## Recommendation Summary

**✅ Use Flat Structure with 5 Apps:**

1. `mobile/` - Consumer mobile
2. `web/` - Consumer web
3. `merchant-mobile/` - Merchant mobile
4. `merchant-web/` - Merchant web
5. `admin/` - Admin & Partners (web)

**All sharing the same `backend/` API.**

This structure:
- ✅ Matches your requirements
- ✅ Clear separation of concerns
- ✅ Independent development
- ✅ Scalable and maintainable
- ✅ Industry best practice

