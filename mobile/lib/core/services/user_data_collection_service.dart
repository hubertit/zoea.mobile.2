import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../services/token_storage_service.dart';

/// Service for managing UX-first user data collection
class UserDataCollectionService {
  final Dio _dio = AppConfig.dioInstance();
  final TokenStorageService _tokenStorage = TokenStorageService.getInstance() as TokenStorageService;

  /// Save mandatory onboarding data
  /// This is called after the user completes the initial onboarding screen
  Future<UserPreferences> saveMandatoryData({
    required String countryOfOrigin,
    required UserType userType,
    required VisitPurpose visitPurpose,
    required String language,
    bool analyticsConsent = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'preferences': {
          'countryOfOrigin': countryOfOrigin,
          'userType': userType.apiValue,
          'visitPurpose': visitPurpose.apiValue,
          'preferredLanguage': language,
          'notificationPreferences': {
            'push': analyticsConsent,
            'email': analyticsConsent,
          },
          'dataCollectionFlags': {
            'countryAsked': true,
            'userTypeAsked': true,
            'visitPurposeAsked': true,
            'languageAsked': true,
            'analyticsConsentAsked': true,
          },
        },
      };

      final response = await _dio.put(
        '${AppConfig.usersEndpoint}/me',
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        final preferencesData = userData['preferences'] as Map<String, dynamic>?;
        
        if (preferencesData != null) {
          return UserPreferences.fromJson(preferencesData);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to save mandatory data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to save data.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid data.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error saving mandatory data: $e');
    }
  }

  /// Save optional progressive data (age range, gender, etc.)
  /// This is called when user completes a progressive prompt
  Future<UserPreferences> saveProgressiveData({
    AgeRange? ageRange,
    Gender? gender,
    LengthOfStay? lengthOfStay,
    TravelParty? travelParty,
    List<String>? interests,
    String? flagKey, // e.g., 'ageAsked', 'genderAsked'
  }) async {
    try {
      final preferences = <String, dynamic>{};
      final flags = <String, bool>{};

      if (ageRange != null) {
        preferences['ageRange'] = ageRange.apiValue;
        flags['ageAsked'] = true;
      }
      if (gender != null) {
        preferences['gender'] = gender.apiValue;
        flags['genderAsked'] = true;
      }
      if (lengthOfStay != null) {
        preferences['lengthOfStay'] = lengthOfStay.apiValue;
        flags['lengthOfStayAsked'] = true;
      }
      if (travelParty != null) {
        preferences['travelParty'] = travelParty.apiValue;
        flags['travelPartyAsked'] = true;
      }
      if (interests != null && interests.isNotEmpty) {
        preferences['interests'] = interests;
        flags['interestsAsked'] = true;
      }
      if (flagKey != null) {
        flags[flagKey] = true;
      }

      // Merge with existing flags if any
      final currentUser = await _tokenStorage.getUserData();
      if (currentUser?.preferences?.dataCollectionFlags.isNotEmpty == true) {
        flags.addAll(currentUser!.preferences!.dataCollectionFlags);
      }

      preferences['dataCollectionFlags'] = flags;

      final data = <String, dynamic>{
        'preferences': preferences,
      };

      final response = await _dio.put(
        '${AppConfig.usersEndpoint}/me/preferences',
        data: data,
      );

      if (response.statusCode == 200) {
        final prefsData = response.data;
        return UserPreferences.fromJson(prefsData);
      } else {
        throw Exception('Failed to save progressive data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to save data.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid data.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error saving progressive data: $e');
    }
  }

  /// Update data collection flags (mark that a prompt was shown/asked)
  Future<void> updateDataCollectionFlags(Map<String, bool> flags) async {
    try {
      final currentUser = await _tokenStorage.getUserData();
      final existingFlags = currentUser?.preferences?.dataCollectionFlags ?? {};
      
      // Merge flags
      final mergedFlags = {...existingFlags, ...flags};

      final data = <String, dynamic>{
        'preferences': {
          'dataCollectionFlags': mergedFlags,
        },
      };

      await _dio.put(
        '${AppConfig.usersEndpoint}/me/preferences',
        data: data,
      );
    } on DioException catch (e) {
      // Silently fail - flags are not critical
      if (kDebugMode) {
        print('Failed to update data collection flags: $e');
      }
    } catch (e) {
      // Silently fail
      if (kDebugMode) {
        print('Error updating data collection flags: $e');
      }
    }
  }

  /// Check if mandatory data collection is complete
  Future<bool> isMandatoryDataComplete() async {
    try {
      final user = await _tokenStorage.getUserData();
      return user?.preferences?.isMandatoryDataComplete ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get profile completion percentage
  Future<int> getProfileCompletionPercentage() async {
    try {
      final user = await _tokenStorage.getUserData();
      return user?.preferences?.profileCompletionPercentage ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

