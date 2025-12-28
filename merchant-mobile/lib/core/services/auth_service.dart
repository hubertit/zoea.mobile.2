import 'dart:async';
import '../models/user.dart';

class AuthService {
  final StreamController<User?> _authController = StreamController<User?>.broadcast();
  
  Stream<User?> get authStateChanges => _authController.stream;
  
  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // Mock authentication with specific test accounts
      if (password != 'Pass123') {
        throw Exception('Invalid password');
      }
      
      User? user;
      switch (email.toLowerCase()) {
        case 'hubert@zoea.africa':
          user = User(
            id: '1',
            email: email,
            fullName: 'Hubert',
            role: UserRole.merchant,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isVerified: true,
          );
          break;
        default:
          // Allow any other email for testing (defaults to merchant)
          user = User(
            id: '2',
            email: email,
            fullName: 'Test Merchant',
            role: UserRole.merchant,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
      }
      
      _currentUser = user;
      _authController.add(user);
      return user;
    } catch (e) {
      _authController.addError(e);
      return null;
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    UserRole userRole = UserRole.merchant,
  }) async {
    try {
      // TODO: Implement actual registration with backend
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: userRole,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _currentUser = user;
      _authController.add(user);
      return user;
    } catch (e) {
      _authController.addError(e);
      return null;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }

  Future<void> dispose() async {
    await _authController.close();
  }
}

