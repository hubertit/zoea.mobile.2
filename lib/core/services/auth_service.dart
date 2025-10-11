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
        case 'explorer@zoea.africa':
          user = User(
            id: '1',
            email: email,
            fullName: 'Alex Explorer',
            role: UserRole.explorer,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          break;
        case 'merchant@zoea.africa':
          user = User(
            id: '2',
            email: email,
            fullName: 'Maria Merchant',
            role: UserRole.merchant,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          break;
        case 'eventorg@zoea.africa':
          user = User(
            id: '3',
            email: email,
            fullName: 'David Event Organizer',
            role: UserRole.eventOrganizer,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          break;
        default:
          // Allow any other email for testing
          user = User(
            id: '4',
            email: email,
            fullName: 'Test User',
            role: UserRole.explorer,
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

  Future<User?> signUpWithEmail(String email, String password, String fullName, UserRole userRole) async {
    try {
      // TODO: Implement actual registration with backend
      final user = User(
        id: '1',
        email: email,
        fullName: fullName,
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
