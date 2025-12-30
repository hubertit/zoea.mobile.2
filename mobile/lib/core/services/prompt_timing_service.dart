import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_storage_service.dart';
import '../models/user.dart';

/// Service for managing when to show progressive data collection prompts
/// Implements smart timing logic to avoid annoying users
class PromptTimingService {
  static const String _sessionCountKey = 'user_data_collection_session_count';
  static const String _lastPromptDateKey = 'user_data_collection_last_prompt_date';
  static const String _lastPromptTypeKey = 'user_data_collection_last_prompt_type';
  static const String _dontAskAgainKey = 'user_data_collection_dont_ask_again';
  static const String _promptsShownKey = 'user_data_collection_prompts_shown';

  final TokenStorageService _tokenStorage = TokenStorageService.getInstance() as TokenStorageService;

  /// Increment session count (call on app launch)
  Future<void> incrementSessionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_sessionCountKey) ?? 0;
      await prefs.setInt(_sessionCountKey, currentCount + 1);
    } catch (e) {
      // Silently fail
    }
  }

  /// Get current session count
  Future<int> getSessionCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_sessionCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if we should show a prompt based on session count
  /// Returns true if user has completed 2-3 sessions
  Future<bool> shouldShowPromptBasedOnSessions() async {
    try {
      final sessionCount = await getSessionCount();
      // Show after 2-3 sessions
      return sessionCount >= 2 && sessionCount <= 3;
    } catch (e) {
      return false;
    }
  }

  /// Check if a prompt was shown today
  Future<bool> wasPromptShownToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPromptDate = prefs.getString(_lastPromptDateKey);
      if (lastPromptDate == null) return false;

      final lastDate = DateTime.parse(lastPromptDate);
      final today = DateTime.now();
      
      return lastDate.year == today.year &&
          lastDate.month == today.month &&
          lastDate.day == today.day;
    } catch (e) {
      return false;
    }
  }

  /// Record that a prompt was shown
  Future<void> recordPromptShown(String promptType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastPromptDateKey, DateTime.now().toIso8601String());
      await prefs.setString(_lastPromptTypeKey, promptType);
      
      // Track total prompts shown
      final promptsShown = prefs.getStringList(_promptsShownKey) ?? [];
      if (!promptsShown.contains(promptType)) {
        promptsShown.add(promptType);
        await prefs.setStringList(_promptsShownKey, promptsShown);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Get the last prompt type shown
  Future<String?> getLastPromptType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastPromptTypeKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user selected "Don't ask again" for a specific prompt type
  Future<bool> shouldNotAskAgain(String promptType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dontAskList = prefs.getStringList(_dontAskAgainKey) ?? [];
      return dontAskList.contains(promptType);
    } catch (e) {
      return false;
    }
  }

  /// Mark a prompt type as "Don't ask again"
  Future<void> setDontAskAgain(String promptType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dontAskList = prefs.getStringList(_dontAskAgainKey) ?? [];
      if (!dontAskList.contains(promptType)) {
        dontAskList.add(promptType);
        await prefs.setStringList(_dontAskAgainKey, dontAskList);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Check if we can show a prompt now
  /// Returns true if:
  /// - No prompt shown today
  /// - User hasn't selected "Don't ask again"
  /// - Session count is appropriate (for session-based prompts)
  Future<bool> canShowPrompt({
    String? promptType,
    bool checkSessionCount = false,
  }) async {
    try {
      // Check if prompt was shown today
      if (await wasPromptShownToday()) {
        return false;
      }

      // Check if user selected "Don't ask again"
      if (promptType != null && await shouldNotAskAgain(promptType)) {
        return false;
      }

      // Check session count if required
      if (checkSessionCount) {
        if (!await shouldShowPromptBasedOnSessions()) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if a specific data field has been asked/collected
  Future<bool> hasDataBeenCollected(String fieldName) async {
    try {
      final user = await _tokenStorage.getUserData();
      if (user?.preferences == null) return false;

      final flags = user!.preferences!.dataCollectionFlags;
      return flags[fieldName] == true;
    } catch (e) {
      return false;
    }
  }

  /// Get the next prompt type to show based on missing data
  /// Returns the first missing field that hasn't been asked
  /// Note: lengthOfStay is only shown for visitors, not residents
  Future<String?> getNextPromptType() async {
    try {
      final user = await _tokenStorage.getUserData();
      if (user?.preferences == null) return null;

      final prefs = user!.preferences!;
      final flags = prefs.dataCollectionFlags;
      final isVisitor = prefs.userType == UserType.visitor;

      // Check in priority order
      if (prefs.ageRange == null && flags['ageAsked'] != true) {
        return 'age';
      }
      if (prefs.gender == null && flags['genderAsked'] != true) {
        return 'gender';
      }
      if (prefs.interests.isEmpty && flags['interestsAsked'] != true) {
        return 'interests';
      }
      // Only show lengthOfStay for visitors
      if (isVisitor && prefs.lengthOfStay == null && flags['lengthOfStayAsked'] != true) {
        return 'lengthOfStay';
      }
      if (prefs.travelParty == null && flags['travelPartyAsked'] != true) {
        return 'travelParty';
      }

      return null; // All data collected
    } catch (e) {
      return null;
    }
  }

  /// Reset all prompt timing data (for testing or user reset)
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionCountKey);
      await prefs.remove(_lastPromptDateKey);
      await prefs.remove(_lastPromptTypeKey);
      await prefs.remove(_dontAskAgainKey);
      await prefs.remove(_promptsShownKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Check if we should show a prompt after a specific user action
  /// e.g., after saving a place, viewing an event, etc.
  Future<bool> shouldShowPromptAfterAction({
    required String actionType, // 'save_place', 'view_event', 'use_navigation'
    String? suggestedPromptType,
  }) async {
    try {
      // Check basic conditions first
      if (!await canShowPrompt(promptType: suggestedPromptType)) {
        return false;
      }

      // Action-specific logic
      switch (actionType) {
        case 'save_place':
          // Show interests prompt if not collected
          if (suggestedPromptType == 'interests' || suggestedPromptType == null) {
            if (!await hasDataBeenCollected('interestsAsked')) {
              return true;
            }
          }
          break;

        case 'view_event':
          // Show age prompt if not collected
          if (suggestedPromptType == 'age' || suggestedPromptType == null) {
            if (!await hasDataBeenCollected('ageAsked')) {
              return true;
            }
          }
          break;

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
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

