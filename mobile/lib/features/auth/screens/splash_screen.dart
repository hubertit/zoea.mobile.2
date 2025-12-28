import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/assets.dart';
import '../../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _animationController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash duration
    await Future.delayed(
      const Duration(milliseconds: AppConfig.splashDuration),
    );
    
    if (!mounted) return;
    
    // Wait for auth provider to finish initializing (loading user from storage)
    // Check auth state multiple times until it's no longer loading
    int attempts = 0;
    while (attempts < 10) {
      final authState = ref.read(authProvider);
      if (!authState.isLoading) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
      if (!mounted) return;
    }
    
    if (!mounted) return;
    
    // Check if user is logged in (has tokens stored)
    final authNotifier = ref.read(authProvider.notifier);
    final isLoggedIn = await authNotifier.isUserLoggedIn();
    
    if (!mounted) return;
    
    // Get the current user from auth state
    final user = ref.read(authProvider).value;
    
    // Navigate based on auth state
    // If user has tokens (isLoggedIn), keep them logged in even if user data is missing
    // User data can be fetched from API if needed
    if (isLoggedIn) {
      if (user != null) {
        // User is logged in and has valid user data, go to explore
        if (mounted) {
          context.go('/explore');
        }
      } else {
        // User has tokens but no user data - still keep them logged in
        // Navigate to explore, user data will be fetched if needed
        if (mounted) {
          context.go('/explore');
        }
      }
    } else {
      // Not logged in (no tokens), go to login screen
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  AppAssets.logoDark,
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              
              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Zoea Africa',
                  style: AppTheme.titleLarge.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Discover Rwanda Like Never Before',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

