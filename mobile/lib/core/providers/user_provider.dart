import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for current user profile (refreshed from API)
final currentUserProfileProvider = FutureProvider<User>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getCurrentUser();
});

/// Provider for user statistics
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserStats();
});

/// Provider for user preferences
final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getPreferences();
});

