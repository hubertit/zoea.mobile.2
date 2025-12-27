import 'dart:async';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../utils/phone_validator.dart';
import 'token_storage_service.dart';

class AuthService {
  final StreamController<User?> _authController = StreamController<User?>.broadcast();
  final Dio _dio = AppConfig.dioInstance();
  TokenStorageService? _tokenStorage;
  
  Stream<User?> get authStateChanges => _authController.stream;
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthService() {
    _initializeTokenInterceptor();
  }

  Future<void> _initializeTokenInterceptor() async {
    _tokenStorage = await TokenStorageService.getInstance();
    
    // Load stored user after token storage is initialized
    await _loadStoredUser();
    
    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage?.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors - token expired
          if (error.response?.statusCode == 401) {
            // Skip refresh if this is already a refresh token request to avoid infinite loop
            if (error.requestOptions.path.contains('/refresh')) {
              // Refresh token request failed - session expired
              await signOut();
              handler.next(error);
              return;
            }
            
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request with new token
              final opts = error.requestOptions;
              final token = await _tokenStorage?.getAccessToken();
              if (token != null) {
                opts.headers['Authorization'] = 'Bearer $token';
                try {
                  final response = await _dio.fetch(opts);
                  handler.resolve(response);
                  return;
                } catch (e) {
                  // Retry failed even after refresh - might be a different error
                  // Don't logout, just pass the error
                  handler.next(error);
                  return;
                }
              }
            } else {
              // Refresh token failed - session expired, logout user
              await signOut();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _loadStoredUser() async {
    try {
      // Ensure token storage is initialized
      _tokenStorage ??= await TokenStorageService.getInstance();
      final isLoggedIn = await _tokenStorage?.isLoggedIn() ?? false;
      
      if (isLoggedIn) {
        // Check if we have valid tokens
        final accessToken = await _tokenStorage?.getAccessToken();
        final refreshToken = await _tokenStorage?.getRefreshToken();
        
        // If we have tokens, restore the session
        if (accessToken != null && refreshToken != null) {
          // First, load cached user data for immediate display
          final cachedUser = await _tokenStorage?.getUserData();
          if (cachedUser != null) {
            _currentUser = cachedUser;
            _authController.add(cachedUser);
          }
          
          // Then, validate tokens by trying to get current user from API
          // This ensures tokens are still valid and gets latest user data
          try {
            await getCurrentUser();
          } catch (e) {
            // If getCurrentUser fails with 401, try to refresh token
            if (e is DioException && e.response?.statusCode == 401) {
              final refreshed = await _refreshToken();
              if (refreshed) {
                // Token refreshed successfully, try to get user again
                try {
                  await getCurrentUser();
                } catch (e2) {
                  // If still fails after refresh, but we have cached user, keep session
                  // User might be offline or API temporarily unavailable
                  if (cachedUser != null) {
                    // Keep using cached user - session is still valid
                    return;
                  } else {
                    // No cached user and can't fetch - clear session
                    await signOut();
                  }
                }
              } else {
                // Refresh token failed - session expired
                // Only logout if refresh token is also invalid
                await signOut();
              }
            } else {
              // Network error or other issue - keep session if we have cached user
              // User might be offline, but session is still valid
              if (cachedUser == null) {
                // No cached user and can't fetch - might be first time login
                // Don't logout, let user try again later
              }
            }
          }
        } else {
          // No tokens found - clear login state
          await signOut();
        }
      }
    } catch (e) {
      // If loading fails completely, only clear if we don't have valid tokens
      final accessToken = await _tokenStorage?.getAccessToken();
      final refreshToken = await _tokenStorage?.getRefreshToken();
      
      if (accessToken == null || refreshToken == null) {
        await signOut();
      }
      // Otherwise, keep the session - might be a temporary error
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage?.getRefreshToken();
      if (refreshToken == null) return false;

      // Create a new Dio instance without interceptors to avoid infinite loop
      final dioWithoutInterceptors = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
          receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final response = await dioWithoutInterceptors.post(
        '${AppConfig.authEndpoint}/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Extract tokens from response
        // API might return tokens directly or nested in a 'data' field
        final accessToken = data['accessToken'] ?? data['data']?['accessToken'];
        final newRefreshToken = data['refreshToken'] ?? data['data']?['refreshToken'] ?? refreshToken;
        
        if (accessToken != null) {
          await _tokenStorage?.saveTokens(accessToken, newRefreshToken);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      // If refresh token is invalid (401), return false
      if (e.response?.statusCode == 401) {
        return false;
      }
      // For other errors (network, etc.), return false
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // Clean identifier if it looks like a phone number (contains only digits or starts with +)
      final identifier = _isPhoneNumber(email) 
          ? PhoneValidator.cleanPhoneNumber(email)
          : email;
      
      final response = await _dio.post(
        '${AppConfig.authEndpoint}/login',
        data: {
          'identifier': identifier, // V2 API accepts email or phone as identifier
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
               // Save tokens
               await _tokenStorage?.saveTokens(
                 data['accessToken'],
                 data['refreshToken'],
               );
               await _tokenStorage?.setLoggedIn(true);

               // Parse user data
               final userData = data['user'];
               final user = _parseUserFromResponse(userData);
               
               // Cache user data
               await _tokenStorage?.saveUserData(user);
               
               _currentUser = user;
               _authController.add(user);
               return user;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Authentication failed. Please try again.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Invalid email or password.';
        } else if (statusCode == 404) {
          errorMessage = 'User not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      _authController.addError(Exception(errorMessage));
      throw Exception(errorMessage);
    } catch (e) {
      _authController.addError(e);
      rethrow;
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.authEndpoint}/register',
        data: {
          'email': email,
          'phoneNumber': phoneNumber != null ? PhoneValidator.cleanPhoneNumber(phoneNumber) : null,
          'password': password,
          'fullName': fullName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
               // Save tokens
               await _tokenStorage?.saveTokens(
                 data['accessToken'],
                 data['refreshToken'],
               );
               await _tokenStorage?.setLoggedIn(true);

               // Parse user data
               final userData = data['user'];
               final user = _parseUserFromResponse(userData);
               
               // Cache user data
               await _tokenStorage?.saveUserData(user);
               
               _currentUser = user;
               _authController.add(user);
               return user;
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Registration failed. Please try again.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 409) {
          errorMessage = 'User with this email or phone already exists.';
        } else if (statusCode == 400) {
          errorMessage = message ?? 'Invalid registration data.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      _authController.addError(Exception(errorMessage));
      throw Exception(errorMessage);
    } catch (e) {
      _authController.addError(e);
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get('${AppConfig.authEndpoint}/profile');

      if (response.statusCode == 200) {
        // Extract user data from response (might be nested in 'data' field)
        final userData = response.data is Map && response.data['data'] != null
            ? response.data['data']
            : response.data;
        
        final user = _parseUserFromResponse(userData);
        
        // Cache updated user data
        await _tokenStorage?.saveUserData(user);
        await _tokenStorage?.setLoggedIn(true);
        
        _currentUser = user;
        _authController.add(user);
        return user;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired or invalid - try to refresh
        final refreshed = await _refreshToken();
        if (!refreshed) {
          // Refresh failed - session expired, logout
          await signOut();
        }
        // If refresh succeeded, don't return null - let caller retry
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
        notificationsEnabled: data['notificationPreferences'] != null && 
                             data['notificationPreferences'] is Map
            ? (data['notificationPreferences']['push'] ?? 
               data['notificationPreferences']['email'] ?? true)
            : data['preferences']?['notificationsEnabled'] ?? true,
        locationEnabled: data['isPrivate'] != null 
            ? !(data['isPrivate'] as bool)
            : data['preferences']?['locationEnabled'] ?? true,
        interests: data['interests'] != null && data['interests'] is List
            ? List<String>.from(data['interests'])
            : data['preferences']?['interests'] != null && 
              data['preferences']['interests'] is List
                ? List<String>.from(data['preferences']['interests'])
                : [],
      ),
    );
  }

  Future<void> signOut() async {
    await _tokenStorage?.clearTokens();
    await _tokenStorage?.clearUserData();
    _currentUser = null;
    _authController.add(null);
  }

  /// Check if user has a valid session (has tokens)
  Future<bool> hasValidSession() async {
    try {
      _tokenStorage ??= await TokenStorageService.getInstance();
      final accessToken = await _tokenStorage?.getAccessToken();
      final refreshToken = await _tokenStorage?.getRefreshToken();
      final isLoggedIn = await _tokenStorage?.isLoggedIn() ?? false;
      
      // User has valid session if they have both tokens and isLoggedIn flag is true
      return isLoggedIn && accessToken != null && refreshToken != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if a string is likely a phone number (contains only digits or starts with +)
  bool _isPhoneNumber(String value) {
    // Remove all non-digit characters except +
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
    // If it contains only digits (with optional + at start), it's likely a phone number
    return RegExp(r'^\+?\d+$').hasMatch(cleaned) && cleaned.length >= 7;
  }

  Future<void> dispose() async {
    await _authController.close();
  }
}
