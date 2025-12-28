class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final UserRole role;
  final UserPreferences? preferences;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.role = UserRole.merchant,
    this.preferences,
  });

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'M';
  }
}

class UserPreferences {
  final String? language;
  final String? currency;
  final bool notificationsEnabled;
  final bool locationEnabled;
  final List<String> interests;

  const UserPreferences({
    this.language,
    this.currency,
    this.notificationsEnabled = true,
    this.locationEnabled = true,
    this.interests = const [],
  });
}

enum UserRole {
  explorer,
  merchant,
  eventOrganizer,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.explorer:
        return 'Explorer';
      case UserRole.merchant:
        return 'Merchant';
      case UserRole.eventOrganizer:
        return 'Event Organizer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.explorer:
        return 'Discover and book experiences, hotels, restaurants, and tours';
      case UserRole.merchant:
        return 'Manage your business listings and bookings';
      case UserRole.eventOrganizer:
        return 'Create and manage events and experiences';
      case UserRole.admin:
        return 'Platform administration and management';
    }
  }
}

