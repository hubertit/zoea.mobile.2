import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'About',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left, size: 32),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Info
            _buildAppHeader(),
            const SizedBox(height: 32),
            
            // App Information
            _buildAppInformation(),
            const SizedBox(height: 24),
            
            // Features
            _buildFeatures(),
            const SizedBox(height: 24),
            
            // Team
            _buildTeam(),
            const SizedBox(height: 24),
            
            // Legal
            _buildLegal(),
            const SizedBox(height: 24),
            
            // Social Links
            _buildSocialLinks(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Center(
      child: Column(
        children: [
          // App Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.explore,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // App Name
          Text(
            'Zoea',
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          
          // Tagline
          Text(
            'Discover Rwanda\'s Beauty',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Version 1.0.0',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoItem(
                icon: Icons.info_outline,
                title: 'App Version',
                value: '1.0.0',
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.build_outlined,
                title: 'Build Number',
                value: '100',
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.update_outlined,
                title: 'Last Updated',
                value: 'December 2024',
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.phone_android_outlined,
                title: 'Platform',
                value: 'Flutter',
              ),
              _buildDivider(),
              _buildInfoItem(
                icon: Icons.language_outlined,
                title: 'Language',
                value: 'English',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: AppTheme.dividerColor,
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                icon: Icons.event_outlined,
                title: 'Events & Bookings',
                subtitle: 'Discover and book amazing events',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.place_outlined,
                title: 'Places & Locations',
                subtitle: 'Explore Rwanda\'s beautiful places',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.reviews_outlined,
                title: 'Reviews & Ratings',
                subtitle: 'Share your experiences with others',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.favorite_outline,
                title: 'Favorites',
                subtitle: 'Save your favorite places and events',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.card_membership_outlined,
                title: 'Zoea Card',
                subtitle: 'Digital membership and rewards',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Team',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTeamMember(
                name: 'Development Team',
                role: 'Flutter & Backend Development',
                description: 'Building amazing experiences',
              ),
              _buildDivider(),
              _buildTeamMember(
                name: 'Design Team',
                role: 'UI/UX Design',
                description: 'Creating beautiful interfaces',
              ),
              _buildDivider(),
              _buildTeamMember(
                name: 'Content Team',
                role: 'Content & Localization',
                description: 'Curating Rwanda\'s best experiences',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.people_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLegalItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we protect your data',
                onTap: () => _showLegalDialog('Privacy Policy', _getPrivacyPolicy()),
              ),
              _buildDivider(),
              _buildLegalItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Terms and conditions',
                onTap: () => _showLegalDialog('Terms of Service', _getTermsOfService()),
              ),
              _buildDivider(),
              _buildLegalItem(
                icon: Icons.copyright_outlined,
                title: 'Copyright',
                subtitle: '© 2024 Zoea. All rights reserved.',
                onTap: () => _showLegalDialog('Copyright', _getCopyright()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalItem({
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
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect With Us',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSocialItem(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'contact@zoea.rw',
                onTap: () => _showContactDialog('Email', 'Send us an email at contact@zoea.rw'),
              ),
              _buildDivider(),
              _buildSocialItem(
                icon: Icons.phone_outlined,
                title: 'Phone',
                subtitle: '+250 788 123 456',
                onTap: () => _showContactDialog('Phone', 'Call us at +250 788 123 456'),
              ),
              _buildDivider(),
              _buildSocialItem(
                icon: Icons.language_outlined,
                title: 'Website',
                subtitle: 'www.zoea.rw',
                onTap: () => _showContactDialog('Website', 'Visit our website at www.zoea.rw'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialItem({
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
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTheme.titleMedium),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTheme.titleMedium),
        content: Text(content, style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement contact action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title feature coming soon'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: Text(
              'Contact',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrivacyPolicy() {
    return '''
Privacy Policy

Last updated: December 2024

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, make a booking, or contact us for support.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Your Rights
You have the right to access, update, or delete your personal information. You can do this through your account settings or by contacting us.

6. Contact Us
If you have any questions about this Privacy Policy, please contact us at privacy@zoea.rw.
''';
  }

  String _getTermsOfService() {
    return '''
Terms of Service

Last updated: December 2024

1. Acceptance of Terms
By using our app, you agree to be bound by these Terms of Service.

2. Use of the App
You may use our app for lawful purposes only. You agree not to use the app in any way that could damage, disable, or impair the app.

3. User Accounts
You are responsible for maintaining the confidentiality of your account and password.

4. Bookings and Payments
All bookings are subject to availability. Payment terms are as specified at the time of booking.

5. Cancellation Policy
Cancellation policies vary by event and are specified at the time of booking.

6. Limitation of Liability
To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, or consequential damages.

7. Changes to Terms
We reserve the right to modify these terms at any time. We will notify users of any material changes.

8. Contact Information
For questions about these Terms of Service, contact us at legal@zoea.rw.
''';
  }

  String _getCopyright() {
    return '''
Copyright Notice

© 2024 Zoea. All rights reserved.

This app and its contents are protected by copyright and other intellectual property laws.

You may not:
- Copy, modify, or distribute the app without permission
- Reverse engineer or attempt to extract source code
- Use the app for commercial purposes without authorization

For licensing inquiries, contact us at legal@zoea.rw.
''';
  }
}
