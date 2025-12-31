import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../utils/phone_validator.dart';

class UserService {
  Dio? _dio;

  /// Get authenticated Dio instance
  Future<Dio> _getDio() async {
    _dio ??= await AppConfig.authenticatedDioInstance();
    return _dio!;
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await (await _getDio()).get('${AppConfig.usersEndpoint}/me');

      if (response.statusCode == 200) {
        final userData = response.data;
        return _parseUserFromResponse(userData);
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch user profile.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'User profile not found.';
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
      throw Exception('Error fetching user profile: $e');
    }
  }

  /// Update current user profile
  Future<User> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (fullName != null) data['fullName'] = fullName;
      if (phoneNumber != null) {
        data['phoneNumber'] = PhoneValidator.cleanPhoneNumber(phoneNumber);
      }
      if (bio != null) data['bio'] = bio;
      if (preferences != null) data['preferences'] = preferences;

      final response = await (await _getDio()).put(
        '${AppConfig.usersEndpoint}/me',
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        return _parseUserFromResponse(userData);
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update profile.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid profile data.';
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
      throw Exception('Error updating profile: $e');
    }
  }

  /// Update email address
  /// Requires current password for verification
  Future<void> updateEmail(String newEmail, {String? password}) async {
    try {
      if (password == null || password.isEmpty) {
        throw Exception('Password is required to update email address for security reasons.');
      }
      
      final response = await (await _getDio()).put(
        '${AppConfig.usersEndpoint}/me/email',
        data: {
          'email': newEmail.trim(),
          'password': password,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update email: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update email.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid email address.';
        } else if (statusCode == 409) {
          errorMessage = 'Email already in use.';
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
      throw Exception('Error updating email: $e');
    }
  }

  /// Update phone number
  Future<void> updatePhone(String newPhone) async {
    try {
      final response = await (await _getDio()).put(
        '${AppConfig.usersEndpoint}/me/phone',
        data: {'phoneNumber': PhoneValidator.cleanPhoneNumber(newPhone)},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update phone: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update phone number.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid phone number.';
        } else if (statusCode == 409) {
          errorMessage = 'Phone number already in use.';
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
      throw Exception('Error updating phone: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await (await _getDio()).put(
        '${AppConfig.usersEndpoint}/me/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to change password: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to change password.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Current password is incorrect.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid password.';
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
      throw Exception('Error changing password: $e');
    }
  }

  /// Update profile image
  Future<User> updateProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await (await _getDio()).put(
        '${AppConfig.usersEndpoint}/me/profile-image',
        data: formData,
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        return _parseUserFromResponse(userData);
      } else {
        throw Exception('Failed to update profile image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update profile image.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid image file.';
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
      throw Exception('Error updating profile image: $e');
    }
  }

  /// Get user preferences
  /// Now returns all fields including new UX-first data collection fields
  Future<UserPreferences> getPreferences() async {
    try {
      final response = await (await _getDio()).get('${AppConfig.usersEndpoint}/me/preferences');

      if (response.statusCode == 200) {
        final prefsData = response.data as Map<String, dynamic>;
        
        // Transform API response to match our model format
        // API uses preferredLanguage/preferredCurrency, but our model uses language/currency
        final transformedData = <String, dynamic>{
          'language': prefsData['preferredLanguage']?.toString(),
          'currency': prefsData['preferredCurrency']?.toString() ?? 'RWF',
          'interests': prefsData['interests'] != null && prefsData['interests'] is List
              ? List<String>.from(prefsData['interests'])
              : [],
        };

        // Handle notification preferences
        final notificationPrefs = prefsData['notificationPreferences'] as Map<String, dynamic>?;
        final notificationsEnabled = notificationPrefs?['push'] ?? 
                                     notificationPrefs?['email'] ?? 
                                     true;
        transformedData['notificationsEnabled'] = notificationsEnabled;

        // Handle location (API uses isPrivate, inverse of locationEnabled)
        transformedData['locationEnabled'] = !(prefsData['isPrivate'] ?? false);

        // Include new UX-first fields if present
        if (prefsData['countryOfOrigin'] != null) {
          transformedData['countryOfOrigin'] = prefsData['countryOfOrigin'];
        }
        if (prefsData['userType'] != null) {
          transformedData['userType'] = prefsData['userType'];
        }
        if (prefsData['visitPurpose'] != null) {
          transformedData['visitPurpose'] = prefsData['visitPurpose'];
        }
        if (prefsData['ageRange'] != null) {
          transformedData['ageRange'] = prefsData['ageRange'];
        }
        if (prefsData['gender'] != null) {
          transformedData['gender'] = prefsData['gender'];
        }
        if (prefsData['lengthOfStay'] != null) {
          transformedData['lengthOfStay'] = prefsData['lengthOfStay'];
        }
        if (prefsData['travelParty'] != null) {
          transformedData['travelParty'] = prefsData['travelParty'];
        }
        if (prefsData['dataCollectionFlags'] != null) {
          transformedData['dataCollectionFlags'] = prefsData['dataCollectionFlags'];
        }
        if (prefsData['dataCollectionCompletedAt'] != null) {
          transformedData['dataCollectionCompletedAt'] = prefsData['dataCollectionCompletedAt'];
        }

        // Use fromJson to parse all fields
        return UserPreferences.fromJson(transformedData);
      } else {
        throw Exception('Failed to fetch preferences: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch preferences.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
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
      throw Exception('Error fetching preferences: $e');
    }
  }

  /// Update user preferences
  /// Now supports both existing and new UX-first data collection fields
  Future<UserPreferences> updatePreferences({
    String? language,
    String? currency,
    bool? notificationsEnabled,
    bool? locationEnabled,
    List<String>? interests,
    // New UX-first fields
    String? countryOfOrigin,
    UserType? userType,
    VisitPurpose? visitPurpose,
    AgeRange? ageRange,
    Gender? gender,
    LengthOfStay? lengthOfStay,
    TravelParty? travelParty,
    Map<String, bool>? dataCollectionFlags,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      // Existing fields - API uses preferredLanguage and preferredCurrency at root level
      if (language != null) data['preferredLanguage'] = language;
      if (currency != null) data['preferredCurrency'] = currency;
      if (interests != null) data['interests'] = interests;
      // API uses isPrivate (inverse of locationEnabled)
      if (locationEnabled != null) data['isPrivate'] = !locationEnabled;
      // API uses notificationPreferences object
      if (notificationsEnabled != null) {
        data['notificationPreferences'] = {
          'push': notificationsEnabled,
          'email': notificationsEnabled,
        };
      }

      // New UX-first fields
      if (countryOfOrigin != null) data['countryOfOrigin'] = countryOfOrigin;
      if (userType != null) data['userType'] = userType.apiValue;
      if (visitPurpose != null) data['visitPurpose'] = visitPurpose.apiValue;
      if (ageRange != null) data['ageRange'] = ageRange.apiValue;
      if (gender != null) data['gender'] = gender.apiValue;
      if (lengthOfStay != null) data['lengthOfStay'] = lengthOfStay.apiValue;
      if (travelParty != null) data['travelParty'] = travelParty.apiValue;
      if (dataCollectionFlags != null) data['dataCollectionFlags'] = dataCollectionFlags;

      final response = await (await _getDio()).put(
        '${AppConfig.usersEndpoint}/me/preferences',
        data: data,
      );

      if (response.statusCode == 200) {
        final prefsData = response.data;
        // Use fromJson to parse all fields including new ones
        return UserPreferences.fromJson(prefsData);
      } else {
        throw Exception('Failed to update preferences: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update preferences.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid preferences data.';
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
      throw Exception('Error updating preferences: $e');
    }
  }

  /// Get user statistics
  /// Returns: {bookings: int, reviews: int, favorites: int, visitedPlaces: int}
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await (await _getDio()).get('${AppConfig.usersEndpoint}/me/stats');

      if (response.statusCode == 200) {
        final statsData = response.data as Map<String, dynamic>;
        // API returns: {bookings, reviews, favorites, visitedPlaces}
        return {
          'bookings': statsData['bookings'] ?? 0,
          'reviews': statsData['reviews'] ?? 0,
          'favorites': statsData['favorites'] ?? 0,
          'visitedPlaces': statsData['visitedPlaces'] ?? 0,
        };
      } else {
        throw Exception('Failed to fetch user stats: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch user statistics.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
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
      throw Exception('Error fetching user stats: $e');
    }
  }

  /// Delete account (soft delete)
  Future<void> deleteAccount() async {
    try {
      final response = await (await _getDio()).delete('${AppConfig.usersEndpoint}/me');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete account: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete account.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
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
      throw Exception('Error deleting account: $e');
    }
  }

  /// Parse user from API response
  User _parseUserFromResponse(Map<String, dynamic> data) {
    // Parse roles - V2 API returns roles as array
    UserRole role = UserRole.explorer;
    if (data['roles'] != null && data['roles'] is List) {
      final roles = data['roles'] as List;
      if (roles.contains('merchant')) {
        role = UserRole.merchant;
      } else if (roles.contains('event_organizer') || roles.contains('organizer')) {
        role = UserRole.eventOrganizer;
      } else if (roles.contains('admin')) {
        role = UserRole.admin;
      }
    }

    // Parse full name - handle different response formats
    String fullName = 'User';
    if (data['fullName'] != null && data['fullName'].toString().isNotEmpty) {
      fullName = data['fullName'].toString();
    } else if (data['firstName'] != null || data['lastName'] != null) {
      final firstName = data['firstName']?.toString() ?? '';
      final lastName = data['lastName']?.toString() ?? '';
      fullName = '$firstName $lastName'.trim();
      if (fullName.isEmpty) fullName = 'User';
    }

    // Parse profile image - handle nested structure
    String? profileImage;
    if (data['profileImage'] != null) {
      if (data['profileImage'] is Map) {
        profileImage = data['profileImage']['url'] ?? data['profileImage']['thumbnailUrl'];
      } else if (data['profileImage'] is String) {
        profileImage = data['profileImage'];
      }
    } else if (data['profileImageUrl'] != null) {
      profileImage = data['profileImageUrl'].toString();
    }

    // Parse dates
    DateTime createdAt = DateTime.now();
    if (data['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(data['createdAt'].toString());
      } catch (e) {
        createdAt = DateTime.now();
      }
    }

    DateTime updatedAt = DateTime.now();
    if (data['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(data['updatedAt'].toString());
      } catch (e) {
        updatedAt = DateTime.now();
      }
    }

    // Parse preferences - API uses preferredCurrency and preferredLanguage at root level
    // Also has notificationPreferences object
    final notificationPrefs = data['notificationPreferences'] as Map<String, dynamic>?;
    final notificationsEnabled = notificationPrefs?['push'] ?? 
                                 notificationPrefs?['email'] ?? 
                                 true;

    return User(
      id: data['id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      fullName: fullName,
      phoneNumber: data['phoneNumber']?.toString(),
      profileImage: profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isVerified: data['isVerified'] == true,
      role: role,
      preferences: UserPreferences(
        language: data['preferredLanguage']?.toString() ?? 
                 data['preferences']?['language']?.toString(),
        currency: data['preferredCurrency']?.toString() ?? 
                 data['preferences']?['currency']?.toString() ?? 'RWF',
        notificationsEnabled: notificationsEnabled,
        locationEnabled: true, // Default, API doesn't expose this directly
        interests: data['interests'] != null && data['interests'] is List
            ? List<String>.from(data['interests'])
            : data['preferences']?['interests'] != null && data['preferences']['interests'] is List
                ? List<String>.from(data['preferences']['interests'])
                : [],
      ),
    );
  }
}

