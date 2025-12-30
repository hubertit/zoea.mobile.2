# Quick Testing Guide - Phase 1

## ✅ Automated Tests (PASSED)

Run the unit tests:
```bash
cd mobile
flutter test test/core/models/user_test.dart
```

**Result:** ✅ All 12 tests passed!

---

## 🚀 Quick Manual Test Steps

### Step 1: Test Models in Flutter DevTools

1. **Run the app in debug mode**
2. **Open Flutter DevTools** (or use debug console)
3. **Paste this code:**

```dart
import 'package:zoea2/core/models/user.dart';

// Test 1: Create UserPreferences
final prefs = UserPreferences(
  countryOfOrigin: 'RW',
  userType: UserType.resident,
  visitPurpose: VisitPurpose.leisure,
  ageRange: AgeRange.range26_35,
  gender: Gender.male,
);

print('✅ UserPreferences created');
print('Country: ${prefs.countryOfOrigin}');
print('User Type: ${prefs.userType?.displayName}');
print('Is Complete: ${prefs.isMandatoryDataComplete}');
print('Completion: ${prefs.profileCompletionPercentage}%');
```

**Expected:** Should print all values correctly.

---

### Step 2: Test Enums

```dart
// Test enum extensions
print('UserType: ${UserType.visitor.displayName}'); // "Visitor"
print('VisitPurpose: ${VisitPurpose.mice.displayName}'); // "MICE"
print('AgeRange: ${AgeRange.range56Plus.displayName}'); // "56+"
print('Gender: ${Gender.preferNotToSay.displayName}'); // "Prefer not to say"
print('LengthOfStay: ${LengthOfStay.oneToTwoWeeks.displayName}'); // "1-2 weeks"
print('TravelParty: ${TravelParty.family.displayName}'); // "Family"
```

**Expected:** All display names print correctly.

---

### Step 3: Test DataInferenceService

```dart
import 'package:zoea2/core/services/data_inference_service.dart';

final service = DataInferenceService();

// Test inference
final country = await service.inferCountryFromLocale();
final language = await service.inferLanguageFromLocale();
final userType = await service.inferUserType(countryCode: country);

print('Inferred Country: $country');
print('Inferred Language: $language');
print('Inferred User Type: ${userType?.displayName}');
```

**Expected:** Should infer values from your device locale.

---

### Step 4: Test PromptTimingService

```dart
import 'package:zoea2/core/services/prompt_timing_service.dart';

final service = PromptTimingService();

// Increment session
await service.incrementSessionCount();
final count = await service.getSessionCount();
print('Session Count: $count');

// Check if should show prompt
final shouldShow = await service.shouldShowPromptBasedOnSessions();
print('Should show prompt: $shouldShow');
```

**Expected:** Session count increments, prompt logic works.

---

### Step 5: Test AnalyticsService

```dart
import 'package:zoea2/core/services/analytics_service.dart';

final service = AnalyticsService();

// Set consent
await service.setConsent(true);
print('Has Consent: ${await service.hasConsent()}'); // true

// Track events
await service.trackSearch(query: 'test');
await service.trackListingView(listingId: '123');

// Check queue
print('Queue Size: ${await service.getQueueSize()}'); // > 0
```

**Expected:** Consent works, events tracked, queue accumulates.

---

## 📋 Testing Checklist

- [x] **Automated Tests:** All 12 tests pass
- [ ] **UserPreferences Model:** Creates, serializes, deserializes correctly
- [ ] **Enum Extensions:** All display names and API values work
- [ ] **DataInferenceService:** Infers country, language, user type
- [ ] **PromptTimingService:** Tracks sessions, manages prompts
- [ ] **AnalyticsService:** Manages consent, tracks events
- [ ] **UserDataCollectionService:** Saves data (requires login)

---

## 🎯 What to Look For

✅ **Models:** JSON serialization/deserialization works  
✅ **Enums:** Display names and API values are correct  
✅ **Services:** All methods work without errors  
✅ **Providers:** Return correct data types  

---

## 🐛 If Something Fails

1. **Check imports:** Make sure you're importing from `package:zoea2/...`
2. **Check async:** Services use `await` - make sure you're in an async context
3. **Check login:** UserDataCollectionService requires authentication

---

**Ready for Phase 2?** Once Phase 1 is verified, we can test the UI components! 🚀

