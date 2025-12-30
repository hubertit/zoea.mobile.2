# User Data Integration - Complete Analysis

**Date**: December 30, 2024  
**Purpose**: Ensure 100% integration of all user data collection features with APIs and database

---

## Current State Analysis

### 1. Registration Flow

#### Mobile App (register_screen.dart)
**Current Fields Collected:**
- ✅ Full Name
- ✅ Email
- ✅ Password
- ✅ Confirm Password
- ❌ **User Role Selection** (needs to be removed - default to "explorer"/"customer")
- ✅ Terms & Conditions agreement

**Issues:**
- User role selection UI exists (lines 263-351) but is NOT sent to API
- Role selection is unnecessary since this is consumer app (merchants have separate app)

#### Backend API (auth.service.ts)
**RegisterDto accepts:**
- ✅ email (optional)
- ✅ phoneNumber (optional)
- ✅ password
- ✅ fullName (optional)

**What happens:**
- User is created with default role: `[explorer]` (from DB schema default)
- No user preferences are created during registration
- User must complete onboarding data collection after registration

**Missing:**
- No explicit role setting (relies on DB default)
- No initial preferences creation

---

### 2. User Data Collection Fields

#### Mobile App (UserPreferences model)
**Fields defined:**
- ✅ countryOfOrigin (String)
- ✅ userType (UserType enum: resident, visitor)
- ✅ visitPurpose (VisitPurpose enum: leisure, business, mice)
- ✅ ageRange (AgeRange enum: 18-25, 26-35, 36-45, 46-55, 56+)
- ✅ gender (Gender enum: male, female, other, prefer_not_to_say)
- ✅ lengthOfStay (LengthOfStay enum: 1-3 days, 4-7 days, 1-2 weeks, 2+ weeks)
- ✅ travelParty (TravelParty enum: solo, couple, family, group)
- ✅ dataCollectionFlags (Map<String, bool>)
- ✅ dataCollectionCompletedAt (DateTime)
- ✅ language (String)
- ✅ currency (String)
- ✅ interests (List<String>)

#### Database Schema (User table)
**Existing fields:**
- ✅ preferredLanguage (String)
- ✅ preferredCurrency (String)
- ✅ interests (String[])
- ✅ gender (String)
- ✅ roles (user_role[] - default [explorer])
- ✅ accountType (account_type - default personal)

**MISSING fields:**
- ❌ countryOfOrigin (String)
- ❌ userType (String/enum)
- ❌ visitPurpose (String/enum)
- ❌ ageRange (String)
- ❌ lengthOfStay (String)
- ❌ travelParty (String)
- ❌ dataCollectionFlags (JSON)
- ❌ dataCollectionCompletedAt (DateTime)

#### Backend API (UpdatePreferencesDto)
**Current fields:**
- ✅ preferredCurrency
- ✅ preferredLanguage
- ✅ timezone
- ✅ maxDistance
- ✅ notificationPreferences
- ✅ marketingConsent
- ✅ interests
- ✅ isPrivate

**MISSING fields:**
- ❌ countryOfOrigin
- ❌ userType
- ❌ visitPurpose
- ❌ ageRange
- ❌ gender
- ❌ lengthOfStay
- ❌ travelParty
- ❌ dataCollectionFlags
- ❌ dataCollectionCompletedAt

---

### 3. API Endpoints Analysis

#### Registration Endpoint
**POST /auth/register**
- ✅ Exists
- ✅ Accepts: email, phoneNumber, password, fullName
- ❌ Does NOT set role explicitly (uses DB default)
- ❌ Does NOT create initial preferences

#### Preferences Update Endpoint
**PUT /users/me/preferences**
- ✅ Exists
- ✅ Accepts: preferredCurrency, preferredLanguage, interests, etc.
- ❌ Does NOT accept new UX-first data collection fields

#### User Update Endpoint
**PUT /users/me**
- ✅ Exists
- ✅ Can update user fields
- ❌ Does NOT accept preferences fields (they're separate)

---

## Required Changes

### Phase 1: Database Schema Updates

**Add to User table:**
```sql
ALTER TABLE users ADD COLUMN country_of_origin VARCHAR(3);
ALTER TABLE users ADD COLUMN user_type VARCHAR(20);
ALTER TABLE users ADD COLUMN visit_purpose VARCHAR(20);
ALTER TABLE users ADD COLUMN age_range VARCHAR(10);
ALTER TABLE users ADD COLUMN length_of_stay VARCHAR(20);
ALTER TABLE users ADD COLUMN travel_party VARCHAR(20);
ALTER TABLE users ADD COLUMN data_collection_flags JSONB DEFAULT '{}';
ALTER TABLE users ADD COLUMN data_collection_completed_at TIMESTAMPTZ;
```

**Or create Prisma migration:**
```prisma
countryOfOrigin        String?                     @map("country_of_origin") @db.VarChar(3)
userType               String?                     @map("user_type") @db.VarChar(20)
visitPurpose           String?                     @map("visit_purpose") @db.VarChar(20)
ageRange               String?                     @map("age_range") @db.VarChar(10)
lengthOfStay           String?                     @map("length_of_stay") @db.VarChar(20)
travelParty            String?                     @map("travel_party") @db.VarChar(20)
dataCollectionFlags     Json?                       @default("{}") @map("data_collection_flags")
dataCollectionCompletedAt DateTime?                 @map("data_collection_completed_at") @db.Timestamptz(6)
```

### Phase 2: Backend API Updates

**Update RegisterDto:**
- No changes needed (role defaults to explorer)

**Update UpdatePreferencesDto:**
- Add all new UX-first data collection fields

**Update UsersService.updatePreferences:**
- Handle new fields in update logic

**Update AuthService.register:**
- Ensure role defaults to "explorer" (already does via DB default)

### Phase 3: Mobile App Updates

**Update register_screen.dart:**
- Remove UserRole selection UI (lines 263-351)
- Remove _selectedUserRole state variable
- Keep only: fullName, email, password, confirmPassword, terms

**Verify UserDataCollectionService:**
- Ensure all fields are sent correctly to API
- Verify API endpoints match

---

## Implementation Plan

1. ✅ **Analysis Complete** - This document
2. ⏳ **Database Migration** - Add missing columns to User table
3. ⏳ **Backend DTOs** - Update UpdatePreferencesDto
4. ⏳ **Backend Service** - Update updatePreferences method
5. ⏳ **Mobile Registration** - Remove role selection
6. ⏳ **Mobile Service** - Verify all fields sent correctly
7. ⏳ **Testing** - End-to-end testing

---

## Field Mapping

| Mobile Field | Database Column | API Field | Status |
|-------------|----------------|-----------|--------|
| countryOfOrigin | country_of_origin | countryOfOrigin | ❌ Missing |
| userType | user_type | userType | ❌ Missing |
| visitPurpose | visit_purpose | visitPurpose | ❌ Missing |
| ageRange | age_range | ageRange | ❌ Missing |
| gender | gender | gender | ✅ Exists |
| lengthOfStay | length_of_stay | lengthOfStay | ❌ Missing |
| travelParty | travel_party | travelParty | ❌ Missing |
| dataCollectionFlags | data_collection_flags | dataCollectionFlags | ❌ Missing |
| dataCollectionCompletedAt | data_collection_completed_at | dataCollectionCompletedAt | ❌ Missing |
| language | preferred_language | preferredLanguage | ✅ Exists |
| currency | preferred_currency | preferredCurrency | ✅ Exists |
| interests | interests | interests | ✅ Exists |

---

**Next Step**: Start with database migration, then backend, then mobile app updates.

