import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  // Theme Mode Toggle
                  ListTile(
                    leading: Icon(
                      themeMode == ThemeMode.dark 
                          ? Icons.dark_mode 
                          : themeMode == ThemeMode.light 
                              ? Icons.light_mode 
                              : Icons.brightness_auto,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Theme'),
                    subtitle: Text(
                      themeMode == ThemeMode.dark 
                          ? 'Dark Mode' 
                          : themeMode == ThemeMode.light 
                              ? 'Light Mode' 
                              : 'System Default',
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeMode,
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          themeNotifier.setTheme(newValue);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Quick Theme Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  ListTile(
                    leading: Icon(
                      themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(
                      themeMode == ThemeMode.dark ? 'Switch to Light' : 'Switch to Dark',
                    ),
                    subtitle: const Text('Toggle between light and dark theme'),
                    onTap: () => themeNotifier.toggleTheme(),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
