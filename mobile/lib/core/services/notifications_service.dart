import 'package:dio/dio.dart';
import '../config/app_config.dart';

class NotificationsService {
  /// Get authenticated Dio instance for API calls
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Get user notifications with filters
  /// Returns: {data: [...], meta: {total, page, limit, unreadCount}}
  Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? limit,
    bool? unreadOnly,
  }) async {
    try {
      final dio = await _getDio();
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;

      final response = await dio.get(
        AppConfig.notificationsEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch notifications.';
      
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
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Get unread notification count
  /// Returns: {count: number}
  Future<int> getUnreadCount() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('${AppConfig.notificationsEndpoint}/unread-count');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API returns: {count: number}
        return (data['count'] as num?)?.toInt() ?? 0;
      } else {
        throw Exception('Failed to fetch unread count: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch unread count.';
      
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
      throw Exception('Error fetching unread count: $e');
    }
  }

  /// Mark a notification as read
  /// Returns: Updated notification object
  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      final dio = await _getDio();
      final response = await dio.post('${AppConfig.notificationsEndpoint}/$id/read');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to mark notification as read: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to mark notification as read.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Notification not found.';
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
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  /// Returns: {success: true}
  Future<void> markAllAsRead() async {
    try {
      final dio = await _getDio();
      final response = await dio.post('${AppConfig.notificationsEndpoint}/read-all');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to mark all notifications as read: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to mark all notifications as read.';
      
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
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  /// Returns: {success: true}
  Future<void> deleteNotification(String id) async {
    try {
      final dio = await _getDio();
      final response = await dio.delete('${AppConfig.notificationsEndpoint}/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete notification: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete notification.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Notification not found.';
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
      throw Exception('Error deleting notification: $e');
    }
  }

  /// Delete all notifications
  /// Returns: {success: true}
  Future<void> deleteAllNotifications() async {
    try {
      final dio = await _getDio();
      final response = await dio.delete(AppConfig.notificationsEndpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete all notifications: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to delete all notifications.';
      
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
      throw Exception('Error deleting all notifications: $e');
    }
  }
}

