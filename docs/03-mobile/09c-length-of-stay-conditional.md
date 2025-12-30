# Length of Stay - Conditional for Visitors Only

**Date**: December 30, 2024  
**Purpose**: Make length of stay conditional - only collect for visitors, not residents

---

## Problem Statement

**Issue:**
- Length of stay field doesn't make sense for residents
- Residents live permanently, so "how long are you staying?" is irrelevant
- This creates confusion and poor UX for residents

**Solution:**
- Make length of stay conditional based on `userType`
- Only show/collect for `UserType.visitor`
- Hide/clear for `UserType.resident`

---

## Implementation Changes

### 1. Profile Completion Calculation

**File**: `mobile/lib/core/models/user.dart`

**Change**: Updated `profileCompletionPercentage` to exclude `lengthOfStay` for residents

```dart
/// Get profile completion percentage (0-100)
/// Note: lengthOfStay is only counted for visitors, not residents
int get profileCompletionPercentage {
  // Base fields (always counted)
  int totalFields = 9; // Mandatory + optional fields (excluding lengthOfStay)
  
  // Add lengthOfStay to total only if user is a visitor
  if (userType == UserType.visitor) {
    totalFields = 10; // Include lengthOfStay for visitors
  }

  int completedFields = 0;
  // ... count fields ...
  
  // Only count lengthOfStay for visitors
  if (userType == UserType.visitor && lengthOfStay != null) completedFields++;
  // ... other fields ...
}
```

**Impact:**
- Residents: 9 total fields (lengthOfStay excluded)
- Visitors: 10 total fields (lengthOfStay included)
- Completion percentage calculated correctly for both user types

---

### 2. Complete Profile Screen

**File**: `mobile/lib/features/user_data_collection/screens/complete_profile_screen.dart`

**Change**: Conditionally show length of stay section only for visitors

```dart
// Length of Stay (only for visitors)
if (user?.preferences?.userType == UserType.visitor) ...[
  _buildSection(
    title: 'Length of Stay',
    subtitle: 'How long are you staying in Rwanda?',
    isComplete: _selectedLengthOfStay != null,
    child: LengthOfStaySelector(...),
  ),
  const SizedBox(height: AppTheme.spacing24),
],
```

**Save Logic:**
```dart
// Only save lengthOfStay for visitors
final currentUser = ref.read(currentUserProvider);
final userType = currentUser?.preferences?.userType;
if (userType == UserType.visitor && _selectedLengthOfStay != null) {
  await service.saveProgressiveData(
    lengthOfStay: _selectedLengthOfStay,
    flagKey: 'lengthOfStayAsked',
  );
} else if (userType == UserType.resident && _selectedLengthOfStay != null) {
  // Clear lengthOfStay if user is a resident (shouldn't have this)
  await service.saveProgressiveData(
    lengthOfStay: null,
    flagKey: 'lengthOfStayAsked',
  );
}
```

**Impact:**
- Residents don't see length of stay field
- Visitors see and can fill length of stay
- If resident somehow has lengthOfStay, it's cleared on save

---

### 3. Progressive Prompt Helper

**File**: `mobile/lib/features/user_data_collection/utils/prompt_helper.dart`

**Change**: Skip length of stay prompt for residents

```dart
/// Check and show prompt after using navigation (length of stay prompt)
/// Only shows for visitors, not residents
static Future<void> checkAndShowPromptAfterNavigation(
  BuildContext context,
  WidgetRef ref,
) async {
  try {
    // Check if user is a visitor (length of stay only applies to visitors)
    final user = ref.read(currentUserProvider);
    final userType = user?.preferences?.userType;
    
    // Skip if user is a resident (length of stay doesn't apply)
    if (userType != UserType.visitor) {
      return;
    }

    // ... show prompt logic ...
  }
}
```

**Impact:**
- Residents never see length of stay progressive prompts
- Only visitors see navigation-based length of stay prompts

---

### 4. Prompt Timing Service

**File**: `mobile/lib/core/services/prompt_timing_service.dart`

**Changes:**

**A. `getNextPromptType()` - Skip lengthOfStay for residents**
```dart
/// Get the next prompt type to show based on missing data
/// Note: lengthOfStay is only shown for visitors, not residents
Future<String?> getNextPromptType() async {
  // ...
  final isVisitor = prefs.userType == UserType.visitor;
  
  // Only show lengthOfStay for visitors
  if (isVisitor && prefs.lengthOfStay == null && flags['lengthOfStayAsked'] != true) {
    return 'lengthOfStay';
  }
  // ...
}
```

**B. `shouldShowPromptAfterAction()` - Check user type for navigation prompts**
```dart
case 'use_navigation':
  // Show length of stay prompt if not collected (only for visitors)
  if (suggestedPromptType == 'lengthOfStay' || suggestedPromptType == null) {
    // Check if user is a visitor
    final user = await _tokenStorage.getUserData();
    final isVisitor = user?.preferences?.userType == UserType.visitor;
    
    // Only show for visitors
    if (isVisitor && !await hasDataBeenCollected('lengthOfStayAsked')) {
      return true;
    }
  }
  break;
```

**Impact:**
- Session-based prompts skip lengthOfStay for residents
- Navigation-based prompts only trigger for visitors

---

### 5. User Data Collection Service

**File**: `mobile/lib/core/services/user_data_collection_service.dart`

**Change**: Validate and clear lengthOfStay for residents

```dart
/// Save optional progressive data (age range, gender, etc.)
/// Note: lengthOfStay is only saved for visitors, not residents
Future<UserPreferences> saveProgressiveData({
  // ...
  LengthOfStay? lengthOfStay,
  // ...
}) async {
  // Check if user is a visitor before saving lengthOfStay
  final currentUser = await _tokenStorage.getUserData();
  final userType = currentUser?.preferences?.userType;

  // Only save lengthOfStay for visitors
  if (lengthOfStay != null) {
    if (userType == UserType.visitor) {
      preferences['lengthOfStay'] = lengthOfStay.apiValue;
      flags['lengthOfStayAsked'] = true;
    } else {
      // Clear lengthOfStay if user is a resident
      preferences['lengthOfStay'] = null;
    }
  } else if (userType == UserType.resident) {
    // Explicitly clear lengthOfStay for residents
    preferences['lengthOfStay'] = null;
  }
}
```

**Impact:**
- Service-level validation ensures residents can't save lengthOfStay
- Automatically clears lengthOfStay if resident tries to save it

---

### 6. Backend API Documentation

**File**: `backend/src/modules/users/dto/user.dto.ts`

**Change**: Added documentation clarifying lengthOfStay is only for visitors

```typescript
@ApiPropertyOptional({ 
  example: '1-3 days', 
  enum: ['1-3 days', '4-7 days', '1-2 weeks', '2+ weeks'],
  description: 'Length of stay in Rwanda. Only applicable for visitors, not residents.' 
})
@IsString()
@IsIn(['1-3 days', '4-7 days', '1-2 weeks', '2+ weeks'], { 
  message: 'lengthOfStay must be one of: 1-3 days, 4-7 days, 1-2 weeks, 2+ weeks' 
})
@IsOptional()
lengthOfStay?: string;
```

**Impact:**
- API documentation clearly states lengthOfStay is visitor-only
- Helps API consumers understand the field's purpose

---

## User Experience Flow

### For Visitors:
1. ✅ See "Length of Stay" in Complete Profile screen
2. ✅ Can select length of stay (1-3 days, 4-7 days, etc.)
3. ✅ May receive progressive prompt after using navigation
4. ✅ Length of stay counted in profile completion

### For Residents:
1. ✅ Don't see "Length of Stay" in Complete Profile screen
2. ✅ Never receive length of stay progressive prompts
3. ✅ Length of stay not counted in profile completion
4. ✅ If somehow set, automatically cleared on save

---

## Data Integrity

### Automatic Cleanup:
- If resident has `lengthOfStay` set, it's cleared when:
  - User saves preferences via `saveProgressiveData()`
  - User updates profile via Complete Profile screen

### Validation:
- Frontend: UI doesn't show field for residents
- Service: Validates user type before saving
- Backend: Field is optional, no validation needed (frontend handles it)

---

## Testing Checklist

- [ ] Visitor can see and select length of stay
- [ ] Resident cannot see length of stay field
- [ ] Profile completion % correct for visitors (10 fields)
- [ ] Profile completion % correct for residents (9 fields)
- [ ] Progressive prompts skip lengthOfStay for residents
- [ ] Navigation prompts only show for visitors
- [ ] If resident has lengthOfStay, it's cleared on save
- [ ] API accepts null for lengthOfStay (for residents)

---

## Summary

**Changes Made:**
1. ✅ Profile completion excludes lengthOfStay for residents
2. ✅ Complete Profile screen conditionally shows field
3. ✅ Progressive prompts skip lengthOfStay for residents
4. ✅ Service validates and clears lengthOfStay for residents
5. ✅ Backend documentation updated

**Result:**
- ✅ Better UX for residents (no irrelevant questions)
- ✅ Accurate profile completion percentages
- ✅ Data integrity maintained
- ✅ No confusion about field purpose

---

**Status**: ✅ Complete

