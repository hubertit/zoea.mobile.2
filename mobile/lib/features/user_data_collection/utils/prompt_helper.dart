import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_data_collection_provider.dart';
import '../screens/progressive_prompt_screen.dart';

/// Helper utility for showing progressive prompts after user actions
class PromptHelper {
  /// Check and show prompt after saving a place (interests prompt)
  static Future<void> checkAndShowPromptAfterSavePlace(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final timingService = ref.read(promptTimingServiceProvider);
      
      final shouldShow = await timingService.shouldShowPromptAfterAction(
        actionType: 'save_place',
        suggestedPromptType: 'interests',
      );

      if (shouldShow && context.mounted) {
        await showProgressivePrompt(context, 'interests');
      }
    } catch (e) {
      // Silently fail - prompts should never break the app
    }
  }

  /// Check and show prompt after viewing an event (age prompt)
  static Future<void> checkAndShowPromptAfterViewEvent(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final timingService = ref.read(promptTimingServiceProvider);
      
      final shouldShow = await timingService.shouldShowPromptAfterAction(
        actionType: 'view_event',
        suggestedPromptType: 'age',
      );

      if (shouldShow && context.mounted) {
        await showProgressivePrompt(context, 'age');
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Check and show prompt based on session count
  static Future<void> checkAndShowPromptBasedOnSessions(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final timingService = ref.read(promptTimingServiceProvider);
      
      // Check if we should show based on sessions
      if (!await timingService.shouldShowPromptBasedOnSessions()) {
        return;
      }

      // Check if we can show a prompt today
      if (!await timingService.canShowPrompt(checkSessionCount: true)) {
        return;
      }

      // Get next prompt type to show
      final nextPromptType = await timingService.getNextPromptType();
      
      if (nextPromptType != null && context.mounted) {
        await showProgressivePrompt(context, nextPromptType);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Check and show prompt after using navigation (length of stay prompt)
  static Future<void> checkAndShowPromptAfterNavigation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final timingService = ref.read(promptTimingServiceProvider);
      
      final shouldShow = await timingService.shouldShowPromptAfterAction(
        actionType: 'use_navigation',
        suggestedPromptType: 'lengthOfStay',
      );

      if (shouldShow && context.mounted) {
        await showProgressivePrompt(context, 'lengthOfStay');
      }
    } catch (e) {
      // Silently fail
    }
  }
}

