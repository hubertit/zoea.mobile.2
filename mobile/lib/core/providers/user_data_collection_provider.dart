import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_data_collection_service.dart';
import '../services/data_inference_service.dart';
import '../services/prompt_timing_service.dart';
import '../services/analytics_service.dart';

/// Provider for UserDataCollectionService
final userDataCollectionServiceProvider = Provider<UserDataCollectionService>((ref) {
  return UserDataCollectionService();
});

/// Provider for DataInferenceService
final dataInferenceServiceProvider = Provider<DataInferenceService>((ref) {
  return DataInferenceService();
});

/// Provider for PromptTimingService
final promptTimingServiceProvider = Provider<PromptTimingService>((ref) {
  return PromptTimingService();
});

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider to check if mandatory data collection is complete
final isMandatoryDataCompleteProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(userDataCollectionServiceProvider);
  return await service.isMandatoryDataComplete();
});

/// Provider for profile completion percentage
final profileCompletionPercentageProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(userDataCollectionServiceProvider);
  return await service.getProfileCompletionPercentage();
});

/// Provider for session count
final sessionCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(promptTimingServiceProvider);
  return await service.getSessionCount();
});

/// Provider to check if we can show a prompt
final canShowPromptProvider = FutureProvider.family<bool, String?>((ref, promptType) async {
  final service = ref.watch(promptTimingServiceProvider);
  return await service.canShowPrompt(promptType: promptType);
});

/// Provider for next prompt type to show
final nextPromptTypeProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(promptTimingServiceProvider);
  return await service.getNextPromptType();
});

/// Provider for analytics consent status
final analyticsConsentProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.hasConsent();
});

/// Provider for inferred data (country, language, user type)
final inferredDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(dataInferenceServiceProvider);
  return await service.inferAllData();
});

