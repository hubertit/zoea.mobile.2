import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  bool _locationEnabled = true;
  bool _notificationsEnabled = true;
  bool _dataSharingEnabled = false;
  bool _analyticsEnabled = true;
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Privacy & Security',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.primaryTextColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy Settings Section
          _buildSectionHeader('Privacy Settings'),
          const SizedBox(height: 16),
          _buildSwitchTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'Allow app to access your location for better recommendations',
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive notifications about events and updates',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.share,
            title: 'Data Sharing',
            subtitle: 'Share anonymous data to improve app experience',
            value: _dataSharingEnabled,
            onChanged: (value) {
              setState(() {
                _dataSharingEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.analytics,
            title: 'Analytics',
            subtitle: 'Help us improve the app with usage analytics',
            value: _analyticsEnabled,
            onChanged: (value) {
              setState(() {
                _analyticsEnabled = value;
              });
            },
          ),
          const SizedBox(height: 32),

          // Security Settings Section
          _buildSectionHeader('Security Settings'),
          const SizedBox(height: 16),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face recognition to unlock',
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
            },
          ),
          _buildSwitchTile(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security to your account',
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          _buildActionTile(
            icon: Icons.email,
            title: 'Email Verification',
            subtitle: 'Verify your email address',
            onTap: () {
              _showEmailVerificationDialog();
            },
          ),
          _buildActionTile(
            icon: Icons.phone,
            title: 'Phone Verification',
            subtitle: 'Add and verify your phone number',
            onTap: () {
              _showPhoneVerificationDialog();
            },
          ),
          const SizedBox(height: 32),

          // Account Management Section
          _buildSectionHeader('Account Management'),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.download,
            title: 'Download My Data',
            subtitle: 'Get a copy of your personal data',
            onTap: () {
              _showDownloadDataDialog();
            },
          ),
          _buildActionTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and all data',
            onTap: () {
              _showDeleteAccountDialog();
            },
            isDestructive: true,
          ),
          const SizedBox(height: 32),

          // Legal Section
          _buildSectionHeader('Legal'),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.description,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          _buildActionTile(
            icon: Icons.gavel,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryTextColor,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
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
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : AppTheme.primaryTextColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.secondaryTextColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'This feature will be available soon. You will be able to change your password securely.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
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

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Email Verification',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'A verification email will be sent to your registered email address.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Send verification email
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Verification email sent!',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Send Email',
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

  void _showPhoneVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Phone Verification',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'Add and verify your phone number for enhanced security.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to phone verification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Phone verification feature coming soon!',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Continue',
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

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Download My Data',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'We will prepare your data and send it to your email address within 24 hours.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Request data download
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data download request submitted!',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Request Data',
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: AppTheme.titleMedium.copyWith(
            color: Colors.red,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation();
            },
            child: Text(
              'Delete',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Final Confirmation',
          style: AppTheme.titleMedium.copyWith(
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you absolutely sure? This will permanently delete your account and all associated data.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account deletion feature coming soon!',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete Forever',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
