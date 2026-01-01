import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode themeMode,
    required ThemeMode currentMode,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = currentMode == themeMode;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacing12,
            horizontal: AppTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? context.primaryColorTheme 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? context.isDarkMode 
                        ? AppTheme.darkPrimaryTextColor
                        : Colors.white
                    : context.secondaryTextColor,
                size: 24,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected 
                      ? context.isDarkMode 
                          ? AppTheme.darkPrimaryTextColor
                          : Colors.white
                      : context.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // Theme Section with Enhanced UI
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: context.primaryTextColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Text(
                        'Appearance',
                        style: AppTheme.titleLarge.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Theme Mode Segmented Control
                  Container(
                    decoration: BoxDecoration(
                      color: context.grey100,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
                      border: Border.all(
                        color: context.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildThemeOption(
                          context: context,
                          themeMode: ThemeMode.light,
                          currentMode: themeMode,
                          icon: Icons.light_mode,
                          label: 'Light',
                          onTap: () => themeNotifier.setTheme(ThemeMode.light),
                        ),
                        _buildThemeOption(
                          context: context,
                          themeMode: ThemeMode.dark,
                          currentMode: themeMode,
                          icon: Icons.dark_mode,
                          label: 'Dark',
                          onTap: () => themeNotifier.setTheme(ThemeMode.dark),
                        ),
                        _buildThemeOption(
                          context: context,
                          themeMode: ThemeMode.system,
                          currentMode: themeMode,
                          icon: Icons.brightness_auto,
                          label: 'System',
                          onTap: () => themeNotifier.setTheme(ThemeMode.system),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacing16),
                  
                  // Current Theme Info
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: context.grey50,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          themeMode == ThemeMode.dark 
                              ? Icons.dark_mode 
                              : themeMode == ThemeMode.light 
                                  ? Icons.light_mode 
                                  : Icons.brightness_auto,
                          color: context.secondaryTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Theme',
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                themeMode == ThemeMode.dark 
                                    ? 'Dark Mode' 
                                    : themeMode == ThemeMode.light 
                                        ? 'Light Mode' 
                                        : 'System Default',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: context.primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
