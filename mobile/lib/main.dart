import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/config/app_config.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/user_data_collection_provider.dart';
import 'core/providers/health_check_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle app going to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _uploadAnalyticsBatch();
      // Pause health checks to save battery and network
      ref.read(healthCheckProvider.notifier).pause();
    }
    
    // Handle app coming to foreground
    if (state == AppLifecycleState.resumed) {
      // Resume health checks
      ref.read(healthCheckProvider.notifier).resume();
    }
  }

  Future<void> _uploadAnalyticsBatch() async {
    try {
      final analyticsService = ref.read(analyticsServiceProvider);
      await analyticsService.forceUpload();
    } catch (e) {
      // Silently fail - analytics should never break the app
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}