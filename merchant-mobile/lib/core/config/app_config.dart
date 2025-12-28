import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Zoea Merchant';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'https://api.zoea.africa/v1';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String merchantsEndpoint = '/merchants';
  static const String listingsEndpoint = '/listings';
  static const String bookingsEndpoint = '/bookings';
  static const String analyticsEndpoint = '/analytics';
  static const String transactionsEndpoint = '/transactions';
  static const String notificationsEndpoint = '/notifications';
  static const String uploadEndpoint = '/upload';

  // Cache Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String merchantDataKey = 'merchant_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String lastSyncKey = 'last_sync';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const List<String> allowedImageTypes = [
    'image/jpeg', 
    'image/png', 
    'image/webp',
    'image/gif'
  ];

  // Animation Durations
  static const int splashDuration = 2000; // 2 seconds
  static const int pageTransitionDuration = 300; // 300 milliseconds
  static const int cardAnimationDuration = 200; // 200 milliseconds

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registrationSuccessMessage = 'Account created successfully!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';

  // Payment Configuration
  static const String paymentGateway = 'ZoeaPay';
  static const String currency = 'RWF';
  static const String currencySymbol = 'Frw';
  static const double minPaymentAmount = 100.0;
  static const double maxPaymentAmount = 1000000.0; // 1M RWF

  // Support
  static const String supportEmail = 'merchant-support@zoea.africa';
  static const String supportPhone = '+250788123456';

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
}

