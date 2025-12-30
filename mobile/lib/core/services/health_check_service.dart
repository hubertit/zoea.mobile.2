import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Service to check backend API health status
class HealthCheckService {
  // TODO: Change back to '/health' after testing
  static const String _healthEndpoint = '/healthx'; // Using wrong endpoint for testing
  static const Duration _timeout = Duration(seconds: 5);

  /// Check if the backend API is available
  /// Returns true if API is healthy, false otherwise
  static Future<bool> checkHealth() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: _timeout,
          receiveTimeout: _timeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            // Only consider 200-299 as success
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

      final response = await dio.get(_healthEndpoint);
      
      // Check if we got a successful response with status 'ok'
      if (response.statusCode != null && 
          response.statusCode! >= 200 && 
          response.statusCode! < 300) {
        // Verify the response has the expected structure
        final data = response.data;
        if (data is Map && data['status'] == 'ok') {
          return true;
        }
        // If status is ok but structure is different, still consider healthy
        return true;
      }
      
      return false;
    } on DioException catch (e) {
      // Handle Dio-specific errors
      // Connection errors, timeouts, 404s, etc. all mean API is not available
      return false;
    } catch (e) {
      // Any other error means API is not available
      return false;
    }
  }

  /// Check health with retry logic
  /// [maxRetries] - Maximum number of retry attempts (default: 2)
  /// [retryDelay] - Delay between retries (default: 1 second)
  static Future<bool> checkHealthWithRetry({
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i <= maxRetries; i++) {
      final isHealthy = await checkHealth();
      if (isHealthy) {
        return true;
      }
      
      // Wait before retry (except on last attempt)
      if (i < maxRetries) {
        await Future.delayed(retryDelay);
      }
    }
    
    return false;
  }
}

