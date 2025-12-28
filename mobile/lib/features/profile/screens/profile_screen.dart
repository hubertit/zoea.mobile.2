import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // User preferences state - will be loaded from user data
  String _selectedCurrency = 'RWF';
  String _selectedCountry = 'Rwanda';
  String _selectedLocation = 'Kigali';
  String _selectedLanguage = 'English';
  
  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }
  
  void _loadUserPreferences() {
    final user = ref.read(currentUserProvider);
    if (user?.preferences != null) {
      setState(() {
        _selectedCurrency = user!.preferences!.currency ?? 'RWF';
        // Map language codes to display names
        final langCode = user.preferences!.language ?? 'en';
        _selectedLanguage = _mapLanguageCodeToName(langCode);
      });
    }
  }
  
  String _mapLanguageCodeToName(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'English';
      case 'rw':
      case 'kin':
        return 'Kinyarwanda';
      case 'fr':
        return 'French';
      case 'sw':
        return 'Swahili';
      default:
        return 'English';
    }
  }
  
  String _mapLanguageNameToCode(String name) {
    switch (name) {
      case 'Kinyarwanda':
        return 'rw';
      case 'English':
        return 'en';
      case 'French':
        return 'fr';
      case 'Swahili':
        return 'sw';
      default:
        return 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              title: 'Preferences',
              items: [
                _buildMenuItem(
                  icon: Icons.attach_money_outlined,
                  title: 'Currency',
                  subtitle: _selectedCurrency,
                  onTap: () {
                    _showCurrencyBottomSheet(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.public_outlined,
                  title: 'Country',
                  subtitle: _selectedCountry,
                  onTap: () {
                    _showCountryBottomSheet(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  subtitle: _selectedLocation,
                  onTap: () {
                    _showLocationBottomSheet(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  onTap: () {
                    _showLanguageBottomSheet(context);
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
                    context.go('/profile/my-bookings');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Favorites',
                  subtitle: 'Your saved places and events',
                  onTap: () {
                    context.go('/profile/favorites');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.reviews_outlined,
                  title: 'Reviews & Ratings',
                  subtitle: 'Your reviews and feedback',
                  onTap: () {
                    context.go('/profile/reviews-ratings');
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
                    context.go('/profile/help-center');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    context.go('/profile/about');
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
    final user = ref.watch(currentUserProvider);
    
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
            child: user?.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      user!.profileImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'User',
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.isVerified == true)
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
              context.go('/profile/edit');
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
    final userStats = ref.watch(userStatsProvider);
    
    return userStats.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.go('/profile/events-attended'),
              child: _buildStatCard(
                icon: Icons.event,
                title: 'Events',
                value: '0', // Events not in stats yet
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
                value: '${stats['visitedPlaces'] ?? 0}',
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
                value: '${stats['reviews'] ?? 0}',
                subtitle: 'Written',
              ),
            ),
          ),
        ],
      ),
      loading: () => Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.event, title: 'Events', value: '...', subtitle: 'Attended')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.place, title: 'Places', value: '...', subtitle: 'Visited')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.star, title: 'Reviews', value: '...', subtitle: 'Written')),
        ],
      ),
      error: (_, __) => Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.event, title: 'Events', value: '0', subtitle: 'Attended')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.place, title: 'Places', value: '0', subtitle: 'Visited')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.star, title: 'Reviews', value: '0', subtitle: 'Written')),
        ],
      ),
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
            const Icon(
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
            onPressed: () async {
              Navigator.pop(context);
              // Sign out using auth service
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              // Navigate to login screen
              if (context.mounted) {
                context.go('/login');
              }
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

  void _showCurrencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50],
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Select Currency',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Currency options
            _buildCurrencyOption('USD', 'United States Dollar', _selectedCurrency == 'USD'),
            _buildCurrencyOption('RWF', 'Rwandan Franc', _selectedCurrency == 'RWF'),
            _buildCurrencyOption('EUR', 'Euro', _selectedCurrency == 'EUR'),
            _buildCurrencyOption('GBP', 'British Pound', _selectedCurrency == 'GBP'),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showCountryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50],
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Select Country',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Country options
            _buildCountryOption('Rwanda', '🇷🇼', _selectedCountry == 'Rwanda'),
            _buildCountryOption('Kenya', '🇰🇪', _selectedCountry == 'Kenya'),
            _buildCountryOption('Uganda', '🇺🇬', _selectedCountry == 'Uganda'),
            _buildCountryOption('Tanzania', '🇹🇿', _selectedCountry == 'Tanzania'),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50],
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Select Location',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Location options
            _buildLocationOption('Kigali', 'Capital city', _selectedLocation == 'Kigali'),
            _buildLocationOption('Butare', 'University town', _selectedLocation == 'Butare'),
            _buildLocationOption('Gisenyi', 'Lake town', _selectedLocation == 'Gisenyi'),
            _buildLocationOption('Ruhengeri', 'Mountain region', _selectedLocation == 'Ruhengeri'),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[50],
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Select Language',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // Language options
            _buildLanguageOption('Kinyarwanda', 'Ikinyarwanda', _selectedLanguage == 'Kinyarwanda'),
            _buildLanguageOption('English', 'English', _selectedLanguage == 'English'),
            _buildLanguageOption('French', 'Français', _selectedLanguage == 'French'),
            _buildLanguageOption('Swahili', 'Kiswahili', _selectedLanguage == 'Swahili'),
            
            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          code,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
          ),
        ),
        subtitle: Text(
          name,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
          ),
        ),
        trailing: isSelected ? const Icon(
          Icons.check_circle,
          color: AppTheme.primaryColor,
          size: 20,
        ) : null,
        onTap: () async {
          Navigator.pop(context);
          setState(() {
            _selectedCurrency = code;
          });
          
          // Update preferences in API
          try {
            final userService = ref.read(userServiceProvider);
            await userService.updatePreferences(currency: code);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Currency changed to $code',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to update currency: ${e.toString().replaceFirst('Exception: ', '')}',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCountryOption(String name, String flag, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(
          flag,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          name,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
          ),
        ),
        trailing: isSelected ? const Icon(
          Icons.check_circle,
          color: AppTheme.primaryColor,
          size: 20,
        ) : null,
        onTap: () {
          setState(() {
            _selectedCountry = name;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Country changed to $name',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationOption(String name, String description, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
        ),
        title: Text(
          name,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
          ),
        ),
        trailing: isSelected ? const Icon(
          Icons.check_circle,
          color: AppTheme.primaryColor,
          size: 20,
        ) : null,
        onTap: () {
          setState(() {
            _selectedLocation = name;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location changed to $name',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption(String name, String nativeName, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          name,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryColor : AppTheme.primaryTextColor,
          ),
        ),
        subtitle: Text(
          nativeName,
          style: AppTheme.bodySmall.copyWith(
            color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
          ),
        ),
        trailing: isSelected ? const Icon(
          Icons.check_circle,
          color: AppTheme.primaryColor,
          size: 20,
        ) : null,
        onTap: () async {
          Navigator.pop(context);
          setState(() {
            _selectedLanguage = name;
          });
          
          // Update preferences in API
          try {
            final userService = ref.read(userServiceProvider);
            final langCode = _mapLanguageNameToCode(name);
            await userService.updatePreferences(language: langCode);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed to $name',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to update language: ${e.toString().replaceFirst('Exception: ', '')}',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
