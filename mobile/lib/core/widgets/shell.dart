import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_extensions.dart';
import '../theme/text_theme_extensions.dart';
import '../providers/health_check_provider.dart';
import '../providers/connectivity_provider.dart';

class Shell extends ConsumerStatefulWidget {
  final Widget child;

  const Shell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  bool _hasShownMaintenanceScreen = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    
    // Start periodic health checks when app shell is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthCheckProvider.notifier).startPeriodicChecks();
      
      // After initial grace period, allow warnings to show
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isInitialLoad = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    // Listen to connectivity state changes
    ref.listen<ConnectivityState>(
      connectivityProvider,
      (previous, next) {
        // Skip notifications during initial load
        if (_isInitialLoad) return;
        
        // If device loses internet
        if (previous?.isConnected == true && next.isDisconnected) {
          _showNoInternetWarning(next);
        }
        
        // If device regains internet
        if (previous?.isDisconnected == true && next.isConnected) {
          _showInternetRestoredMessage();
        }
      },
    );
    
    // Listen to health state changes (only when internet is available)
    ref.listen<BackendHealthState>(
      healthCheckProvider,
      (previous, next) {
        // Skip notifications during initial load
        if (_isInitialLoad) return;
        
        final hasInternet = ref.read(hasInternetProvider);
        
        // Only show backend warnings if we have internet
        if (!hasInternet) return;
        
        // If backend becomes unhealthy after being healthy, show warning
        if (previous?.isHealthy == true && next.isUnhealthy) {
          _showBackendOfflineWarning();
        }
        
        // If backend has been unhealthy for too long, navigate to maintenance
        if (next.consecutiveFailures >= 3 && !_hasShownMaintenanceScreen) {
          _navigateToMaintenance();
        }
        
        // If backend recovers, show success message
        if (previous?.isUnhealthy == true && next.isHealthy) {
          _showBackOnlineMessage();
          _hasShownMaintenanceScreen = false;
        }
      },
    );
    
    final isOffline = ref.watch(isOfflineProvider);
    final connectivityState = ref.watch(connectivityProvider);
    final shouldShowBackendWarning = ref.watch(shouldShowOfflineWarningProvider);
    final healthState = ref.watch(healthCheckProvider);
    
    // Determine current index based on location (5 items now)
    int currentIndex = 0;
    if (location.startsWith('/events')) {
      currentIndex = 1;
    } else if (location.startsWith('/ask-zoea')) {
      currentIndex = 2;
    } else if (location.startsWith('/accommodation')) {
      currentIndex = 3;
    } else if (location.startsWith('/my-bookings')) {
      currentIndex = 4;
    } else if (location.startsWith('/explore')) {
      currentIndex = 0;
    }
    
    return Scaffold(
      body: Column(
        children: [
          // No internet banner (higher priority) - only show after initial load
          if (!_isInitialLoad && isOffline)
            _buildNoInternetBanner(connectivityState)
          // Backend offline warning banner (only show if internet is available and after initial load)
          else if (!_isInitialLoad && shouldShowBackendWarning && !_hasShownMaintenanceScreen)
            _buildBackendOfflineBanner(healthState),
          // Main content
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.surfaceColor,
        selectedItemColor: context.primaryColorTheme,
        unselectedItemColor: context.secondaryTextColor,
        currentIndex: currentIndex,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.primaryColorTheme,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.secondaryTextColor,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedAskZoeaIcon(isActive: currentIndex == 2),
            activeIcon: const Icon(Icons.smart_toy),
            label: 'Ask Zoea',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.hotel_outlined),
            activeIcon: Icon(Icons.hotel),
            label: 'Stay',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book_online_outlined),
            activeIcon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/explore');
              break;
            case 1:
              context.go('/events');
              break;
            case 2:
              context.go('/ask-zoea');
              break;
            case 3:
              context.go('/accommodation');
              break;
            case 4:
              context.go('/my-bookings');
              break;
          }
        },
      ),
    );
  }

  Widget _buildNoInternetBanner(ConnectivityState connectivityState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.errorColor.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No Internet Connection',
                    style: context.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Check your WiFi or mobile data connection',
                    style: context.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ref.read(connectivityProvider.notifier).forceCheck();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendOfflineBanner(BackendHealthState healthState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Service Issue',
                    style: context.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Having trouble connecting to our servers',
                    style: context.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ref.read(healthCheckProvider.notifier).checkHealth();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoInternetWarning(ConnectivityState state) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No internet connection. Please check your network settings.',
                style: context.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: context.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showInternetRestoredMessage() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Internet connection restored!',
                style: context.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showBackendOfflineWarning() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Service temporarily unavailable. Retrying...',
                style: context.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showBackOnlineMessage() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Back online! Connection restored.',
                style: context.bodySmall.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _navigateToMaintenance() {
    if (!mounted) return;
    
    _hasShownMaintenanceScreen = true;
    
    // Navigate to maintenance screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/maintenance');
      }
    });
  }
}

/// Animated Ask Zoea Icon with subtle pulse effect
class _AnimatedAskZoeaIcon extends StatefulWidget {
  final bool isActive;

  const _AnimatedAskZoeaIcon({required this.isActive});

  @override
  State<_AnimatedAskZoeaIcon> createState() => _AnimatedAskZoeaIconState();
}

class _AnimatedAskZoeaIconState extends State<_AnimatedAskZoeaIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (!widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_AnimatedAskZoeaIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.stop();
        _controller.reset();
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If active, show static icon
    if (widget.isActive) {
      return const Icon(Icons.smart_toy_outlined);
    }

    // If inactive, show animated icon
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: const Icon(Icons.smart_toy_outlined),
          ),
        );
      },
    );
  }
}
