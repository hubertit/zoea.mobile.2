import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/providers/country_provider.dart';

class AskZoeaScreen extends ConsumerStatefulWidget {
  const AskZoeaScreen({super.key});

  @override
  ConsumerState<AskZoeaScreen> createState() => _AskZoeaScreenState();
}

class _AskZoeaScreenState extends ConsumerState<AskZoeaScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  String? _currentConversationId;
  bool _isLoading = false;
  List<String> _suggestions = [
    'Show me popular places',
    'Find restaurants in Kigali',
    'What tours are available?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// Clean markdown text by removing image syntax since we show images as cards
  String _cleanMarkdownText(String text) {
    // Remove image markdown: ![alt](url)
    String cleaned = text.replaceAll(RegExp(r'!\[([^\]]*)\]\([^\)]+\)'), '');
    
    // Remove multiple consecutive newlines
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Trim whitespace
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = {
      'role': 'user',
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final service = ref.read(assistantServiceProvider);
      final selectedCountry = ref.read(selectedCountryProvider).value;
      
      final response = await service.sendMessage(
        message: text,
        conversationId: _currentConversationId,
        countryCode: selectedCountry?.code2,
      );

      // Update conversation ID if new
      _currentConversationId ??= response['conversationId'] as String?;

      // Add assistant message
      final assistantMessage = response['assistantMessage'] as Map<String, dynamic>?;
      final cards = response['cards'] as List?;
      final suggestions = response['suggestions'] as List?;

      if (assistantMessage != null) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': assistantMessage['text'],
            'cards': cards ?? [],
            'createdAt': assistantMessage['createdAt'],
          });
          
          if (suggestions != null && suggestions.isNotEmpty) {
            _suggestions = suggestions.cast<String>();
          }
        });

        _scrollToBottom();
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startNewConversation() {
    setState(() {
      _currentConversationId = null;
      _messages.clear();
      _suggestions = [
        'Show me popular places',
        'Find restaurants in Kigali',
        'What tours are available?',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.grey50,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy,
                  color: context.primaryColorTheme,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask Zoea',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                Text(
                  'Your Rwanda guide',
                  style: context.bodySmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startNewConversation,
              tooltip: 'New conversation',
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show conversations history
              _showConversationsHistory();
            },
            tooltip: 'History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),

          // Suggestions
          if (_suggestions.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(suggestion),
                        onPressed: () => _sendMessage(suggestion),
                        backgroundColor: context.backgroundColor,
                        side: BorderSide(color: context.dividerColor),
                        labelStyle: context.bodySmall.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about Rwanda...',
                        hintStyle: context.bodyMedium.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        filled: true,
                        fillColor: context.grey50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: context.primaryColorTheme,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading
                          ? null
                          : () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy,
                  size: 50,
                  color: context.primaryColorTheme,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hi! I\'m Zoea 👋',
              style: context.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your friendly guide to Rwanda. Ask me about places to visit, restaurants, tours, or anything else!',
              textAlign: TextAlign.center,
              style: context.bodyLarge.copyWith(
                color: context.secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Try asking:',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            ..._suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => _sendMessage(suggestion),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.dividerColor),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  suggestion,
                  style: context.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['role'] == 'user';
    final text = message['text'] as String;
    final cards = message['cards'] as List? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.smart_toy,
                  color: context.primaryColorTheme,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Chat bubble tail
                    Positioned(
                      bottom: 0,
                      left: isUser ? null : -6,
                      right: isUser ? -6 : null,
                      child: CustomPaint(
                        size: const Size(20, 20),
                        painter: _ChatBubbleTailPainter(
                          color: isUser
                              ? (context.isDarkMode 
                                  ? const Color(0xFF2B5278)  // Match darker blue
                                  : context.primaryColorTheme)
                              : context.cardColor,
                          isUser: isUser,
                        ),
                      ),
                    ),
                    // Chat bubble content
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? (context.isDarkMode 
                                ? const Color(0xFF2B5278)  // Darker blue for dark mode
                                : context.primaryColorTheme)
                            : context.cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 3),
                          bottomRight: Radius.circular(isUser ? 3 : 18),
                        ),
                      ),
                  child: isUser
                      ? Text(
                          text,
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: _cleanMarkdownText(text),
                          styleSheet: MarkdownStyleSheet(
                            p: context.bodyMedium.copyWith(
                              color: context.primaryTextColor,
                              height: 1.4,
                            ),
                            strong: context.bodyMedium.copyWith(
                              color: context.primaryTextColor,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                            em: context.bodyMedium.copyWith(
                              color: context.primaryTextColor,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            listBullet: context.bodyMedium.copyWith(
                              color: context.primaryTextColor,
                            ),
                            code: context.bodySmall.copyWith(
                              color: context.primaryTextColor,
                              backgroundColor: context.dividerColor,
                              fontFamily: 'monospace',
                            ),
                            h1: context.titleLarge.copyWith(
                              color: context.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: context.titleMedium.copyWith(
                              color: context.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: context.bodyLarge.copyWith(
                              color: context.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                            blockquote: context.bodyMedium.copyWith(
                              color: context.secondaryTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                            a: context.bodyMedium.copyWith(
                              color: context.primaryColorTheme,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          selectable: true,
                        ),
                    ),
                  ],
                ),
                
                // Cards
                if (cards.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...cards.map((card) => _buildCard(card)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> card) {
    final type = card['type'] as String;
    final title = card['title'] as String;
    final subtitle = card['subtitle'] as String?;
    final imageUrl = card['imageUrl'] as String?;
    final route = card['route'] as String;
    final params = card['params'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Navigate based on route
          final id = params['id'] as String;
          context.push(route.replaceAll(':id', id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
          ),
          child: Row(
            children: [
              // Image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: context.dividerColor,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: context.dividerColor,
                      child: Icon(
                        _getIconForType(type),
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: context.primaryColorTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForType(type),
                    color: context.primaryColorTheme,
                  ),
                ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: context.bodySmall.copyWith(
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              Icon(
                Icons.chevron_right,
                color: context.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primaryColorTheme.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.smart_toy,
                color: context.primaryColorTheme,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              // Chat bubble tail
              Positioned(
                bottom: 0,
                left: -6,
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: _ChatBubbleTailPainter(
                    color: context.cardColor,
                    isUser: false,
                  ),
                ),
              ),
              // Typing indicator bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(1),
                    const SizedBox(width: 4),
                    _buildDot(2),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        final opacity = (animValue * 2).clamp(0.3, 1.0);
        
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: context.secondaryTextColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'listing':
        return Icons.place;
      case 'tour':
        return Icons.tour;
      case 'product':
        return Icons.shopping_bag;
      case 'service':
        return Icons.room_service;
      default:
        return Icons.info;
    }
  }

  Future<void> _showConversationsHistory() async {
    // Refresh conversations before showing
    ref.invalidate(conversationsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: context.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final conversationsAsync = ref.watch(conversationsProvider);
            
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Conversations',
                    style: context.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: conversationsAsync.when(
                      data: (conversations) {
                        if (conversations.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No conversations yet',
                                style: context.bodyMedium.copyWith(
                                  color: context.secondaryTextColor,
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conv = conversations[index];
                            return ListTile(
                              leading: Icon(
                                Icons.chat_bubble_outline,
                                color: context.primaryColorTheme,
                              ),
                              title: Text(
                                conv['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.primaryTextColor,
                                ),
                              ),
                              subtitle: Text(
                                _formatDate(conv['lastMessageAt'] as String),
                                style: context.bodySmall.copyWith(
                                  color: context.secondaryTextColor,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: context.secondaryTextColor,
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await _loadConversation(conv['id'] as String);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: context.errorColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load conversations',
                                style: context.bodyMedium.copyWith(
                                  color: context.errorColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: context.bodySmall.copyWith(
                                  color: context.secondaryTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Future<void> _loadConversation(String conversationId) async {
    setState(() {
      _isLoading = true;
      _currentConversationId = conversationId;
      _messages.clear();
    });

    try {
      final service = ref.read(assistantServiceProvider);
      final messages = await service.getMessages(conversationId);

      setState(() {
        _messages.addAll(messages.map((msg) {
          return {
            'role': msg['role'],
            'text': msg['text'],
            'cards': msg['cards'] ?? [],
            'createdAt': msg['createdAt'],
          };
        }));
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load conversation: ${e.toString()}'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Custom painter for iMessage-style chat bubble tail
class _ChatBubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isUser;

  _ChatBubbleTailPainter({
    required this.color,
    required this.isUser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isUser) {
      // iMessage-style tail pointing to the right
      path.moveTo(0, 0);
      path.lineTo(size.width - 2, 0);
      path.quadraticBezierTo(
        size.width - 1,
        size.height * 0.5,
        size.width,
        size.height,
      );
      path.quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.8,
        0,
        size.height * 0.2,
      );
      path.close();
    } else {
      // iMessage-style tail pointing to the left
      path.moveTo(size.width, 0);
      path.lineTo(2, 0);
      path.quadraticBezierTo(
        1,
        size.height * 0.5,
        0,
        size.height,
      );
      path.quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.8,
        size.width,
        size.height * 0.2,
      );
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

