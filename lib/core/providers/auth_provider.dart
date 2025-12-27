import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StateNotifier-based auth provider (similar to Finance project)
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  AuthService? _authService;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final tokenStorage = await TokenStorageService.getInstance();
      
      // Get auth service
      _authService = _ref.read(authServiceProvider);
      
      // Listen to auth state changes
      _authService?.authStateChanges.listen((user) {
        if (mounted) {
          state = AsyncValue.data(user);
        }
      });
      
      // Check if user has valid tokens
      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();
      final isLoggedIn = await tokenStorage.isLoggedIn();
      
      // If user has tokens, they should be considered logged in
      // The auth service will validate tokens and load user data
      if (isLoggedIn && accessToken != null && refreshToken != null) {
        // Wait a bit for auth service to load user (it runs in background)
        // Check auth service current user
        await Future.delayed(const Duration(milliseconds: 100));
        
        final cachedUser = await tokenStorage.getUserData();
        final serviceUser = _authService?.currentUser;
        
        // Use service user if available, otherwise cached user
        final user = serviceUser ?? cachedUser;
        
        if (user != null) {
          state = AsyncValue.data(user);
        } else {
          // User has tokens but no user data yet - keep them logged in
          // Auth service will fetch user data in background
          state = const AsyncValue.data(null);
        }
      } else {
        // No tokens or not logged in
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      // On error, check if we have tokens - if yes, keep session
      try {
        final tokenStorage = await TokenStorageService.getInstance();
        final accessToken = await tokenStorage.getAccessToken();
        final refreshToken = await tokenStorage.getRefreshToken();
        
        if (accessToken != null && refreshToken != null) {
          // Have tokens, keep session even if init had error
          final cachedUser = await tokenStorage.getUserData();
          state = AsyncValue.data(cachedUser);
        } else {
          state = AsyncValue.error(e, stack);
        }
      } catch (_) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Check if user is logged in by checking tokens directly
  Future<bool> isUserLoggedIn() async {
    try {
      // Use auth service to check for valid session
      final authService = _ref.read(authServiceProvider);
      return await authService.hasValidSession();
    } catch (e) {
      return false;
    }
  }

  /// Get current user from state
  User? get currentUser => state.value;
  
  /// Check if auth state is still loading
  bool get isLoading => state.isLoading;
}

// Legacy providers for backward compatibility
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
