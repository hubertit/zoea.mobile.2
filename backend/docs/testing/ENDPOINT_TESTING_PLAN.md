# Endpoint Testing Plan

## User Data Collection Endpoints

### 1. GET /api/users/me/preferences
- **Purpose**: Get user preferences including all UX-first data collection fields
- **Auth**: Required (Bearer token)
- **Expected**: Returns all preference fields including countryOfOrigin, userType, visitPurpose, ageRange, etc.

### 2. PUT /api/users/me/preferences
- **Purpose**: Update user preferences (all new fields)
- **Auth**: Required (Bearer token)
- **Test Data**: 
  ```json
  {
    "countryOfOrigin": "RW",
    "userType": "visitor",
    "visitPurpose": "leisure",
    "ageRange": "26-35",
    "gender": "male",
    "lengthOfStay": "1-2 weeks",
    "travelParty": "couple"
  }
  ```

### 3. GET /api/users/me/preferences/completion-status
- **Purpose**: Get mandatory and optional data completion status
- **Auth**: Required (Bearer token)
- **Expected**: Returns completion status for mandatory and optional fields

### 4. GET /api/users/me/profile/completion
- **Purpose**: Get profile completion percentage and missing fields
- **Auth**: Required (Bearer token)
- **Expected**: Returns percentage and list of missing fields

## Analytics Endpoints

### 5. POST /api/analytics/events
- **Purpose**: Receive batched analytics events
- **Auth**: Required (Bearer token)
- **Test Data**: Batch of events (listing_view, search, etc.)

### 6. POST /api/analytics/content-view
- **Purpose**: Record individual content view
- **Auth**: Required (Bearer token)
- **Test Data**: Single content view event

## Testing Order

1. ✅ GET /api/users/me/preferences (verify current state)
2. ⏳ PUT /api/users/me/preferences (update with test data)
3. ⏳ GET /api/users/me/preferences/completion-status (verify completion)
4. ⏳ GET /api/users/me/profile/completion (verify percentage)
5. ⏳ POST /api/analytics/events (test analytics)
6. ⏳ POST /api/analytics/content-view (test individual view)

