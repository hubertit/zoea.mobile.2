# Phase 1 Testing Guide - Core Infrastructure

This guide helps you test the Phase 1 components: Models, Enums, Services, and Providers.

---

## 🧪 Automated Tests

### Run Unit Tests

```bash
cd mobile
flutter test test/core/models/user_test.dart
```

This will test:
- ✅ UserPreferences model with new fields
- ✅ JSON serialization/deserialization
- ✅ Mandatory data completion check
- ✅ Profile completion percentage
- ✅ All enum extensions (display names, API values, fromString)

---

## 🔍 Manual Testing Guide

### 1. Test Data Models & Enums

#### Test UserPreferences Model

**In Flutter DevTools or Debug Console:**

```dart
import 'package:zoea2/core/models/user.dart';

// Test creating UserPreferences with new fields
final prefs = UserPreferences(
  countryOfOrigin: 'RW',
  userType: UserType.resident,
  visitPurpose: VisitPurpose.leisure,
  ageRange: AgeRange.range26_35,
  gender: Gender.male,
  lengthOfStay: LengthOfStay.fourToSevenDays,
  travelParty: TravelParty.couple,
  interests: ['adventure', 'culture'],
);

// Test JSON serialization
final json = prefs.toJson();
print(json);

// Test JSON deserialization
final fromJson = UserPreferences.fromJson(json);
print('Country: ${fromJson.countryOfOrigin}');
print('User Type: ${fromJson.userType?.displayName}');

// Test mandatory data check
print('Is mandatory complete: ${prefs.isMandatoryDataComplete}');

// Test profile completion
print('Completion: ${prefs.profileCompletionPercentage}%');
```

**Expected Results:**
- ✅ All fields serialize/deserialize correctly
- ✅ `isMandatoryDataComplete` returns `true` when all required fields are present
- ✅ `profileCompletionPercentage` calculates correctly (0-100)

---

#### Test Enum Extensions

```dart
// Test UserType
print(UserType.resident.displayName); // Should print "Resident"
print(UserType.resident.apiValue); // Should print "resident"
print(UserTypeExtension.fromString('visitor')); // Should return UserType.visitor

// Test VisitPurpose
print(VisitPurpose.mice.displayName); // Should print "MICE"
print(VisitPurpose.mice.apiValue); // Should print "mice"

// Test AgeRange
print(AgeRange.range56Plus.displayName); // Should print "56+"
print(AgeRangeExtension.fromString('26-35')); // Should return AgeRange.range26_35

// Test Gender
print(Gender.preferNotToSay.displayName); // Should print "Prefer not to say"
print(GenderExtension.fromString('prefer_not_to_say')); // Should return Gender.preferNotToSay

// Test LengthOfStay
print(LengthOfStay.oneToTwoWeeks.displayName); // Should print "1-2 weeks"

// Test TravelParty
print(TravelParty.family.displayName); // Should print "Family"
```

**Expected Results:**
- ✅ All enums have correct `displayName` and `apiValue`
- ✅ `fromString` correctly parses string values
- ✅ `fromString` returns `null` for invalid values

---

### 2. Test DataInferenceService

**Create a test file or use Flutter DevTools:**

```dart
import 'package:zoea2/core/services/data_inference_service.dart';

final service = DataInferenceService();

// Test country inference
final country = await service.inferCountryFromLocale();
print('Inferred country: $country');

// Test language inference
final language = await service.inferLanguageFromLocale();
print('Inferred language: $language');

// Test user type inference
final userType = await service.inferUserType(countryCode: 'RW');
print('Inferred user type: ${userType?.displayName}'); // Should be "Resident"

final userType2 = await service.inferUserType(countryCode: 'US');
print('Inferred user type: ${userType2?.displayName}'); // Should be "Visitor"

// Test all data inference
final allData = await service.inferAllData();
print('All inferred data: $allData');
```

**Expected Results:**
- ✅ Country code is inferred from device locale (e.g., "RW", "US", "GB")
- ✅ Language code is inferred (e.g., "en", "rw", "fr")
- ✅ User type is correctly inferred (RW = resident, others = visitor)
- ✅ `inferAllData()` returns a map with all inferred values

---

### 3. Test PromptTimingService

**Test in Flutter DevTools or create a test widget:**

```dart
import 'package:zoea2/core/services/prompt_timing_service.dart';

final service = PromptTimingService();

// Test session counting
await service.incrementSessionCount();
final count = await service.getSessionCount();
print('Session count: $count'); // Should be 1

await service.incrementSessionCount();
final count2 = await service.getSessionCount();
print('Session count: $count2'); // Should be 2

// Test prompt timing
final shouldShow = await service.shouldShowPromptBasedOnSessions();
print('Should show prompt: $shouldShow'); // Should be true after 2-3 sessions

// Test daily prompt check
final wasShownToday = await service.wasPromptShownToday();
print('Was prompt shown today: $wasShownToday'); // Should be false initially

// Record a prompt
await service.recordPromptShown('age');
final wasShownAfter = await service.wasPromptShownToday();
print('Was prompt shown today (after): $wasShownAfter'); // Should be true

// Test "Don't ask again"
await service.setDontAskAgain('gender');
final shouldNotAsk = await service.shouldNotAskAgain('gender');
print('Should not ask again: $shouldNotAsk'); // Should be true

// Test can show prompt
final canShow = await service.canShowPrompt(
  promptType: 'age',
  checkSessionCount: true,
);
print('Can show prompt: $canShow');
```

**Expected Results:**
- ✅ Session count increments correctly
- ✅ Prompt timing logic works (shows after 2-3 sessions)
- ✅ Daily prompt check prevents multiple prompts per day
- ✅ "Don't ask again" functionality works
- ✅ `canShowPrompt` respects all conditions

---

### 4. Test AnalyticsService

**Test in Flutter DevTools:**

```dart
import 'package:zoea2/core/services/analytics_service.dart';

final service = AnalyticsService();

// Test consent
await service.setConsent(true);
final hasConsent = await service.hasConsent();
print('Has consent: $hasConsent'); // Should be true

// Test tracking (only works if consent is true)
await service.trackSearch(query: 'restaurants', category: 'dining');
await service.trackListingView(listingId: '123', category: 'hotels');
await service.trackEventView(eventId: '456', eventType: 'conference');
await service.trackNavigation(zone: 'Kigali');
await service.trackSessionStart();
await service.trackBookingAttempt(listingId: '789', listingType: 'hotel');
await service.trackBookingCompletion(bookingId: '101', listingId: '789');

// Check queue size
final queueSize = await service.getQueueSize();
print('Queue size: $queueSize'); // Should be > 0

// Test consent revocation
await service.setConsent(false);
final queueSizeAfter = await service.getQueueSize();
print('Queue size after revoking: $queueSizeAfter'); // Should be 0 (cleared)
```

**Expected Results:**
- ✅ Consent management works (set/get)
- ✅ Events are tracked when consent is given
- ✅ Events are NOT tracked when consent is revoked
- ✅ Queue accumulates events
- ✅ Queue is cleared when consent is revoked

---

### 5. Test UserDataCollectionService

**⚠️ Note: This requires a logged-in user and API connection**

**Test in a real app session:**

```dart
import 'package:zoea2/core/services/user_data_collection_service.dart';
import 'package:zoea2/core/models/user.dart';

final service = UserDataCollectionService();

// Test saving mandatory data
try {
  final prefs = await service.saveMandatoryData(
    countryOfOrigin: 'RW',
    userType: UserType.resident,
    visitPurpose: VisitPurpose.leisure,
    language: 'en',
    analyticsConsent: true,
  );
  print('Saved preferences: ${prefs.countryOfOrigin}');
} catch (e) {
  print('Error: $e');
}

// Test saving progressive data
try {
  final prefs = await service.saveProgressiveData(
    ageRange: AgeRange.range26_35,
    gender: Gender.male,
    flagKey: 'ageAsked',
  );
  print('Saved progressive data');
} catch (e) {
  print('Error: $e');
}

// Test checking mandatory data
final isComplete = await service.isMandatoryDataComplete();
print('Is mandatory complete: $isComplete');

// Test profile completion
final percentage = await service.getProfileCompletionPercentage();
print('Profile completion: $percentage%');
```

**Expected Results:**
- ✅ Mandatory data saves successfully (if logged in)
- ✅ Progressive data saves successfully
- ✅ `isMandatoryDataComplete` returns correct status
- ✅ Profile completion percentage is calculated correctly

---

### 6. Test Riverpod Providers

**Test in a widget or Flutter DevTools:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoea2/core/providers/user_data_collection_provider.dart';

final container = ProviderContainer();

// Test inferred data provider
final inferredData = await container.read(inferredDataProvider.future);
print('Inferred data: $inferredData');

// Test session count provider
final sessionCount = await container.read(sessionCountProvider.future);
print('Session count: $sessionCount');

// Test analytics consent provider
final consent = await container.read(analyticsConsentProvider.future);
print('Analytics consent: $consent');
```

**Expected Results:**
- ✅ Providers return correct data
- ✅ Providers handle errors gracefully
- ✅ Providers update when underlying data changes

---

## ✅ Checklist

### Models & Enums
- [ ] UserPreferences creates with new fields
- [ ] JSON serialization works
- [ ] JSON deserialization works
- [ ] `isMandatoryDataComplete` works correctly
- [ ] `profileCompletionPercentage` calculates correctly
- [ ] All enum extensions work (displayName, apiValue, fromString)

### Services
- [ ] DataInferenceService infers country from locale
- [ ] DataInferenceService infers language from locale
- [ ] DataInferenceService infers user type correctly
- [ ] PromptTimingService tracks sessions
- [ ] PromptTimingService manages prompt timing correctly
- [ ] AnalyticsService manages consent
- [ ] AnalyticsService tracks events (with consent)
- [ ] AnalyticsService doesn't track events (without consent)
- [ ] UserDataCollectionService saves mandatory data (if logged in)
- [ ] UserDataCollectionService saves progressive data (if logged in)

### Providers
- [ ] All providers initialize correctly
- [ ] Providers return expected data types
- [ ] Providers handle errors gracefully

---

## 🐛 Troubleshooting

### Issue: Tests fail with "No implementation found"
**Solution:** Make sure you're running tests in the `mobile` directory:
```bash
cd mobile
flutter test
```

### Issue: Services fail with "User not logged in"
**Solution:** UserDataCollectionService requires authentication. Test with a logged-in user or mock the service.

### Issue: DataInferenceService returns null
**Solution:** This is normal if device locale cannot be determined. The service has fallback defaults.

---

## 📝 Next Steps

After Phase 1 testing is complete:
1. ✅ Verify all models and enums work
2. ✅ Verify all services work (with/without API)
3. ✅ Verify providers work
4. ✅ Proceed to Phase 2 testing (UI components)

---

**Happy Testing! 🚀**

