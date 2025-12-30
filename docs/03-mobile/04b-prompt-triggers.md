# Progressive Prompt Triggers - Documentation

## Overview
Progressive prompts are triggered automatically based on user behavior and session count. They appear as bottom sheets and are always skippable.

---

## Current Triggers (Implemented)

### 1. **Session-Based Trigger** ✅
**Location**: `explore_screen.dart` (main app entry point)

**When**: After user completes 2-3 app sessions

**How it works**:
- Session count is incremented on app launch (in `splash_screen.dart`)
- When user reaches explore screen, checks if session count is 2-3
- Shows the next missing data field prompt (age, gender, interests, etc.)
- Only shows once per day
- Respects "Don't ask again" preferences

**Code**:
```dart
// In explore_screen.dart initState
WidgetsBinding.instance.addPostFrameCallback((_) {
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      PromptHelper.checkAndShowPromptBasedOnSessions(context, ref);
    }
  });
});
```

---

### 2. **After Saving a Place** ✅
**Location**: `accommodation_detail_screen.dart` (and other detail screens)

**When**: User adds a place to favorites

**How it works**:
- Detects when a place is added to favorites (not removed)
- Waits 1 second after showing success message
- Shows interests prompt if not already collected
- Only shows if conditions are met (not shown today, not asked before, etc.)

**Code**:
```dart
// After toggleFavorite succeeds
if (!wasFavorited && context.mounted) {
  Future.delayed(const Duration(seconds: 1), () {
    if (context.mounted) {
      PromptHelper.checkAndShowPromptAfterSavePlace(context, ref);
    }
  });
}
```

---

### 3. **After Viewing an Event** ✅
**Location**: `event_detail_screen.dart`

**When**: User views an event detail page

**How it works**:
- Triggers 2 seconds after event detail screen loads
- Shows age range prompt if not already collected
- Only shows if conditions are met

**Code**:
```dart
// In event_detail_screen.dart build method
WidgetsBinding.instance.addPostFrameCallback((_) {
  Future.delayed(const Duration(seconds: 2), () {
    if (context.mounted) {
      PromptHelper.checkAndShowPromptAfterViewEvent(context, ref);
    }
  });
});
```

---

## Prompt Timing Rules

All prompts follow these rules (enforced by `PromptTimingService`):

1. **Never show more than 1 prompt per day**
2. **Never block app access** - prompts are always skippable
3. **Respect user preferences** - if user selected "Don't ask again", don't show
4. **Check if data already collected** - don't ask for data we already have
5. **Session-based timing** - only show after 2-3 sessions for session-based prompts

---

## Prompt Types & Their Triggers

| Prompt Type | Trigger | When |
|------------|---------|------|
| **Age Range** | Session-based OR After viewing event | After 2-3 sessions OR when viewing event detail |
| **Gender** | Session-based | After 2-3 sessions |
| **Interests** | Session-based OR After saving place | After 2-3 sessions OR when adding to favorites |
| **Length of Stay** | Session-based OR After using navigation | After 2-3 sessions OR when using map/navigation |
| **Travel Party** | Session-based | After 2-3 sessions |

---

## How to Add New Triggers

### Step 1: Add helper method in `prompt_helper.dart`
```dart
static Future<void> checkAndShowPromptAfterYourAction(
  BuildContext context,
  WidgetRef ref,
) async {
  try {
    final timingService = ref.read(promptTimingServiceProvider);
    
    final shouldShow = await timingService.shouldShowPromptAfterAction(
      actionType: 'your_action',
      suggestedPromptType: 'age', // or other prompt type
    );

    if (shouldShow && context.mounted) {
      await showProgressivePrompt(context, 'age');
    }
  } catch (e) {
    // Silently fail
  }
}
```

### Step 2: Call it in your screen
```dart
// After user action
PromptHelper.checkAndShowPromptAfterYourAction(context, ref);
```

### Step 3: Update `PromptTimingService.shouldShowPromptAfterAction()`
Add your action type in the switch statement:
```dart
case 'your_action':
  if (suggestedPromptType == 'age' || suggestedPromptType == null) {
    if (!await hasDataBeenCollected('ageAsked')) {
      return true;
    }
  }
  break;
```

---

## Testing Triggers

### Test Session-Based Trigger:
1. Clear app data
2. Launch app 2-3 times
3. Should see prompt on explore screen after 2 seconds

### Test Save Place Trigger:
1. Go to any place detail screen
2. Add place to favorites
3. Wait 1 second after success message
4. Should see interests prompt (if not already collected)

### Test View Event Trigger:
1. Go to any event detail screen
2. Wait 2 seconds
3. Should see age prompt (if not already collected)

---

## Future Triggers (Not Yet Implemented)

- **After using navigation/map**: Show length of stay prompt
- **After booking**: Show travel party prompt
- **After multiple searches**: Show interests prompt
- **After viewing multiple events**: Show age prompt

---

## Files Involved

- `prompt_helper.dart` - Helper functions for triggers
- `prompt_timing_service.dart` - Timing logic and rules
- `progressive_prompt_screen.dart` - The actual prompt UI
- `explore_screen.dart` - Session-based trigger
- `accommodation_detail_screen.dart` - Save place trigger
- `event_detail_screen.dart` - View event trigger
- `splash_screen.dart` - Session count increment

---

**Last Updated**: Phase 3 Implementation

