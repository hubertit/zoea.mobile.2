# UX-First User Data Collection - Implementation Plan

## Overview
This document outlines the implementation plan for a frictionless, progressive user data collection system in the Zoea mobile app that respects user time, privacy, and maintains design consistency.

---

## 1. Architecture & Design Patterns

### 1.1 Existing Patterns to Maintain
- **State Management**: Riverpod providers (`flutter_riverpod`)
- **Navigation**: GoRouter (`go_router`)
- **UI Components**: Bottom sheets (`showModalBottomSheet`), Cards, Chips
- **Theme**: `AppTheme` with consistent colors, typography, spacing
- **Storage**: `SharedPreferences` via `TokenStorageService`
- **API**: `UserService` for backend communication
- **Models**: `User` and `UserPreferences` models

### 1.2 New Components to Create
```
mobile/lib/
├── core/
│   ├── models/
│   │   └── user_profile_data.dart          # Extended user data model
│   ├── services/
│   │   ├── user_data_collection_service.dart  # Progressive collection logic
│   │   └── analytics_service.dart             # Passive data tracking
│   └── providers/
│       └── user_data_collection_provider.dart # State management
└── features/
    └── user_data_collection/
        ├── screens/
        │   ├── onboarding_data_screen.dart    # Mandatory minimal data
        │   └── progressive_prompt_screen.dart  # Optional prompts
        ├── widgets/
        │   ├── country_selector.dart           # Chip-based country selection
        │   ├── visit_purpose_selector.dart    # Leisure/Business/MICE
        │   ├── age_range_selector.dart        # Range slider/chips
        │   ├── gender_selector.dart            # Icon-based with "Prefer not to say"
        │   ├── interests_chips.dart            # Multi-select chips
        │   ├── travel_party_selector.dart      # Icon-based party size
        │   └── length_of_stay_selector.dart   # Range selector
        └── utils/
            ├── data_inference_service.dart     # Infer from device/IP
            └── prompt_timing_service.dart      # When to show prompts
```

---

## 2. Data Model Extensions

### 2.1 Extended User Model
Extend `UserPreferences` to include:
```dart
class UserPreferences {
  // Existing fields
  final String? language;
  final String? currency;
  final bool notificationsEnabled;
  final bool locationEnabled;
  final List<String> interests;
  
  // New UX-first fields
  final String? countryOfOrigin;        // ISO country code
  final UserType? userType;              // resident, visitor
  final VisitPurpose? visitPurpose;     // leisure, business, mice
  final AgeRange? ageRange;              // e.g., "18-25", "26-35", etc.
  final Gender? gender;                  // male, female, other, prefer_not_to_say
  final LengthOfStay? lengthOfStay;      // "1-3 days", "4-7 days", etc.
  final TravelParty? travelParty;        // solo, couple, family, group
  final DateTime? dataCollectionCompletedAt;
  final Map<String, bool> dataCollectionFlags; // Track what's been asked
}
```

### 2.2 Enums
```dart
enum UserType { resident, visitor }
enum VisitPurpose { leisure, business, mice }
enum AgeRange { range18_25, range26_35, range36_45, range46_55, range56_plus }
enum Gender { male, female, other, preferNotToSay }
enum LengthOfStay { oneToThreeDays, fourToSevenDays, oneToTwoWeeks, twoWeeksPlus }
enum TravelParty { solo, couple, family, group }
```

---

## 3. Implementation Phases

### Phase 1: Core Infrastructure (Week 1)

#### 3.1.1 Data Models & Services
- [ ] Extend `UserPreferences` model with new fields
- [ ] Create `UserDataCollectionService` for API communication
- [ ] Create `AnalyticsService` for passive tracking
- [ ] Create `DataInferenceService` for device/IP-based inference
- [ ] Create `PromptTimingService` for smart prompt scheduling

#### 3.1.2 State Management
- [ ] Create `userDataCollectionProvider` (Riverpod)
- [ ] Create `analyticsProvider` for passive data
- [ ] Create `promptTimingProvider` for prompt state

#### 3.1.3 Backend Integration
- [ ] Extend `UserService.updatePreferences()` to handle new fields
- [ ] Add API endpoints support (if needed)
- [ ] Handle existing users (4,500+) with null values gracefully

---

### Phase 2: Mandatory Onboarding (Week 1-2)

#### 3.2.1 Minimal Onboarding Screen
**Location**: After successful registration/login, before main app

**Data Collected** (10-15 seconds):
1. Country of origin (chip-based, auto-detected)
2. Resident vs Visitor (two large buttons)
3. Visit purpose: Leisure / Business / MICE (chip selection)
4. Language (auto-detected, user can change)
5. Analytics consent (checkbox with explanation)

**UX Pattern**:
- Full-screen card-based design
- One question per card
- Large tap targets (minimum 48x48dp)
- No text input
- Progress indicator (optional, max 2 steps)
- Skip button (only for non-legal items)

**Implementation**:
```dart
// Route: /onboarding-data (after /onboarding or /register)
// File: features/user_data_collection/screens/onboarding_data_screen.dart
```

**Design Specs**:
- Use `AppTheme` colors and typography
- Bottom sheet pattern (50-70% height) OR full-screen cards
- Smooth animations with `flutter_animate`
- Consistent with existing `OnboardingScreen` style

---

### Phase 3: Progressive Prompts (Week 2-3)

#### 3.3.1 Prompt System Architecture
**Trigger Logic**:
- After 2-3 app sessions
- After saving a place
- After viewing an event
- After navigation usage
- Never more than once per day
- Never block app access

**Prompt Types**:
1. **Age Range** - Bottom sheet with range chips
2. **Gender** - Icon-based selector
3. **Length of Stay** - Range selector
4. **Interests** - Multi-select chips
5. **Travel Party** - Icon-based selector

**UX Pattern**:
- Bottom sheet (50-70% height)
- One question per prompt
- Always skippable ("Maybe later" button)
- Friendly copy: "Help us personalize Zoea (10 sec)"
- Non-intrusive design

**Implementation**:
```dart
// File: features/user_data_collection/widgets/progressive_prompt_screen.dart
// Service: PromptTimingService tracks when to show
```

---

### Phase 4: Passive Data Collection (Week 3)

#### 3.4.1 Analytics Service
**Track Silently**:
- Search queries
- Viewed listings (IDs, categories, timestamps)
- Event views & interactions
- Navigation usage (zones only, aggregated)
- App usage frequency & time
- Booking attempts/completions

**Implementation**:
```dart
// File: core/services/analytics_service.dart
// Uses SharedPreferences for local storage
// Batches and sends to backend periodically
// Respects user consent
```

**Privacy**:
- Aggregated data only
- No exact locations
- No personal identifiers
- User can opt-out anytime

---

### Phase 5: Existing Users Migration (Week 3-4)

#### 3.5.1 Silent Enrichment
**On App Launch** (for existing 4,500+ users):
1. Infer country from IP/SIM (via `DataInferenceService`)
2. Infer language from device settings
3. Infer resident vs visitor (based on country)
4. Mark all other fields as `null`
5. No prompts shown initially

#### 3.5.2 Gradual Enrichment (30-60 days)
- After 2-3 sessions, show friendly prompt
- One question at a time
- Event-driven prompts (when relevant)
- Never block access

**Implementation**:
```dart
// File: core/services/data_inference_service.dart
// Checks: device locale, IP geolocation (if available), SIM country
```

---

### Phase 6: MICE Contextual Data (Week 4)

#### 3.6.1 MICE-Specific Collection
**Only shown inside MICE event flows**:
- Delegate self-identification
- Conference association
- Pre/during/post-event behavior

**Implementation**:
- Integrate into `EventDetailScreen`
- Pre-filled where possible
- One-tap confirmation
- Contextual to event type

---

## 4. UI Component Specifications

### 4.1 Country Selector
```dart
// Widget: CountrySelector
// Pattern: Chip-based grid (2-3 columns)
// Auto-detection: Show detected country first, allow change
// Design: Large chips (min 80x40dp), rounded corners
```

### 4.2 Visit Purpose Selector
```dart
// Widget: VisitPurposeSelector
// Pattern: 3 large cards/chips
// Icons: Leisure (🏖️), Business (💼), MICE (🎤)
// Design: Full-width cards, prominent selection state
```

### 4.3 Age Range Selector
```dart
// Widget: AgeRangeSelector
// Pattern: Chip-based ranges
// Options: 18-25, 26-35, 36-45, 46-55, 56+
// Design: Horizontal scrollable chips
```

### 4.4 Gender Selector
```dart
// Widget: GenderSelector
// Pattern: Icon-based with labels
// Options: Male, Female, Other, Prefer not to say
// Design: 4 equal-width cards with icons
// Always include "Prefer not to say" option
```

### 4.5 Interests Chips
```dart
// Widget: InterestsChips
// Pattern: Multi-select chips (existing pattern)
// Categories: Adventure, Culture, Nature, Food, Nightlife, Shopping, etc.
// Design: Wrap layout, selected state with AppTheme.primaryColor
```

### 4.6 Travel Party Selector
```dart
// Widget: TravelPartySelector
// Pattern: Icon-based
// Options: Solo (👤), Couple (👥), Family (👨‍👩‍👧), Group (👥👥)
// Design: 4 equal-width cards
```

### 4.7 Length of Stay Selector
```dart
// Widget: LengthOfStaySelector
// Pattern: Range chips
// Options: 1-3 days, 4-7 days, 1-2 weeks, 2+ weeks
// Design: Horizontal chips
```

---

## 5. Integration Points

### 5.1 Router Integration
```dart
// app_router.dart
// Add route: /onboarding-data
// Show after registration/login if data incomplete
// Redirect logic: Check if mandatory data exists
```

### 5.2 Auth Flow Integration
```dart
// auth_service.dart / splash_screen.dart
// After successful login/register:
// 1. Check if mandatory data collected
// 2. If not, redirect to /onboarding-data
// 3. If yes, proceed to /explore
```

### 5.3 Profile Screen Integration
```dart
// profile_screen.dart
// Add "Complete Profile" section if data incomplete
// Show progress indicator
// Link to data collection screens
```

### 5.4 Event-Driven Prompts
```dart
// place_detail_screen.dart, event_detail_screen.dart
// After user interaction (save, view, navigate):
// Check PromptTimingService
// Show relevant prompt if conditions met
```

---

## 6. Backend API Requirements

### 6.1 Endpoints Needed
```
PUT /users/me/preferences
  - Extended to accept new fields
  - Handle partial updates gracefully

POST /users/me/analytics
  - Batch passive data
  - Respect consent flags

GET /users/me/profile-completeness
  - Return completion percentage
  - Return missing fields (optional)
```

### 6.2 Data Schema
```json
{
  "preferences": {
    "countryOfOrigin": "RW",
    "userType": "visitor",
    "visitPurpose": "leisure",
    "ageRange": "26-35",
    "gender": "prefer_not_to_say",
    "lengthOfStay": "4-7 days",
    "travelParty": "couple",
    "interests": ["adventure", "culture"],
    "dataCollectionFlags": {
      "countryAsked": true,
      "ageAsked": false,
      "interestsAsked": true
    }
  }
}
```

---

## 7. Privacy & Consent

### 7.1 Consent Management
- Analytics consent checkbox in mandatory onboarding
- Clear explanation: "Used to improve recommendations"
- Stored in `UserPreferences`
- User can revoke anytime in Settings

### 7.2 Privacy Signals
- Short explanations on each prompt
- Clear opt-out options
- No exact age, no IDs, no exact location
- Aggregated & anonymized by default

### 7.3 Settings Integration
```dart
// settings_screen.dart / privacy_security_screen.dart
// Add section: "Data & Privacy"
// Options:
//   - View collected data
//   - Manage analytics consent
//   - Clear collected data
//   - Export data (GDPR compliance)
```

---

## 8. Testing Strategy

### 8.1 Unit Tests
- Data inference logic
- Prompt timing logic
- Data model serialization

### 8.2 Integration Tests
- Onboarding flow
- Progressive prompts
- Backend API communication

### 8.3 User Testing
- Time to complete mandatory onboarding (target: <15s)
- Prompt acceptance rate
- User feedback on UX

---

## 9. Success Metrics

### 9.1 UX Metrics
- Average time to complete mandatory onboarding: <15 seconds
- Prompt acceptance rate: >60%
- User drop-off rate: <5%

### 9.2 Data Quality Metrics
- Profile completion rate: >70% (after 30 days)
- Data accuracy: Validated against passive data
- Collection rate: Track progressive enrichment

---

## 10. Implementation Checklist

### Week 1: Foundation
- [ ] Extend UserPreferences model
- [ ] Create UserDataCollectionService
- [ ] Create AnalyticsService
- [ ] Create DataInferenceService
- [ ] Create Riverpod providers
- [ ] Update UserService API methods

### Week 2: Mandatory Onboarding
- [ ] Create onboarding_data_screen.dart
- [ ] Create country_selector widget
- [ ] Create visit_purpose_selector widget
- [ ] Integrate with router
- [ ] Add to auth flow
- [ ] Test with new users

### Week 3: Progressive Prompts
- [ ] Create PromptTimingService
- [ ] Create progressive_prompt_screen.dart
- [ ] Create all selector widgets
- [ ] Integrate event-driven triggers
- [ ] Test prompt timing logic

### Week 4: Passive & Migration
- [ ] Implement AnalyticsService tracking
- [ ] Implement DataInferenceService
- [ ] Test existing user migration
- [ ] Add MICE contextual prompts
- [ ] Add privacy settings
- [ ] End-to-end testing

---

## 11. Design Consistency Guidelines

### 11.1 Colors
- Use `AppTheme.primaryColor` for selections
- Use `AppTheme.secondaryTextColor` for hints
- Use `AppTheme.successColor` for confirmations
- Use `AppTheme.dividerColor` for borders

### 11.2 Typography
- Use `AppTheme.displayMedium` for titles
- Use `AppTheme.bodyMedium` for descriptions
- Use `AppTheme.labelMedium` for buttons

### 11.3 Spacing
- Use `AppTheme.spacing16` for standard padding
- Use `AppTheme.spacing24` for section spacing
- Use `AppTheme.borderRadius16` for cards

### 11.4 Animations
- Use `flutter_animate` package (already in dependencies)
- Fade in: 300-600ms
- Slide: 300-400ms
- Scale: 200-300ms

---

## 12. Future Enhancements

### 12.1 Smart Inferences
- Infer interests from search history
- Infer travel party from booking history
- Infer length of stay from accommodation searches

### 12.2 Gamification
- Profile completion badges
- Progress indicators
- Rewards for completion (optional)

### 12.3 A/B Testing
- Test different prompt timings
- Test different UI patterns
- Optimize conversion rates

---

## 13. Notes & Considerations

### 13.1 Existing Users (4,500+)
- Never force data collection
- Always allow skipping
- Gradual enrichment over 30-60 days
- Silent inference where possible

### 13.2 Offline Support
- Store prompts locally
- Queue analytics data
- Sync when online

### 13.3 Internationalization
- Support multiple languages
- Use device locale as default
- Allow language change in onboarding

### 13.4 Accessibility
- Large tap targets (min 48x48dp)
- Screen reader support
- High contrast mode support
- Clear focus indicators

---

**End of Plan**

