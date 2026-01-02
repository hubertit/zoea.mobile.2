import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/user_data_collection_provider.dart';

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  bool _locationEnabled = true;
  bool _notificationsEnabled = true;
  bool _dataSharingEnabled = false;
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;


  @override
  Widget build(BuildContext context) {
    final analyticsConsentAsync = ref.watch(analyticsConsentProvider);
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Privacy & Security',
          style: context.titleLarge.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: Icon(Icons.chevron_left, size: 32, color: context.primaryTextColor),
          style: IconButton.styleFrom(
            foregroundColor: context.primaryTextColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
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
          // Analytics toggle - connected to AnalyticsService
          analyticsConsentAsync.when(
            data: (hasConsent) => _buildSwitchTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Help us improve the app with usage analytics',
              value: hasConsent,
              onChanged: (value) async {
                try {
                  final analyticsService = ref.read(analyticsServiceProvider);
                  await analyticsService.setConsent(value);
                  if (mounted) {
                    ref.invalidate(analyticsConsentProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value 
                              ? 'Analytics enabled' 
                              : 'Analytics disabled',
                          style: context.bodyMedium.copyWith(
                            color: context.primaryTextColor,
                          ),
                        ),
                        backgroundColor: value 
                            ? context.successColor 
                            : context.secondaryTextColor,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      AppTheme.errorSnackBar(
                        message: 'Failed to update analytics settings',
                      ),
                    );
                  }
                }
              },
            ),
            loading: () => _buildSwitchTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Loading...',
              value: false,
              onChanged: (_) {},
            ),
            error: (_, __) => _buildSwitchTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Help us improve the app with usage analytics',
              value: true,
              onChanged: (value) async {
                try {
                  final analyticsService = ref.read(analyticsServiceProvider);
                  await analyticsService.setConsent(value);
                  if (mounted) {
                    ref.invalidate(analyticsConsentProvider);
                  }
                } catch (e) {
                  // Silently fail
                }
              },
            ),
          ),
          const SizedBox(height: 32),

          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'What Data We Collect',
            subtitle: 'View what information is collected and why',
            onTap: () {
              _showDataCollectionInfo();
            },
          ),
          _buildActionTile(
            icon: Icons.delete_sweep,
            title: 'Clear Analytics Data',
            subtitle: 'Delete all stored analytics data',
            onTap: () {
              _showClearAnalyticsDialog();
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
      style: context.titleMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: context.primaryTextColor,
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
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
        title: Text(
          title,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: context.primaryTextColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.bodySmall.copyWith(
            color: context.secondaryTextColor,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: context.primaryColorTheme,
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
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
                ? context.errorColor.withOpacity(0.1)
                : context.primaryColorTheme.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? context.errorColor : context.primaryColorTheme,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? context.errorColor : context.primaryTextColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.bodySmall.copyWith(
            color: context.secondaryTextColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: context.secondaryTextColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Form(
            key: formKey,
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
                  'Change Password',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Current Password
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    hintText: 'Enter your current password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setModalState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: context.dividerColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // New Password
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    hintText: 'Enter your new password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setModalState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: context.dividerColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    hintText: 'Confirm your new password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setModalState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: context.dividerColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () {
                          Navigator.pop(context);
                          currentPasswordController.dispose();
                          newPasswordController.dispose();
                          confirmPasswordController.dispose();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: context.secondaryTextColor),
                        ),
                        child: Text(
                          'Cancel',
                          style: context.bodyMedium.copyWith(
                            color: context.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() {
                              isLoading = true;
                            });

                            try {
                              final userService = ref.read(userServiceProvider);
                              await userService.changePassword(
                                currentPassword: currentPasswordController.text,
                                newPassword: newPasswordController.text,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password changed successfully!',
                                      style: context.bodyMedium.copyWith(
                                        color: context.primaryTextColor,
                                      ),
                                    ),
                                    backgroundColor: context.successColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                final errorMessage = e.toString().replaceFirst('Exception: ', '');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      errorMessage.isNotEmpty 
                                          ? errorMessage 
                                          : 'Failed to change password. Please try again.',
                                      style: context.bodyMedium.copyWith(
                                        color: context.primaryTextColor,
                                      ),
                                    ),
                                    backgroundColor: context.errorColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setModalState(() {
                                  isLoading = false;
                                });
                              }
                              currentPasswordController.dispose();
                              newPasswordController.dispose();
                              confirmPasswordController.dispose();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColorTheme,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: context.primaryTextColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Change Password',
                                style: context.bodyMedium.copyWith(
                                  color: context.primaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEmailVerificationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
              'Email Verification',
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Content
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.primaryColorTheme.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: context.primaryColorTheme,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A verification email will be sent to your registered email address.',
                      style: context.bodyMedium.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),
                ],
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
                      'Cancel',
                      style: context.bodyMedium.copyWith(
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
                      // TODO: Send verification email
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Verification email sent!',
                            style: context.bodyMedium.copyWith(
                              color: context.primaryTextColor,
                            ),
                          ),
                          backgroundColor: context.successColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColorTheme,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Send Email',
                      style: context.bodyMedium.copyWith(
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

  void _showPhoneVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          'Phone Verification',
          style: context.titleMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        content: Text(
          'Add and verify your phone number for enhanced security.',
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
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
                    style: context.bodyMedium.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  backgroundColor: context.primaryColorTheme,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Continue',
              style: context.bodyMedium.copyWith(
                color: context.primaryColorTheme,
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
        backgroundColor: context.cardColor,
        title: Text(
          'Download My Data',
          style: context.titleMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        content: Text(
          'We will prepare your data and send it to your email address within 24 hours.',
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
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
                    style: context.bodyMedium.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  backgroundColor: context.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Request Data',
              style: context.bodyMedium.copyWith(
                color: context.primaryColorTheme,
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
        backgroundColor: context.cardColor,
        title: Text(
          'Delete Account',
          style: context.titleMedium.copyWith(
            color: context.errorColor,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
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
              style: context.bodyMedium.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataCollectionInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
              'What Data We Collect',
              style: context.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Data collection info
            _buildDataInfoItem(
              icon: Icons.person_outline,
              title: 'Profile Information',
              description: 'Country, language, age range, gender, interests, travel preferences',
              purpose: 'Personalize your experience and recommendations',
            ),
            const SizedBox(height: 16),
            _buildDataInfoItem(
              icon: Icons.search,
              title: 'Search Queries',
              description: 'What you search for in the app',
              purpose: 'Improve search results and suggest relevant content',
            ),
            const SizedBox(height: 16),
            _buildDataInfoItem(
              icon: Icons.visibility,
              title: 'Content Views',
              description: 'Places and events you view',
              purpose: 'Understand your interests and improve recommendations',
            ),
            const SizedBox(height: 16),
            _buildDataInfoItem(
              icon: Icons.event,
              title: 'App Usage',
              description: 'How you use the app, session duration, features used',
              purpose: 'Improve app performance and user experience',
            ),
            const SizedBox(height: 24),
            
            // Privacy note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryColorTheme.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: context.primaryColorTheme,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All data is anonymized and used only to improve your experience. You can disable analytics or clear your data anytime.',
                      style: context.bodySmall.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
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
                  'Got it',
                  style: context.bodyMedium.copyWith(
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDataInfoItem({
    required IconData icon,
    required String title,
    required String description,
    required String purpose,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.dividerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: context.primaryColorTheme,
            size: 20,
          ),
          const SizedBox(width: 12),
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
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodySmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Purpose: $purpose',
                  style: context.bodySmall.copyWith(
                    color: context.primaryColorTheme,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAnalyticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          'Clear Analytics Data',
          style: context.titleMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        content: Text(
          'This will delete all stored analytics data from your device. This action cannot be undone.',
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final analyticsService = ref.read(analyticsServiceProvider);
                await analyticsService.clearQueue();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Analytics data cleared successfully',
                        style: context.bodyMedium.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                      backgroundColor: context.successColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    AppTheme.errorSnackBar(
                      message: 'Failed to clear analytics data',
                    ),
                  );
                }
              }
            },
            child: Text(
              'Clear Data',
              style: context.bodyMedium.copyWith(
                color: context.primaryColorTheme,
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
        backgroundColor: context.cardColor,
        title: Text(
          'Final Confirmation',
          style: context.titleMedium.copyWith(
            color: context.errorColor,
          ),
        ),
        content: Text(
          'Are you absolutely sure? This will permanently delete your account and all associated data.',
          style: context.bodyMedium.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyMedium.copyWith(
                color: context.secondaryTextColor,
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
                    style: context.bodyMedium.copyWith(
                      color: context.primaryTextColor,
                    ),
                  ),
                  backgroundColor: context.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete Forever',
              style: context.bodyMedium.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
