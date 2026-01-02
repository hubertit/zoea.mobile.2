import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';
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
    // Start the timer for minimum splash duration
    final splashTimer = Future.delayed(
      const Duration(milliseconds: AppConfig.splashDuration),
    );
    
    // Run auth checks in parallel with splash timer
    final authCheckFuture = _performAuthChecks();
    
    // Wait for both the splash duration AND auth checks to complete
    await Future.wait([splashTimer, authCheckFuture]);
    
    if (!mounted) return;
    
    // Navigate based on the result from auth checks
    final navigationPath = await authCheckFuture;
    if (mounted && navigationPath != null) {
      context.go(navigationPath);
    }
  }

  /// Perform all authentication and health checks
  /// Returns the navigation path to go to
  Future<String?> _performAuthChecks() async {
    // First, check backend health
    final isHealthy = await HealthCheckService.checkHealthWithRetry(
      maxRetries: 2,
      retryDelay: const Duration(seconds: 1),
    );
    
    if (!mounted) return null;
    
    if (!isHealthy) {
      // Backend is down, show maintenance screen
      return '/maintenance';
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
      if (!mounted) return null;
    }
    
    if (!mounted) return null;
    
    // Check if user is logged in (has tokens stored)
    final authNotifier = ref.read(authProvider.notifier);
    final isLoggedIn = await authNotifier.isUserLoggedIn();
    
    if (!mounted) return null;
    
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
        
        if (!mounted) return null;
        
        if (!isComplete) {
          // For existing users (4,500+), try silent inference first
          // Only redirect to onboarding if inference doesn't help
          try {
            await _silentEnrichmentForExistingUsers(ref);
            
            // Check again after enrichment
            final isCompleteAfterEnrichment = await ref.read(isMandatoryDataCompleteProvider.future);
            
            if (!mounted) return null;
            
            if (!isCompleteAfterEnrichment) {
              // Still incomplete, redirect to onboarding data screen
              return '/onboarding-data';
            }
          } catch (e) {
            // If enrichment fails, redirect to onboarding
            return '/onboarding-data';
          }
        }
      } catch (e) {
        // If check fails, still allow navigation to explore
        // (graceful degradation - don't block user)
        return '/explore';
      }
      
      // Mandatory data is complete, go to explore
      return '/explore';
    } else {
      // Not logged in (no tokens), go to login screen
      return '/login';
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            AppAssets.splashBackground,
            fit: BoxFit.cover,
          ),
          // Gradient overlay - transparent at center to darker at bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Circular progress indicator at top
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // Content at bottom
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bold headline - line 1
                  const Text(
                    'Discover Rwanda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  // Bold headline - line 2
                  const Text(
                    'Like Never Before',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description text
                  Text(
                    'Explore stunning destinations, authentic experiences, and hidden gems across the Land of a Thousand Hills.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // "Powered by" section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Powered by',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.asset(
                        AppAssets.logoWhite,
                        height: 35,
                        fit: BoxFit.contain,
                      ),
                    ],
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

