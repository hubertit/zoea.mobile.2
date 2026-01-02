import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/assistant_service.dart';

// Provider for AssistantService
final assistantServiceProvider = Provider<AssistantService>((ref) {
  return AssistantService();
});

// Provider for conversations list
final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(assistantServiceProvider);
  return service.getConversations();
});

// Provider for messages in a conversation
final conversationMessagesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, conversationId) async {
    final service = ref.watch(assistantServiceProvider);
    return service.getMessages(conversationId);
  },
);

