// 

// 

// // @JsonSerializable()
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
    this.role = UserRole.explorer,
    this.preferences,
  });

  // Convert User to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'role': role.name,
      'preferences': preferences?.toJson(),
    };
  }

  // Create User from JSON (for cached data)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      role: _parseRole(json['role']),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.explorer;
    final roleString = role.toString().toLowerCase();
    switch (roleString) {
      case 'merchant':
        return UserRole.merchant;
      case 'event_organizer':
      case 'eventorganizer':
      case 'organizer':
        return UserRole.eventOrganizer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.explorer;
    }
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
}

// // @JsonSerializable()
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

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'currency': currency,
      'notificationsEnabled': notificationsEnabled,
      'locationEnabled': locationEnabled,
      'interests': interests,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'],
      currency: json['currency'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      locationEnabled: json['locationEnabled'] ?? true,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
    );
  }
}

enum UserRole {
  // // @JsonValue('explorer')
  explorer,
  // // @JsonValue('merchant')
  merchant,
  // // @JsonValue('event_organizer')
  eventOrganizer,
  // // @JsonValue('admin')
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
