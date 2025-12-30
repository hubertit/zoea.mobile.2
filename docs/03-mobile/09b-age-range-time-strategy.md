# Age Range Over Time - Strategy & Implementation

**Date**: December 30, 2024  
**Purpose**: Handle age range changes over time as users age

---

## Problem Statement

**Current Situation:**
- User selects age range "18-25" today
- 5 years later, they're 26-30, but their stored `ageRange` is still "18-25"
- This creates inaccurate analytics and personalization

**Questions:**
1. Should age range be static (snapshot) or dynamic (calculated)?
2. How to handle historical analytics?
3. How to maintain data accuracy?
4. Privacy considerations?

---

## Solution: Hybrid Approach

### Strategy Overview

**Store Both:**
1. **`dateOfBirth`** (if provided) - Source of truth for age calculation
2. **`ageRange`** - Current age range snapshot (for quick access & historical tracking)
3. **`ageRangeUpdatedAt`** - Timestamp when age range was last calculated

**Benefits:**
- ✅ Historical analytics preserved (can see what range user was in at time X)
- ✅ Current accuracy (can recalculate from dateOfBirth)
- ✅ Performance (no need to calculate age on every query)
- ✅ Privacy-friendly (can store range without exact birth date)

---

## Implementation Options

### Option 1: Auto-Update on Profile Access (Recommended)

**How it works:**
- When user profile is accessed, check if `ageRange` needs updating
- If `dateOfBirth` exists and `ageRange` is outdated, recalculate
- Update `ageRange` and `ageRangeUpdatedAt`

**Pros:**
- Always accurate when accessed
- No background jobs needed
- Automatic

**Cons:**
- Slight performance overhead on profile access
- Requires dateOfBirth to be set

**Implementation:**
```typescript
// In UsersService.findOne() or getPreferences()
if (user.dateOfBirth && shouldUpdateAgeRange(user.ageRangeUpdatedAt)) {
  const newAgeRange = calculateAgeRange(user.dateOfBirth);
  await this.prisma.user.update({
    where: { id: userId },
    data: {
      ageRange: newAgeRange,
      ageRangeUpdatedAt: new Date(),
    },
  });
}
```

---

### Option 2: Background Job (Periodic Update)

**How it works:**
- Scheduled job runs monthly/quarterly
- Finds users with `dateOfBirth` and outdated `ageRange`
- Updates in batch

**Pros:**
- No performance impact on user requests
- Can update all users at once

**Cons:**
- Requires background job infrastructure
- May be outdated between updates
- More complex

---

### Option 3: On-Demand Update Endpoint

**How it works:**
- User can request age range update
- Or app checks on login/important actions
- Explicit update when needed

**Pros:**
- User control
- No automatic overhead
- Simple

**Cons:**
- May forget to update
- Manual process

---

### Option 4: Calculate Dynamically (No Storage)

**How it works:**
- Never store `ageRange`
- Always calculate from `dateOfBirth` when needed
- Return calculated value in API responses

**Pros:**
- Always accurate
- No sync issues
- Single source of truth

**Cons:**
- Loses historical data (can't see what range user was in 2 years ago)
- Requires dateOfBirth to be set
- Calculation overhead on every query

---

## Recommended Approach: Option 1 (Auto-Update) + Option 4 (Fallback)

### Primary: Auto-Update on Access
- If `dateOfBirth` exists → calculate and update `ageRange`
- If `dateOfBirth` doesn't exist → use stored `ageRange` (user-selected)

### Fallback: Dynamic Calculation
- API always returns calculated age range (if dateOfBirth exists)
- Stored `ageRange` is for historical tracking only

---

## Database Schema Changes

### Add `ageRangeUpdatedAt` Field

```prisma
model User {
  // ... existing fields
  ageRange               String?                     @map("age_range") @db.VarChar(10)
  ageRangeUpdatedAt      DateTime?                   @map("age_range_updated_at") @db.Timestamptz(6)
  dateOfBirth            DateTime?                   @map("date_of_birth") @db.Date
}
```

**Migration:**
```sql
ALTER TABLE users 
  ADD COLUMN IF NOT EXISTS age_range_updated_at TIMESTAMPTZ;
```

---

## Implementation Plan

### Step 1: Add Helper Functions

**Backend Service:**
```typescript
// Calculate age range from date of birth
calculateAgeRange(dateOfBirth: Date): string {
  const today = new Date();
  const age = today.getFullYear() - dateOfBirth.getFullYear();
  const monthDiff = today.getMonth() - dateOfBirth.getMonth();
  const dayDiff = today.getDate() - dateOfBirth.getDate();
  
  // Adjust if birthday hasn't occurred this year
  const actualAge = (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) 
    ? age - 1 
    : age;

  if (actualAge < 18) return 'under-18';
  if (actualAge >= 18 && actualAge <= 25) return '18-25';
  if (actualAge >= 26 && actualAge <= 35) return '26-35';
  if (actualAge >= 36 && actualAge <= 45) return '36-45';
  if (actualAge >= 46 && actualAge <= 55) return '46-55';
  return '56+';
}

// Check if age range needs updating (older than 1 year)
shouldUpdateAgeRange(ageRangeUpdatedAt: Date | null): boolean {
  if (!ageRangeUpdatedAt) return true;
  const oneYearAgo = new Date();
  oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);
  return ageRangeUpdatedAt < oneYearAgo;
}
```

### Step 2: Update Service Methods

**In `getPreferences()` and `findOne()`:**
- Check if `dateOfBirth` exists
- If yes, calculate current age range
- Compare with stored `ageRange`
- If different or outdated, update

### Step 3: Add API Response Enhancement

**Always return calculated age range:**
```typescript
// In response, include both stored and calculated
{
  ageRange: user.ageRange, // Stored (historical)
  calculatedAgeRange: user.dateOfBirth 
    ? calculateAgeRange(user.dateOfBirth) 
    : user.ageRange, // Current (accurate)
  ageRangeSource: user.dateOfBirth ? 'calculated' : 'user-selected'
}
```

---

## Privacy Considerations

### Option A: Store Only Age Range (No Date of Birth)
- ✅ More privacy-friendly
- ✅ No exact age stored
- ❌ Can't auto-update over time
- ❌ User must manually update

### Option B: Store Date of Birth (Recommended)
- ✅ Can auto-update age range
- ✅ More accurate
- ✅ Better analytics
- ⚠️ More sensitive data (requires GDPR compliance)

### Recommendation: Option B with Privacy Controls
- Make `dateOfBirth` optional
- Allow users to provide only age range if preferred
- Auto-update only if `dateOfBirth` is provided
- Clear privacy policy about data usage

---

## Analytics Strategy

### Historical Tracking

**Store age range snapshots:**
```typescript
// When age range changes, log it
await this.prisma.userAgeRangeHistory.create({
  data: {
    userId: user.id,
    ageRange: oldAgeRange,
    changedAt: new Date(),
    reason: 'auto-updated' | 'user-updated'
  }
});
```

**Benefits:**
- Track demographic changes over time
- Analyze user behavior by age range at time of action
- Understand user lifecycle

---

## Mobile App Considerations

### When to Update

1. **On App Launch** (if dateOfBirth exists)
   - Check if age range needs update
   - Update locally and sync with server

2. **On Profile View**
   - Show current calculated age range
   - Option to update if outdated

3. **On Date of Birth Update**
   - Immediately recalculate age range
   - Update preferences

### User Experience

**If dateOfBirth is set:**
- Show: "Age Range: 18-25 (calculated from your birth date)"
- Auto-update silently

**If only ageRange is set:**
- Show: "Age Range: 18-25 (you selected)"
- Option: "Update based on birth date" → prompts for dateOfBirth

---

## Migration Strategy

### For Existing Users

1. **Users with dateOfBirth:**
   - Calculate current age range
   - Update `ageRange` field
   - Set `ageRangeUpdatedAt` to now

2. **Users without dateOfBirth:**
   - Keep existing `ageRange` as-is
   - Optionally prompt to add dateOfBirth for auto-updates

---

## API Changes

### New Endpoint (Optional)

```typescript
@Post('me/preferences/update-age-range')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@ApiOperation({ summary: 'Update age range from date of birth' })
async updateAgeRange(@Request() req) {
  return this.usersService.updateAgeRangeFromDateOfBirth(req.user.id);
}
```

### Enhanced Response

```typescript
// GET /users/me/preferences response
{
  // ... other fields
  ageRange: "18-25", // Stored value
  calculatedAgeRange: "26-35", // Current calculated (if dateOfBirth exists)
  ageRangeSource: "calculated" | "user-selected",
  ageRangeUpdatedAt: "2024-12-30T10:00:00Z"
}
```

---

## Summary

**Recommended Strategy:**
1. ✅ Store both `dateOfBirth` and `ageRange`
2. ✅ Add `ageRangeUpdatedAt` timestamp
3. ✅ Auto-update `ageRange` when `dateOfBirth` exists and range is outdated
4. ✅ Always return calculated age range in API (if dateOfBirth exists)
5. ✅ Keep stored `ageRange` for historical analytics
6. ✅ Make dateOfBirth optional (privacy-friendly)

**Benefits:**
- ✅ Accurate current data
- ✅ Historical tracking preserved
- ✅ Privacy-friendly (optional dateOfBirth)
- ✅ Automatic updates
- ✅ No user intervention needed

---

**Next Steps**: Implement auto-update logic in UsersService

