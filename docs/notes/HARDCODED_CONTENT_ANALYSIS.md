# Hardcoded Content Analysis Report

This document identifies all hardcoded content in the mobile app that should be fetched from an API instead.

## 🔴 Critical - High Priority

### 1. Emergency Numbers (Quick Actions)
**Location**: `mobile/lib/features/explore/screens/explore_screen.dart` (lines 700-734)

**Hardcoded Data**:
- Emergency: 112
- Traffic Accidents: 113
- Abuse by Police Officer: 3511
- Anti Corruption: 997
- Maritime Problems: 110
- Driving License Queries: 118
- Fire and Rescue: 111

**Issue**: Emergency numbers may vary by country/region. Should be dynamic based on user's location.

**Recommendation**: Create API endpoint `/api/emergency-numbers` that returns numbers based on country/city.

---

### 2. Taxi Phone Number
**Location**: `mobile/lib/features/explore/screens/explore_screen.dart` (line 562)

**Hardcoded Data**: `'1010'`

**Issue**: Taxi service number may vary by location or service provider.

**Recommendation**: Add to emergency/quick-actions API or create `/api/quick-actions` endpoint.

---

### 3. MICE Events (Mock Data)
**Location**: `mobile/lib/features/events/screens/events_screen.dart` (lines 1007-1136)

**Hardcoded Data**: 12+ hardcoded MICE events with:
- Event names, dates, locations
- Descriptions
- Categories
- Images (using placeholder KCC image)

**Issue**: Events are completely hardcoded. There's a TODO comment indicating this should be replaced.

**Recommendation**: 
- Events API already exists (`/api/events`)
- Should fetch MICE events from API with category filter
- Remove `_getMockMiceEvents()` method

---

### 4. Specials/Deals (Mock Data)
**Location**: `mobile/lib/features/explore/screens/specials_screen.dart` (lines 192-249)
**Also used in**: `mobile/lib/features/explore/screens/explore_screen.dart` (line 3342)

**Hardcoded Data**: 6+ special offers including:
- Gorilla Trekking
- Cultural Village Tour
- Lake Kivu Boat Trip
- Volcanoes National Park
- Nyungwe Forest Canopy Walk
- Akagera Safari

**Issue**: Specials are completely hardcoded with mock prices and descriptions.

**Recommendation**: 
- Backend has `Promotion` model in schema
- Use `/api/promotions` or `/api/listings?isFeatured=true` endpoint
- Create promotions API endpoint if not exists

---

## 🟡 Medium Priority

### 5. Subcategories (Fallback Data)
**Location**: `mobile/lib/features/explore/screens/category_search_screen.dart` (lines 196-220)

**Hardcoded Data**: Fallback subcategories for:
- Dining: Restaurants, Cafes, Fast Food
- Nightlife: Bars, Clubs, Lounges
- Experiences: Tours, Adventures, Cultural, Operators

**Issue**: Used as fallback when API doesn't provide children categories. Should be removed once API is fixed.

**Recommendation**: 
- Fix categories API to always return children
- Remove hardcoded fallback

---

### 6. Category Definitions (Expected Categories)
**Location**: `mobile/lib/core/services/categories_service.dart` (lines 246-260)

**Hardcoded Data**: Expected parent categories list:
- Events, Dining, Experiences, Nightlife, Accommodation, Shopping, Attractions, Sports, National Parks, Museums, Transport, Hiking, Services

**Issue**: Used to ensure categories exist. This is acceptable for initialization but should be configurable.

**Recommendation**: Keep for initialization, but ensure API returns all categories properly.

---

### 7. Nightlife Places (Mock Data)
**Location**: `mobile/lib/features/explore/screens/nightlife_screen.dart` (lines 423-520)

**Hardcoded Data**: 8+ mock nightlife venues with:
- Names, locations, ratings, reviews
- Price ranges
- Categories (Bars, Clubs, Lounges)
- Images

**Issue**: Should fetch from listings API.

**Recommendation**: Use `/api/listings?type=nightlife` endpoint.

---

### 8. Shopping Places (Mock Data)
**Location**: `mobile/lib/features/explore/screens/shopping_screen.dart` (lines 246-343)

**Hardcoded Data**: 8+ mock shopping places (malls, markets, boutiques) with full details.

**Issue**: Should fetch from listings API.

**Recommendation**: Use `/api/listings?type=shopping` or category filter.

---

### 9. Accommodation Mock Data
**Location**: `mobile/lib/features/explore/screens/accommodation_screen.dart` (lines 1999-2060+)

**Hardcoded Data**: Multiple mock hotels with:
- Names, locations, ratings
- Room types and prices
- Amenities
- Images

**Issue**: Should fetch from listings API.

**Recommendation**: Use `/api/listings?type=hotel` endpoint.

---

### 10. Place Detail Mock Data
**Location**: `mobile/lib/features/explore/screens/place_detail_screen.dart` (lines 841+)

**Hardcoded Data**: Mock place data and reviews.

**Issue**: Should fetch from listings API and reviews API.

**Recommendation**: 
- Use `/api/listings/:id` for place details
- Use `/api/reviews?listingId=:id` for reviews

---

### 11. Reviews Mock Data
**Location**: 
- `mobile/lib/features/profile/screens/reviews_ratings_screen.dart` (line 510+)
- `mobile/lib/features/explore/screens/place_detail_screen.dart` (line 841+)

**Hardcoded Data**: Mock review data.

**Issue**: Reviews API exists but not being used.

**Recommendation**: Use `/api/reviews` endpoint.

---

### 12. Events Attended Mock Data
**Location**: `mobile/lib/features/profile/screens/events_attended_screen.dart` (lines 379+)

**Hardcoded Data**: Mock events data.

**Issue**: Should fetch user's attended events from API.

**Recommendation**: Create endpoint `/api/events/attended` or use existing events API with user filter.

---

### 13. Favorites Mock Data
**Location**: `mobile/lib/features/profile/screens/favorites_screen.dart` (lines 1206+)

**Hardcoded Data**: Mock events and places.

**Issue**: Favorites API exists (`/api/favorites`) but not being used.

**Recommendation**: Use existing `/api/favorites` endpoint.

---

## 🟢 Low Priority (Configuration/Static Content)

### 14. Support Contact Information
**Location**: 
- `mobile/lib/features/profile/screens/help_center_screen.dart` (lines 349-357)
- `mobile/lib/core/config/app_config.dart` (line 133)
- `mobile/lib/features/profile/screens/about_screen.dart` (lines 593-594)

**Hardcoded Data**:
- Email: `support@zoea.rw`, `support@zoea.africa`, `contact@zoea.rw`
- Phone: `+250 788 123 456`
- Privacy: `privacy@zoea.rw`
- Legal: `legal@zoea.rw`

**Issue**: Inconsistent email addresses across files. Should be centralized.

**Recommendation**: 
- Centralize in `app_config.dart`
- Consider making configurable via API for multi-tenant support

---

### 15. External URLs (Quick Actions)
**Location**: `mobile/lib/features/explore/screens/explore_screen.dart` (lines 591, 618, 630, 642)

**Hardcoded URLs**:
- eSim: `https://amadeus-api.optionizr.com/api/esim/deeplink?site=P02XP02X`
- RwandAir: `https://www.rwandair.com/`
- Irembo: `https://irembo.gov.rw/`
- Visit Rwanda: `https://visitrwanda.com/`

**Issue**: URLs are hardcoded. May need to change or be country-specific.

**Recommendation**: 
- Create `/api/quick-actions` endpoint
- Return URLs based on country/location
- Allow admin to configure these links

---

### 16. Mock Calculations
**Location**: 
- `mobile/lib/features/explore/screens/accommodation_booking_screen.dart` (lines 846, 883)
- `mobile/lib/features/explore/screens/dining_booking_screen.dart` (lines 853, 874, 911)

**Hardcoded Logic**:
- Mock coupon validation
- Mock price calculations
- Mock time slot availability

**Issue**: Business logic should be on backend.

**Recommendation**: 
- Use booking API endpoints
- Implement proper coupon validation API
- Calculate prices on backend

---

## 📊 Summary Statistics

- **Total Hardcoded Items Found**: 16 categories
- **Critical Issues**: 4
- **Medium Priority**: 9
- **Low Priority**: 3

## 🎯 Recommended Action Plan

### Phase 1: Critical (Immediate)
1. ✅ Create `/api/emergency-numbers` endpoint
2. ✅ Create `/api/quick-actions` endpoint (includes taxi number, external URLs)
3. ✅ Replace MICE events mock with API call
4. ✅ Replace specials mock with promotions API

### Phase 2: Medium Priority (Next Sprint)
5. ✅ Replace all mock listings data (nightlife, shopping, accommodation)
6. ✅ Replace mock reviews with reviews API
7. ✅ Replace mock favorites with favorites API
8. ✅ Fix categories API to always return children (remove fallback)

### Phase 3: Low Priority (Future)
9. ✅ Centralize contact information
10. ✅ Move booking calculations to backend
11. ✅ Make external URLs configurable via API

## 🔍 API Endpoints Already Available

The following APIs already exist and should be used instead of mock data:
- ✅ `/api/listings` - For all listing types
- ✅ `/api/events` - For events (including MICE)
- ✅ `/api/reviews` - For reviews
- ✅ `/api/favorites` - For user favorites
- ✅ `/api/categories` - For categories (needs to return children)
- ✅ `/api/promotions` - For specials/deals (check if exists)

## 📝 Notes

- Some mock data may be intentional for development/testing
- Ensure proper error handling when switching to API calls
- Consider caching strategy for frequently accessed data
- Some content (like external URLs) may be acceptable to hardcode if they're truly static

