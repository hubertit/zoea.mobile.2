import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../config/app_config.dart';

/// Service for passive data collection (searches, views, interactions)
/// Respects user consent and batches data for efficient upload
class AnalyticsService {
  static const String _analyticsQueueKey = 'analytics_queue';
  static const String _analyticsConsentKey = 'analytics_consent';
  static const int _maxBatchSize = 50; // Max events per batch

  Dio? _dio;
  
  /// Get authenticated Dio instance
  Future<Dio> _getDio() async {
    _dio ??= await AppConfig.authenticatedDioInstance();
    return _dio!;
  }

  /// Check if analytics consent is given
  Future<bool> hasConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_analyticsConsentKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set analytics consent
  Future<void> setConsent(bool consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_analyticsConsentKey, consent);
      
      // If consent revoked, clear queue
      if (!consent) {
        await clearQueue();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Track a search query
  Future<void> trackSearch({
    required String query,
    String? category,
  }) async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'search',
      data: {
        'query': query,
        if (category != null) 'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track a listing view
  Future<void> trackListingView({
    required String listingId,
    String? category,
    String? categorySlug,
  }) async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'listing_view',
      data: {
        'listingId': listingId,
        if (category != null) 'category': category,
        if (categorySlug != null) 'categorySlug': categorySlug,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track an event view
  Future<void> trackEventView({
    required String eventId,
    String? eventType,
  }) async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'event_view',
      data: {
        'eventId': eventId,
        if (eventType != null) 'eventType': eventType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track navigation usage (zones only, aggregated)
  Future<void> trackNavigation({
    required String zone, // e.g., "Kigali", "Musanze", etc.
  }) async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'navigation',
      data: {
        'zone': zone,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track app usage (session start)
  Future<void> trackSessionStart() async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'session_start',
      data: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track booking attempt
  Future<void> trackBookingAttempt({
    required String listingId,
    String? listingType,
  }) async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'booking_attempt',
      data: {
        'listingId': listingId,
        if (listingType != null) 'listingType': listingType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track booking completion
  Future<void> trackBookingCompletion({
    required String bookingId,
    required String listingId,
  }) async {
    if (!await hasConsent()) return;

    await _addEvent(
      type: 'booking_completion',
      data: {
        'bookingId': bookingId,
        'listingId': listingId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Add an event to the queue
  Future<void> _addEvent({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_analyticsQueueKey);
      final queue = queueJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(queueJson))
          : <Map<String, dynamic>>[];

      queue.add({
        'type': type,
        'data': data,
      });

      // Limit queue size
      if (queue.length > _maxBatchSize * 2) {
        queue.removeRange(0, queue.length - _maxBatchSize);
      }

      await prefs.setString(_analyticsQueueKey, jsonEncode(queue));

      // Try to upload if queue is large enough
      if (queue.length >= _maxBatchSize) {
        await uploadBatch();
      }
    } catch (e) {
      // Silently fail - analytics should never break the app
    }
  }

  /// Upload batched events to the server
  Future<void> uploadBatch() async {
    if (!await hasConsent()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_analyticsQueueKey);
      if (queueJson == null || queueJson.isEmpty) return;

      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      if (queue.isEmpty) return;

      // Take up to maxBatchSize events
      final batch = queue.length > _maxBatchSize
          ? queue.sublist(0, _maxBatchSize)
          : queue;

      // Get device info for analytics
      final deviceInfo = await _getDeviceInfo();
      
      // Get authenticated Dio instance
      final dio = await _getDio();
      
      // Upload to server
      final response = await dio.post(
        '${AppConfig.analyticsEndpoint}/events',
        data: {
          'events': batch,
          'sessionId': deviceInfo['sessionId'],
          'deviceType': deviceInfo['deviceType'],
          'os': deviceInfo['os'],
          'browser': deviceInfo['browser'],
          'appVersion': deviceInfo['appVersion'],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove uploaded events from queue
        final remaining = queue.length > _maxBatchSize
            ? queue.sublist(_maxBatchSize)
            : <Map<String, dynamic>>[];

        await prefs.setString(_analyticsQueueKey, jsonEncode(remaining));
      }
    } catch (e) {
      // Silently fail - will retry on next batch
    }
  }

  /// Clear the analytics queue
  Future<void> clearQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_analyticsQueueKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Get queue size (for debugging)
  Future<int> getQueueSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_analyticsQueueKey);
      if (queueJson == null || queueJson.isEmpty) return 0;

      final queue = List<Map<String, dynamic>>.from(jsonDecode(queueJson));
      return queue.length;
    } catch (e) {
      return 0;
    }
  }

  /// Force upload (call periodically or on app close)
  Future<void> forceUpload() async {
    await uploadBatch();
  }

  /// Get device information for analytics
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceType = 'unknown';
      String os = 'unknown';
      String browser = 'mobile_app';
      String appVersion = AppConfig.appVersion;
      String sessionId = await _getOrCreateSessionId();

      if (Platform.isAndroid) {
        deviceType = 'android';
        final androidInfo = await deviceInfo.androidInfo;
        os = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        deviceType = 'ios';
        final iosInfo = await deviceInfo.iosInfo;
        os = 'iOS ${iosInfo.systemVersion}';
      }

      return {
        'sessionId': sessionId,
        'deviceType': deviceType,
        'os': os,
        'browser': browser,
        'appVersion': appVersion,
      };
    } catch (e) {
      // Return defaults if device info fails
      return {
        'sessionId': await _getOrCreateSessionId(),
        'deviceType': 'unknown',
        'os': 'unknown',
        'browser': 'mobile_app',
        'appVersion': AppConfig.appVersion,
      };
    }
  }

  /// Get or create a session ID
  Future<String> _getOrCreateSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const sessionIdKey = 'analytics_session_id';
      const sessionTimestampKey = 'analytics_session_timestamp';
      
      // Check if we have a valid session (less than 30 minutes old)
      final existingSessionId = prefs.getString(sessionIdKey);
      final sessionTimestamp = prefs.getInt(sessionTimestampKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const sessionTimeout = 30 * 60 * 1000; // 30 minutes

      if (existingSessionId != null && 
          (now - sessionTimestamp) < sessionTimeout) {
        return existingSessionId;
      }

      // Create new session ID
      final newSessionId = '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
      await prefs.setString(sessionIdKey, newSessionId);
      await prefs.setInt(sessionTimestampKey, now);
      
      return newSessionId;
    } catch (e) {
      // Fallback to timestamp-based session ID
      return '${DateTime.now().millisecondsSinceEpoch}_fallback';
    }
  }

  /// Generate a random string for session ID
  String _generateRandomString(int length) {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(length, '0');
  }

  /// Get my content views (places visited)
  /// Returns paginated list of listings/events viewed by the user
  Future<Map<String, dynamic>> getMyContentViews({
    int? page,
    int? limit,
    String? contentType, // 'listing' or 'event'
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (contentType != null) queryParams['contentType'] = contentType;

      final dio = await _getDio();
      final response = await dio.get(
        '${AppConfig.analyticsEndpoint}/my-content-views',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch content views: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch content views.';
      
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
      throw Exception('Error fetching content views: $e');
    }
  }
}

