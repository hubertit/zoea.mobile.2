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
        title: const Text('Profile'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'John Doe',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              'john.doe@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            SizedBox(height: AppTheme.spacing32),
            const Text(
              'Profile management and user settings',
              style: const TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
