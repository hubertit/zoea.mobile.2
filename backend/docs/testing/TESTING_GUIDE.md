# Endpoint Testing Guide

## Option 1: Test via Swagger UI (Recommended)

1. Open Swagger UI: https://zoea-africa.qtsoftwareltd.com/api/docs
2. Click "Authorize" button (top right)
3. Enter your JWT token: `Bearer <your-token>`
4. Test each endpoint one by one

## Option 2: Test via Script

1. Get a JWT token by logging in:
   ```bash
   curl -X POST https://zoea-africa.qtsoftwareltd.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"your-email@example.com","password":"your-password"}'
   ```

2. Copy the token from the response

3. Run the test script:
   ```bash
   ./test-endpoints.sh <YOUR_JWT_TOKEN>
   ```

## Option 3: Test via curl (Manual)

### Test 1: GET /api/users/me/preferences

```bash
curl -X GET https://zoea-africa.qtsoftwareltd.com/api/users/me/preferences \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "preferredCurrency": "RWF",
  "preferredLanguage": "en",
  "countryOfOrigin": "RW",
  "userType": "visitor",
  "visitPurpose": "leisure",
  "ageRange": "26-35",
  "calculatedAgeRange": "26-35",
  "ageRangeSource": "user-selected",
  "gender": "male",
  "lengthOfStay": "1-2 weeks",
  "travelParty": "couple",
  ...
}
```

**What to check:**
- ✅ Status code is 200
- ✅ All new fields are present (countryOfOrigin, userType, visitPurpose, etc.)
- ✅ calculatedAgeRange and ageRangeSource are included
- ✅ Response matches Swagger documentation

---

### Test 2: PUT /api/users/me/preferences

```bash
curl -X PUT https://zoea-africa.qtsoftwareltd.com/api/users/me/preferences \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "countryOfOrigin": "KE",
    "userType": "visitor",
    "visitPurpose": "business",
    "ageRange": "26-35",
    "gender": "female",
    "lengthOfStay": "4-7 days",
    "travelParty": "solo"
  }'
```

**What to check:**
- ✅ Status code is 200
- ✅ Response includes calculatedAgeRange and ageRangeSource
- ✅ Data is saved correctly (verify with GET request)

---

### Test 3: GET /api/users/me/preferences/completion-status

```bash
curl -X GET https://zoea-africa.qtsoftwareltd.com/api/users/me/preferences/completion-status \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "mandatory": {
    "completed": true,
    "missing": []
  },
  "optional": {
    "completed": false,
    "missing": ["ageRange", "gender"]
  }
}
```

**What to check:**
- ✅ Status code is 200
- ✅ Mandatory fields completion status is correct
- ✅ Optional fields completion status is correct
- ✅ Missing fields list is accurate

---

### Test 4: GET /api/users/me/profile/completion

```bash
curl -X GET https://zoea-africa.qtsoftwareltd.com/api/users/me/profile/completion \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "percentage": 75,
  "missingFields": ["ageRange", "gender", "interests"]
}
```

**What to check:**
- ✅ Status code is 200
- ✅ Percentage is calculated correctly
- ✅ Missing fields list is accurate

---

## Testing Order

1. ✅ **GET /api/users/me/preferences** - Verify current state
2. ⏳ **PUT /api/users/me/preferences** - Update with test data
3. ⏳ **GET /api/users/me/preferences** - Verify update worked
4. ⏳ **GET /api/users/me/preferences/completion-status** - Check completion
5. ⏳ **GET /api/users/me/profile/completion** - Check percentage
6. ⏳ **POST /api/analytics/events** - Test analytics
7. ⏳ **POST /api/analytics/content-view** - Test individual view

---

## Next Steps

After testing each endpoint:
1. Verify the response matches expected format
2. Check Swagger documentation matches actual response
3. Test edge cases (invalid data, missing fields, etc.)
4. Move to next endpoint

