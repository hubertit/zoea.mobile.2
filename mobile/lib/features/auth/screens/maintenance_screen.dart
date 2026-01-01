import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/services/health_check_service.dart';

/// Beautiful maintenance/offline screen shown when backend is unavailable
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
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
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _retryConnection() async {
    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Builder(
            builder: (context) => Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius16),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(context.primaryColorTheme),
              ),
            ),
          ),
        ),
      );
    }

    // Check health with retry
    final isHealthy = await HealthCheckService.checkHealthWithRetry(
      maxRetries: 2,
      retryDelay: const Duration(seconds: 1),
    );

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (isHealthy) {
        // Backend is back online, navigate to splash to restart the flow
        context.go('/splash');
      } else {
        // Still down, show a brief message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Service is still unavailable. Please try again in a moment.'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.primaryColorTheme.withOpacity(0.2),
                          context.primaryColorTheme.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: context.primaryColorTheme,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacing32),
                  
                  // Title
                  Text(
                    'We\'ll Be Right Back!',
                    style: AppTheme.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppTheme.spacing16),
                  
                      // Message
                      Text(
                        'Our systems are currently undergoing maintenance to serve you better. We\'ll be back online shortly.',
                        style: AppTheme.bodyLarge.copyWith(
                          color: context.secondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  
                  const SizedBox(height: AppTheme.spacing32),
                  
                  // Decorative divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: context.dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing16,
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 16,
                          color: context.primaryColorTheme.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: context.dividerColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacing32),
                  
                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retryConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColorTheme,
                        foregroundColor: context.primaryTextColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadius12,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 20, color: context.primaryTextColor),
                          const SizedBox(width: AppTheme.spacing8),
                          Text(
                            'Try Again',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacing24),
                  
                  // Support info
                  Text(
                    'Need help? Contact us at support@zoea.africa',
                    style: AppTheme.bodySmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

