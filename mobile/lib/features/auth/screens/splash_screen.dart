import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/constants/assets.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_data_collection_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/data_inference_service.dart';
import '../../../core/services/health_check_service.dart';
import '../../../core/models/user.dart';

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
    
    // First, check backend health
    final isHealthy = await HealthCheckService.checkHealthWithRetry(
      maxRetries: 2,
      retryDelay: const Duration(seconds: 1),
    );
    
    if (!mounted) return;
    
    if (!isHealthy) {
      // Backend is down, show maintenance screen
      if (mounted) {
        context.go('/maintenance');
      }
      return;
    }
    
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
      
      // Navigate based on auth state
    if (isLoggedIn) {
      // Increment session count for prompt timing
      try {
        final timingService = ref.read(promptTimingServiceProvider);
        await timingService.incrementSessionCount();
      } catch (e) {
        // Silently fail - session tracking should not block navigation
      }

      // Track session start for analytics
      try {
        final analyticsService = ref.read(analyticsServiceProvider);
        await analyticsService.trackSessionStart();
      } catch (e) {
        // Silently fail - analytics should not block navigation
      }

      // Check if mandatory data collection is complete
      try {
        final isComplete = await ref.read(isMandatoryDataCompleteProvider.future);
        
        if (!mounted) return;
        
        if (!isComplete) {
          // For existing users (4,500+), try silent inference first
          // Only redirect to onboarding if inference doesn't help
          try {
            await _silentEnrichmentForExistingUsers(ref);
            
            // Check again after enrichment
            final isCompleteAfterEnrichment = await ref.read(isMandatoryDataCompleteProvider.future);
            
            if (!mounted) return;
            
            if (!isCompleteAfterEnrichment) {
              // Still incomplete, redirect to onboarding data screen
              if (mounted) {
                context.go('/onboarding-data');
              }
              return;
            }
          } catch (e) {
            // If enrichment fails, redirect to onboarding
            if (mounted) {
              context.go('/onboarding-data');
            }
            return;
          }
        }
      } catch (e) {
        // If check fails, still allow navigation to explore
        // (graceful degradation - don't block user)
        if (mounted) {
          context.go('/explore');
        }
        return;
      }
      
      // Mandatory data is complete, go to explore
      if (mounted) {
        context.go('/explore');
      }
    } else {
      // Not logged in (no tokens), go to login screen
      if (mounted) {
        context.go('/login');
      }
    }
  }

  /// Silent enrichment for existing users (4,500+)
  /// Infers country, language, and user type from device settings
  Future<void> _silentEnrichmentForExistingUsers(WidgetRef ref) async {
    try {
      final inferenceService = DataInferenceService();
      final inferred = await inferenceService.inferAllData();
      
      final country = inferred['countryOfOrigin'] as String?;
      final language = inferred['language'] as String?;
      final userType = inferred['userType'] as UserType?;
      
      // Only update if we have inferred values and user preferences are missing them
      final user = ref.read(currentUserProvider);
      if (user?.preferences == null) return;
      
      final prefs = user!.preferences!;
      bool needsUpdate = false;
      
      // Check what needs to be updated
      if (country != null && (prefs.countryOfOrigin == null || prefs.countryOfOrigin!.isEmpty)) {
        needsUpdate = true;
      }
      if (language != null && (prefs.language == null || prefs.language!.isEmpty)) {
        needsUpdate = true;
      }
      if (userType != null && prefs.userType == null) {
        needsUpdate = true;
      }
      
      if (needsUpdate) {
        // Update preferences with inferred values
        // Use UserService to update preferences
        final userService = ref.read(userServiceProvider);
        await userService.updatePreferences(
          language: language ?? prefs.language,
          countryOfOrigin: country ?? prefs.countryOfOrigin,
          userType: userType ?? prefs.userType,
        );
        
        // Invalidate to refresh user data
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      // Silently fail - enrichment should never block user
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
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
                  isDarkMode ? AppAssets.logoWhite : AppAssets.logoDark,
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
                    color: context.primaryColorTheme,
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
                    color: context.secondaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(context.primaryColorTheme),
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

