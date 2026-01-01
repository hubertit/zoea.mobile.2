import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/token_storage_service.dart';

class AppConfig {
  static const String appName = 'Zoea Africa';
  static const String appVersion = '2.0.0';
  static const String apiBaseUrl = 'https://zoea-africa.qtsoftwareltd.com/api';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String listingsEndpoint = '/listings';
  static const String hotelsEndpoint = '/hotels';
  static const String restaurantsEndpoint = '/restaurants';
  static const String toursEndpoint = '/tours';
  static const String eventsEndpoint = '/events';
  static const String bookingsEndpoint = '/bookings';
  static const String zoeaCardEndpoint = '/zoea-card';
  static const String transactionsEndpoint = '/transactions';
  static const String notificationsEndpoint = '/notifications';
  static const String searchEndpoint = '/search';
  static const String recommendationsEndpoint = '/recommendations';
  static const String reviewsEndpoint = '/reviews';
  static const String favoritesEndpoint = '/favorites';
  static const String uploadEndpoint = '/upload';
  static const String analyticsEndpoint = '/analytics';
  static const String productsEndpoint = '/products';
  static const String servicesEndpoint = '/services';
  static const String menusEndpoint = '/menus';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';

  // Cache Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String userFullDataKey = 'user_full_data';
  static const String userCredentialsKey = 'user_credentials';
  static const String isLoggedInKey = 'is_logged_in';
  static const String lastSyncKey = 'last_sync';
  static const String zoeaCardDataKey = 'zoea_card_data';
  static const String favoritesKey = 'favorites';
  static const String searchHistoryKey = 'search_history';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Map Configuration (Rwanda coordinates)
  static const double defaultMapZoom = 12.0;
  static const double defaultMapLatitude = -1.9403; // Kigali coordinates
  static const double defaultMapLongitude = 30.0644;
  static const double maxSearchRadius = 50.0; // 50km radius

  // File Upload
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const List<String> allowedImageTypes = [
    'image/jpeg', 
    'image/png', 
    'image/webp',
    'image/gif'
  ];
  static const List<String> allowedVideoTypes = [
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo'
  ];

  // Notifications
  static const int maxNotificationAge = 30 * 24 * 60 * 60; // 30 days in seconds
  static const int notificationBatchSize = 50;

  // QR Code
  static const int qrCodeSize = 200;
  static const int qrCodeErrorCorrectionLevel = 3;

  // Animation Durations
  static const int splashDuration = 2000; // 2 seconds
  static const int pageTransitionDuration = 300; // 300 milliseconds
  static const int cardAnimationDuration = 200; // 200 milliseconds

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String locationErrorMessage = 'Location access is required for this feature.';
  static const String paymentErrorMessage = 'Payment failed. Please try again.';

  // Success Messages
  static const String bookingSuccessMessage = 'Booking confirmed successfully!';
  static const String paymentSuccessMessage = 'Payment completed successfully!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String favoriteAddedMessage = 'Added to favorites!';
  static const String favoriteRemovedMessage = 'Removed from favorites!';

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableSocialLogin = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDarkMode = true;
  static const bool enableARFeatures = false; // Future feature

  // Payment Configuration
  static const String paymentGateway = 'ZoeaPay';
  static const String currency = 'RWF';
  static const String currencySymbol = 'Frw';
  static const double minPaymentAmount = 100.0;
  static const double maxPaymentAmount = 1000000.0; // 1M RWF

  // Visit Rwanda Integration
  static const String visitRwandaApiUrl = 'https://api.visitrwanda.gov.rw/v1';
  static const String rdbApiUrl = 'https://api.rdb.rw/v1';
  static const bool enableRDBIntegration = true;

  // Social Media
  static const String facebookUrl = 'https://facebook.com/zoeaafrica';
  static const String twitterUrl = 'https://twitter.com/zoeaafrica';
  static const String instagramUrl = 'https://instagram.com/zoeaafrica';
  static const String linkedinUrl = 'https://linkedin.com/company/zoeaafrica';

  // Support
  static const String supportEmail = 'support@zoea.africa';
  static const String supportPhone = '+250788123456';
  static const String supportWhatsapp = '+250788123456';

  // AI Assistant Configuration
  static const String aiAssistantName = 'Zoea Assistant';
  static const String aiModelVersion = 'gpt-4';
  static const int maxChatHistory = 50;
  static const int aiResponseTimeout = 30000; // 30 seconds

  static Dio dioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(milliseconds: connectionTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': '$appName/$appVersion',
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    return dio;
  }

  /// Create an authenticated Dio instance with token interceptor
  /// This should be used by services that need authentication
  static Future<Dio> authenticatedDioInstance() async {
    final dio = dioInstance();
    final tokenStorage = await TokenStorageService.getInstance();
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors - token expired
          if (error.response?.statusCode == 401) {
            // Skip refresh if this is already a refresh token request
            if (error.requestOptions.path.contains('/refresh') || 
                error.requestOptions.path.contains('/auth')) {
              handler.next(error);
              return;
            }
            
            // Try to refresh token
            final refreshToken = await tokenStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                // Create a new Dio instance without interceptors to avoid infinite loop
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: apiBaseUrl,
                    connectTimeout: const Duration(milliseconds: connectionTimeout),
                    receiveTimeout: const Duration(milliseconds: receiveTimeout),
                    headers: {
                      'Accept': 'application/json',
                      'Content-Type': 'application/json',
                    },
                  ),
                );
                
                final refreshResponse = await refreshDio.post(
                  '$authEndpoint/refresh',
                  data: {'refreshToken': refreshToken},
                );
                
                if (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201) {
                  final data = refreshResponse.data;
                  final newAccessToken = data['accessToken'] ?? data['data']?['accessToken'];
                  final newRefreshToken = data['refreshToken'] ?? data['data']?['refreshToken'] ?? refreshToken;
                  
                  if (newAccessToken != null) {
                    await tokenStorage.saveTokens(newAccessToken, newRefreshToken);
                    
                    // Retry the original request with new token
                    final opts = error.requestOptions;
                    opts.headers['Authorization'] = 'Bearer $newAccessToken';
                    try {
                      final response = await dio.fetch(opts);
                      handler.resolve(response);
                      return;
                    } catch (e) {
                      // Retry failed even after refresh
                      handler.next(error);
                      return;
                    }
                  }
                }
              } catch (e) {
                // Refresh failed - pass the error
                handler.next(error);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );
    
    return dio;
  }

  // Helper method to create Dio instance without token interceptor
  // (for use in AuthService where we add token interceptor manually)
  static Dio dioInstanceWithoutInterceptors() {
    return dioInstance();
  }
}
