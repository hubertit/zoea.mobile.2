import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to settings
              // context.go('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.dividerColor,
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 32),
            
            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 32),
            
            // Menu Sections
            _buildMenuSection(
              title: 'Account',
              items: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    context.go('/profile/edit');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.email_outlined,
                  title: 'Email & Phone',
                  subtitle: 'Manage contact information',
                  onTap: () {
                    // TODO: Navigate to contact settings
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Password and privacy settings',
                  onTap: () {
                    context.go('/profile/privacy-security');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildMenuSection(
              title: 'Travel & Activities',
              items: [
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'My Bookings',
                  subtitle: 'View your reservations',
                  onTap: () {
                    // TODO: Navigate to bookings
                  },
                ),
                _buildMenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Favorites',
                  subtitle: 'Your saved places and events',
                  onTap: () {
                    // TODO: Navigate to favorites
                  },
                ),
                _buildMenuItem(
                  icon: Icons.reviews_outlined,
                  title: 'Reviews & Ratings',
                  subtitle: 'Your reviews and feedback',
                  onTap: () {
                    // TODO: Navigate to reviews
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildMenuSection(
              title: 'Support',
              items: [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    // TODO: Navigate to about
                  },
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: () {
                    _showSignOutDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'john.doe@example.com',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Verified Traveler',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Edit Button
          IconButton(
            onPressed: () {
              // TODO: Navigate to edit profile
            },
            icon: const Icon(Icons.edit_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.dividerColor,
              foregroundColor: AppTheme.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/profile/events-attended'),
            child: _buildStatCard(
              icon: Icons.event,
              title: 'Events',
              value: '12',
              subtitle: 'Attended',
            ),
          ),
        ),
        const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go('/profile/visited-places'),
                  child: _buildStatCard(
                    icon: Icons.place,
                    title: 'Places',
                    value: '8',
                    subtitle: 'Visited',
                  ),
                ),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => context.go('/profile/reviews-written'),
            child: _buildStatCard(
              icon: Icons.star,
              title: 'Reviews',
              value: '24',
              subtitle: 'Written',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTextColor,
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
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
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

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to sign out?',
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
              // TODO: Implement sign out logic
              // context.go('/login');
            },
            child: Text(
              'Sign Out',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
