import 'package:dio/dio.dart';
import '../config/app_config.dart';

class AssistantService {
  /// Get authenticated Dio instance for API calls
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Send a chat message
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? conversationId,
    Map<String, double>? location,
  }) async {
    try {
      final dio = await _getDio();
      
      final response = await dio.post(
        '/assistant/chat',
        data: {
          'message': message,
          if (conversationId != null) 'conversationId': conversationId,
          if (location != null) 'location': {
            'lat': location['lat'],
            'lng': location['lng'],
          },
        },
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final dio = await _getDio();
      
      final response = await dio.get('/assistant/conversations');

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get messages for a conversation
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final dio = await _getDio();
      
      final response = await dio.get('/assistant/conversations/$conversationId/messages');

      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final dio = await _getDio();
      
      await dio.delete('/assistant/conversations/$conversationId');
    } catch (e) {
      rethrow;
    }
  }
}

