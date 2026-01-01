import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Help Center',
          style: AppTheme.titleLarge.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),
            
            // Quick Help
            _buildQuickHelp(),
            const SizedBox(height: 24),
            
            // Popular Topics
            _buildPopularTopics(),
            const SizedBox(height: 24),
            
            // Contact Support
            _buildContactSupport(),
            const SizedBox(height: 24),
            
            // FAQ Categories
            _buildFAQCategories(),
            const SizedBox(height: 24),
            
            // App Information
            _buildAppInformation(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? context.dividerColor.withOpacity(0.3) : context.dividerColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search help articles...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: context.secondaryTextColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: context.secondaryTextColor,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear,
                    color: context.secondaryTextColor,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.dividerColor,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildQuickHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Help',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode ? context.dividerColor.withOpacity(0.3) : context.dividerColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildQuickHelpItem(
                icon: Icons.account_circle_outlined,
                title: 'Account Issues',
                subtitle: 'Login, registration, and profile problems',
                onTap: () => _showHelpDialog('Account Issues', _getAccountHelpContent()),
              ),
              _buildDivider(),
              _buildQuickHelpItem(
                icon: Icons.payment_outlined,
                title: 'Payment & Billing',
                subtitle: 'Booking payments and refunds',
                onTap: () => _showHelpDialog('Payment & Billing', _getPaymentHelpContent()),
              ),
              _buildDivider(),
              _buildQuickHelpItem(
                icon: Icons.event_outlined,
                title: 'Events & Bookings',
                subtitle: 'Event tickets and booking management',
                onTap: () => _showHelpDialog('Events & Bookings', _getBookingHelpContent()),
              ),
              _buildDivider(),
              _buildQuickHelpItem(
                icon: Icons.place_outlined,
                title: 'Places & Locations',
                subtitle: 'Finding and visiting places',
                onTap: () => _showHelpDialog('Places & Locations', _getPlacesHelpContent()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: context.primaryColorTheme,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: context.dividerColor,
    );
  }

  Widget _buildPopularTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTopicChip('How to book events'),
            _buildTopicChip('Payment methods'),
            _buildTopicChip('Cancel booking'),
            _buildTopicChip('Update profile'),
            _buildTopicChip('Contact support'),
            _buildTopicChip('App features'),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicChip(String label) {
    return InkWell(
      onTap: () {
        // TODO: Search for topic
        _searchController.text = label;
        setState(() {});
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.primaryColorTheme.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.primaryColorTheme.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: context.primaryColorTheme,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContactSupport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Support',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode ? context.dividerColor.withOpacity(0.3) : context.dividerColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildContactItem(
                icon: Icons.chat_outlined,
                title: 'Live Chat',
                subtitle: 'Get instant help from our support team',
                onTap: () => _showContactDialog('Live Chat', 'Start a live chat session with our support team.'),
              ),
              _buildDivider(),
              _buildContactItem(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@zoea.rw',
                onTap: () => _showContactDialog('Email Support', 'Send us an email at support@zoea.rw and we\'ll get back to you within 24 hours.'),
              ),
              _buildDivider(),
              _buildContactItem(
                icon: Icons.phone_outlined,
                title: 'Phone Support',
                subtitle: '+250 788 123 456',
                onTap: () => _showContactDialog('Phone Support', 'Call us at +250 788 123 456 for immediate assistance.'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: context.successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode ? context.dividerColor.withOpacity(0.3) : context.dividerColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFAQItem(
                title: 'Getting Started',
                count: 5,
                onTap: () => _showFAQDialog('Getting Started', _getGettingStartedFAQs()),
              ),
              _buildDivider(),
              _buildFAQItem(
                title: 'Account & Profile',
                count: 8,
                onTap: () => _showFAQDialog('Account & Profile', _getAccountFAQs()),
              ),
              _buildDivider(),
              _buildFAQItem(
                title: 'Bookings & Events',
                count: 12,
                onTap: () => _showFAQDialog('Bookings & Events', _getBookingFAQs()),
              ),
              _buildDivider(),
              _buildFAQItem(
                title: 'Payment & Refunds',
                count: 6,
                onTap: () => _showFAQDialog('Payment & Refunds', _getPaymentFAQs()),
              ),
              _buildDivider(),
              _buildFAQItem(
                title: 'Technical Issues',
                count: 4,
                onTap: () => _showFAQDialog('Technical Issues', _getTechnicalFAQs()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem({
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                color: context.primaryColorTheme,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.primaryTextColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: AppTheme.labelSmall.copyWith(
                  color: context.primaryColorTheme,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: context.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Information',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.isDarkMode ? context.dividerColor.withOpacity(0.3) : context.dividerColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow('App Version', '1.0.0'),
              _buildInfoRow('Build Number', '100'),
              _buildInfoRow('Last Updated', 'December 2024'),
              _buildInfoRow('Platform', 'Flutter'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Close',
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Content
            Text(
              content,
              style: AppTheme.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: context.secondaryTextColor),
                    ),
                    child: Text(
                      'Close',
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement contact action
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$title feature coming soon',
                          style: AppTheme.bodyMedium.copyWith(
                            color: context.primaryTextColor,
                          ),
                        ),
                        backgroundColor: context.primaryColorTheme,
                      ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColorTheme,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Contact',
                      style: AppTheme.bodyMedium.copyWith(
                        color: context.primaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showFAQDialog(String title, List<Map<String, String>> faqs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // FAQ List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        faq['question']!,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.primaryTextColor,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            faq['answer']!,
                            style: AppTheme.bodyMedium.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColorTheme,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Close',
                  style: AppTheme.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  String _getAccountHelpContent() {
    return '''
Common account issues and solutions:

• Forgot Password: Use the "Forgot Password" link on the login screen
• Account Verification: Check your email for verification links
• Profile Updates: Go to Profile > Edit Profile to update your information
• Account Security: Enable two-factor authentication in Privacy & Security settings
• Data Privacy: Review your privacy settings in the app settings
''';
  }

  String _getPaymentHelpContent() {
    return '''
Payment and billing assistance:

• Payment Methods: Add credit cards, mobile money, or bank accounts
• Refund Requests: Contact support for booking cancellations and refunds
• Payment History: View all transactions in your profile
• Failed Payments: Check your payment method and try again
• Currency: All payments are processed in Rwandan Francs (RWF)
''';
  }

  String _getBookingHelpContent() {
    return '''
Event booking and management:

• Booking Events: Browse events and tap "Book Now" to reserve your spot
• Booking Confirmation: You'll receive email and app notifications
• Cancel Bookings: Go to My Bookings to cancel upcoming events
• Event Updates: Check the Events tab for latest information
• Group Bookings: Contact support for group reservations
''';
  }

  String _getPlacesHelpContent() {
    return '''
Places and location information:

• Finding Places: Use the search bar or browse categories
• Place Details: Tap on any place to see photos, reviews, and information
• Directions: Get directions using your preferred maps app
• Reviews: Share your experiences by writing reviews
• Favorites: Save places you want to visit later
''';
  }

  List<Map<String, String>> _getGettingStartedFAQs() {
    return [
      {
        'question': 'How do I create an account?',
        'answer': 'Download the app and tap "Sign Up" to create your account with email or phone number.',
      },
      {
        'question': 'How do I book my first event?',
        'answer': 'Browse events in the Events tab, select an event, and tap "Book Now" to reserve your spot.',
      },
      {
        'question': 'How do I update my profile?',
        'answer': 'Go to Profile > Edit Profile to update your personal information.',
      },
      {
        'question': 'How do I find places to visit?',
        'answer': 'Use the Explore tab to discover places, or search for specific locations.',
      },
      {
        'question': 'How do I get help?',
        'answer': 'Use this Help Center, contact support, or check our FAQ section.',
      },
    ];
  }

  List<Map<String, String>> _getAccountFAQs() {
    return [
      {
        'question': 'How do I change my password?',
        'answer': 'Go to Profile > Privacy & Security > Change Password to update your password.',
      },
      {
        'question': 'How do I update my email?',
        'answer': 'Go to Profile > Edit Profile to update your email address.',
      },
      {
        'question': 'How do I delete my account?',
        'answer': 'Contact support to request account deletion. This action cannot be undone.',
      },
      {
        'question': 'How do I enable two-factor authentication?',
        'answer': 'Go to Profile > Privacy & Security to enable 2FA for added security.',
      },
      {
        'question': 'How do I update my profile picture?',
        'answer': 'Go to Profile > Edit Profile and tap on your profile picture to change it.',
      },
      {
        'question': 'How do I change my phone number?',
        'answer': 'Go to Profile > Edit Profile to update your phone number.',
      },
      {
        'question': 'How do I verify my account?',
        'answer': 'Check your email for verification links and follow the instructions.',
      },
      {
        'question': 'How do I download my data?',
        'answer': 'Go to Profile > Privacy & Security > Download Data to request your data.',
      },
    ];
  }

  List<Map<String, String>> _getBookingFAQs() {
    return [
      {
        'question': 'How do I book an event?',
        'answer': 'Browse events, select one, and tap "Book Now" to complete your booking.',
      },
      {
        'question': 'How do I cancel a booking?',
        'answer': 'Go to My Bookings, find your booking, and tap "Cancel Booking".',
      },
      {
        'question': 'How do I get my event tickets?',
        'answer': 'Your tickets will be sent via email and available in the app.',
      },
      {
        'question': 'Can I book for multiple people?',
        'answer': 'Yes, select the number of people when booking an event.',
      },
      {
        'question': 'How do I get a refund?',
        'answer': 'Contact support for refund requests. Refund policy varies by event.',
      },
      {
        'question': 'How do I reschedule a booking?',
        'answer': 'Cancel your current booking and book a new time slot.',
      },
      {
        'question': 'How do I check my booking status?',
        'answer': 'Go to My Bookings to see all your reservations and their status.',
      },
      {
        'question': 'What if an event is cancelled?',
        'answer': 'You\'ll be notified and can request a full refund or transfer to another event.',
      },
      {
        'question': 'How do I book a hotel?',
        'answer': 'Browse hotels in the Explore tab and follow the booking process.',
      },
      {
        'question': 'How do I book a tour?',
        'answer': 'Find tours in the Explore tab and book them like events.',
      },
      {
        'question': 'How do I get directions to an event?',
        'answer': 'Tap on the event location to open it in your maps app.',
      },
      {
        'question': 'How do I share an event?',
        'answer': 'Tap the share button on any event to share it with friends.',
      },
    ];
  }

  List<Map<String, String>> _getPaymentFAQs() {
    return [
      {
        'question': 'What payment methods are accepted?',
        'answer': 'We accept credit cards, mobile money, and bank transfers.',
      },
      {
        'question': 'How do I add a payment method?',
        'answer': 'Go to Profile > Payment Methods to add your preferred payment option.',
      },
      {
        'question': 'How do I get a refund?',
        'answer': 'Contact support with your booking details to request a refund.',
      },
      {
        'question': 'How long do refunds take?',
        'answer': 'Refunds typically take 3-5 business days to process.',
      },
      {
        'question': 'Is my payment information secure?',
        'answer': 'Yes, we use industry-standard encryption to protect your data.',
      },
      {
        'question': 'How do I update my payment method?',
        'answer': 'Go to Profile > Payment Methods to update your payment information.',
      },
    ];
  }

  List<Map<String, String>> _getTechnicalFAQs() {
    return [
      {
        'question': 'The app is not loading properly',
        'answer': 'Try closing and reopening the app, or restart your device.',
      },
      {
        'question': 'I can\'t log in to my account',
        'answer': 'Check your internet connection and verify your login credentials.',
      },
      {
        'question': 'The app crashes frequently',
        'answer': 'Update to the latest version of the app from your app store.',
      },
      {
        'question': 'I\'m not receiving notifications',
        'answer': 'Check your notification settings in your device settings and app settings.',
      },
    ];
  }
}
