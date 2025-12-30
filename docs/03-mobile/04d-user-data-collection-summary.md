# User Data Collection - Quick Reference

## Core Principles
✅ **No long forms** - Max 3-4 actions at once  
✅ **No typing** - Taps, chips, sliders only  
✅ **Everything optional** - Except legal consent  
✅ **Progressive disclosure** - One question at the right moment  
✅ **Skippable by default** - Users stay in control  
✅ **Passive > Active** - Infer before asking  

---

## Mandatory Data (First App Open - 10-15s)
1. Country of origin (chip-based, auto-detected)
2. Resident vs Visitor (two large buttons)
3. Visit purpose: Leisure / Business / MICE (chips)
4. Language (auto-detected, user can change)
5. Analytics consent (checkbox)

**UX**: Full-screen cards or bottom sheet (50-70% height)

---

## Optional Data (Progressive - 10s each)
- Age range (chips: 18-25, 26-35, 36-45, 46-55, 56+)
- Gender (icons: Male, Female, Other, Prefer not to say)
- Length of stay (chips: 1-3 days, 4-7 days, 1-2 weeks, 2+ weeks)
- Interests (multi-select chips)
- Travel party (icons: Solo, Couple, Family, Group)

**UX**: Bottom sheet, one question at a time, always skippable

**Triggers**: After 2-3 sessions, after saving place, after viewing event, after navigation

---

## Passive Data (Background)
- Search queries
- Viewed listings
- Event interactions
- Navigation usage (zones only, aggregated)
- App usage patterns

**UX**: No UI, silent tracking, respects consent

---

## Existing Users (4,500+)
**Phase 1**: Silent inference (country, language, type)  
**Phase 2**: Gradual prompts after 2-3 sessions  
**Phase 3**: Event-driven prompts when relevant  

**Rule**: Never block access, always skippable

---

## File Structure
```
mobile/lib/
├── core/
│   ├── models/user.dart (extend UserPreferences)
│   ├── services/
│   │   ├── user_data_collection_service.dart
│   │   ├── analytics_service.dart
│   │   └── data_inference_service.dart
│   └── providers/
│       └── user_data_collection_provider.dart
└── features/
    └── user_data_collection/
        ├── screens/
        │   ├── onboarding_data_screen.dart
        │   └── progressive_prompt_screen.dart
        └── widgets/
            ├── country_selector.dart
            ├── visit_purpose_selector.dart
            ├── age_range_selector.dart
            ├── gender_selector.dart
            ├── interests_chips.dart
            ├── travel_party_selector.dart
            └── length_of_stay_selector.dart
```

---

## Design Patterns
- **Bottom Sheets**: `showModalBottomSheet` with `AppTheme` styling
- **Chips**: Wrap layout, selected state with `AppTheme.primaryColor`
- **Cards**: `Card` widget with `AppTheme.borderRadius16`
- **Animations**: `flutter_animate` package
- **State**: Riverpod providers
- **Navigation**: GoRouter

---

## Integration Points
1. **Auth Flow**: After login/register → Check mandatory data → Show onboarding if needed
2. **Router**: Add `/onboarding-data` route
3. **Profile**: Add "Complete Profile" section
4. **Event-Driven**: Trigger prompts after user actions (save, view, navigate)
5. **Settings**: Add "Data & Privacy" section

---

## API Endpoints
```
PUT /users/me/preferences
  - Extended to accept new fields
  - Handle partial updates

POST /users/me/analytics
  - Batch passive data
  - Respect consent

GET /users/me/profile-completeness
  - Return completion percentage
```

---

## Success Metrics
- Mandatory onboarding: <15 seconds
- Prompt acceptance rate: >60%
- Profile completion: >70% (after 30 days)
- User drop-off: <5%

---

## Implementation Order
1. **Week 1**: Models, Services, Providers
2. **Week 2**: Mandatory Onboarding Screen
3. **Week 3**: Progressive Prompts
4. **Week 4**: Passive Tracking & Existing User Migration

---

**See detailed plans:**
- `USER_DATA_COLLECTION_PLAN.md` - Full implementation plan
- `USER_DATA_COLLECTION_FLOW.md` - Flow diagrams & architecture

