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
      final isLoggedIn = await tokenStorage.isLoggedIn();
      
      // Get auth service
      _authService = _ref.read(authServiceProvider);
      
      // Listen to auth state changes
      _authService?.authStateChanges.listen((user) {
        if (mounted) {
          state = AsyncValue.data(user);
        }
      });
      
      // If user has tokens stored, they should be considered logged in
      // even if user data is missing (we can fetch it from API if needed)
      if (isLoggedIn) {
        final cachedUser = await tokenStorage.getUserData();
        if (cachedUser != null) {
          state = AsyncValue.data(cachedUser);
        } else {
          // User has tokens but no user data - keep them logged in
          // The app can fetch user data from profile endpoint if needed
          state = const AsyncValue.data(null);
        }
      } else {
        // No tokens and not logged in
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      // On error, don't force logout - keep existing state if possible
      state = AsyncValue.error(e, stack);
    }
  }

  /// Check if user is logged in by checking tokens directly
  Future<bool> isUserLoggedIn() async {
    try {
      final tokenStorage = await TokenStorageService.getInstance();
      final isLoggedIn = await tokenStorage.isLoggedIn();
      return isLoggedIn;
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
