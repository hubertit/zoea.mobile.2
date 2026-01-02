import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

/// Internet connectivity status
enum InternetStatus {
  connected,
  disconnected,
  checking,
  unknown,
}

/// Connectivity state with detailed information
class ConnectivityState {
  final InternetStatus status;
  final List<ConnectivityResult> connectivityResults;
  final DateTime? lastCheckTime;
  final DateTime? lastConnectedTime;
  final bool hasInternetAccess; // Actually verified internet access
  final String? errorMessage;

  const ConnectivityState({
    required this.status,
    this.connectivityResults = const [],
    this.lastCheckTime,
    this.lastConnectedTime,
    this.hasInternetAccess = false,
    this.errorMessage,
  });

  ConnectivityState copyWith({
    InternetStatus? status,
    List<ConnectivityResult>? connectivityResults,
    DateTime? lastCheckTime,
    DateTime? lastConnectedTime,
    bool? hasInternetAccess,
    String? errorMessage,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      connectivityResults: connectivityResults ?? this.connectivityResults,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
      lastConnectedTime: lastConnectedTime ?? this.lastConnectedTime,
      hasInternetAccess: hasInternetAccess ?? this.hasInternetAccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isConnected => status == InternetStatus.connected;
  bool get isDisconnected => status == InternetStatus.disconnected;
  bool get isChecking => status == InternetStatus.checking;

  /// Check if device has any network interface (WiFi or cellular)
  bool get hasNetworkInterface {
    return connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);
  }

  /// Get human-readable connection type
  String get connectionType {
    if (connectivityResults.isEmpty ||
        connectivityResults.contains(ConnectivityResult.none)) {
      return 'No connection';
    }
    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    }
    if (connectivityResults.contains(ConnectivityResult.mobile)) {
      return 'Mobile data';
    }
    if (connectivityResults.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    }
    return 'Connected';
  }
}

/// Notifier for managing internet connectivity
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();
  bool _isCheckingInProgress = false;

  ConnectivityNotifier()
      : super(const ConnectivityState(
          status: InternetStatus.unknown,
        )) {
    _initialize();
  }

  /// Initialize connectivity monitoring
  Future<void> _initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _onConnectivityChanged(results);
      },
      onError: (error) {
        state = state.copyWith(
          status: InternetStatus.disconnected,
          errorMessage: 'Connectivity monitoring error: ${error.toString()}',
        );
      },
    );
  }

  /// Handle connectivity changes
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    // Update connectivity results immediately
    state = state.copyWith(
      connectivityResults: results,
      lastCheckTime: DateTime.now(),
    );

    // Verify actual internet access
    await checkConnectivity();
  }

  /// Check connectivity and verify internet access
  Future<void> checkConnectivity() async {
    if (_isCheckingInProgress) return;

    _isCheckingInProgress = true;

    try {
      // Get current connectivity status
      final results = await _connectivity.checkConnectivity();

      state = state.copyWith(
        status: InternetStatus.checking,
        connectivityResults: results,
        lastCheckTime: DateTime.now(),
      );

      // If no network interface, device is offline
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        state = ConnectivityState(
          status: InternetStatus.disconnected,
          connectivityResults: results,
          lastCheckTime: DateTime.now(),
          lastConnectedTime: state.lastConnectedTime,
          hasInternetAccess: false,
          errorMessage: 'No network connection available',
        );
        _isCheckingInProgress = false;
        return;
      }

      // Verify actual internet access by pinging a reliable endpoint
      final hasInternet = await _verifyInternetAccess();

      if (hasInternet) {
        state = ConnectivityState(
          status: InternetStatus.connected,
          connectivityResults: results,
          lastCheckTime: DateTime.now(),
          lastConnectedTime: DateTime.now(),
          hasInternetAccess: true,
          errorMessage: null,
        );
      } else {
        state = ConnectivityState(
          status: InternetStatus.disconnected,
          connectivityResults: results,
          lastCheckTime: DateTime.now(),
          lastConnectedTime: state.lastConnectedTime,
          hasInternetAccess: false,
          errorMessage: 'Network connected but no internet access',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: InternetStatus.disconnected,
        errorMessage: 'Error checking connectivity: ${e.toString()}',
        hasInternetAccess: false,
      );
    } finally {
      _isCheckingInProgress = false;
    }
  }

  /// Verify actual internet access by pinging Google DNS
  Future<bool> _verifyInternetAccess() async {
    try {
      // Try multiple endpoints for reliability
      final endpoints = [
        'https://www.google.com',
        'https://www.cloudflare.com',
        '8.8.8.8', // Google DNS
      ];

      for (final endpoint in endpoints) {
        try {
          final dio = Dio(BaseOptions(
            connectTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ));

          if (endpoint.startsWith('http')) {
            await dio.head(endpoint);
          } else {
            // For IP addresses, use a simple GET request
            await dio.get('https://$endpoint');
          }

          return true; // Success, internet is accessible
        } catch (_) {
          // Try next endpoint
          continue;
        }
      }

      return false; // All endpoints failed
    } catch (_) {
      return false;
    }
  }

  /// Force an immediate connectivity check
  Future<void> forceCheck() async {
    await checkConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Provider for connectivity state
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

/// Provider for checking if device has internet
final hasInternetProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.isConnected && connectivity.hasInternetAccess;
});

/// Provider for checking if device is offline
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.isDisconnected || !connectivity.hasInternetAccess;
});

/// Provider for getting connection type
final connectionTypeProvider = Provider<String>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.connectionType;
});

