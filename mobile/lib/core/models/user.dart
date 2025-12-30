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
  // Existing fields
  final String? language;
  final String? currency;
  final bool notificationsEnabled;
  final bool locationEnabled;
  final List<String> interests;

  // UX-First User Data Collection fields
  final String? countryOfOrigin; // ISO country code (e.g., "RW", "US")
  final UserType? userType; // resident, visitor
  final VisitPurpose? visitPurpose; // leisure, business, mice
  final AgeRange? ageRange; // e.g., "under-18", "18-25", "26-35", etc.
  final Gender? gender; // male, female, other, prefer_not_to_say
  final LengthOfStay? lengthOfStay; // "1-3 days", "4-7 days", etc.
  final TravelParty? travelParty; // solo, couple, family, group
  final DateTime? dataCollectionCompletedAt;
  final Map<String, bool> dataCollectionFlags; // Track what's been asked

  const UserPreferences({
    this.language,
    this.currency,
    this.notificationsEnabled = true,
    this.locationEnabled = true,
    this.interests = const [],
    // New fields
    this.countryOfOrigin,
    this.userType,
    this.visitPurpose,
    this.ageRange,
    this.gender,
    this.lengthOfStay,
    this.travelParty,
    this.dataCollectionCompletedAt,
    this.dataCollectionFlags = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      // Existing fields
      'language': language,
      'currency': currency,
      'notificationsEnabled': notificationsEnabled,
      'locationEnabled': locationEnabled,
      'interests': interests,
      // New fields
      'countryOfOrigin': countryOfOrigin,
      'userType': userType?.apiValue,
      'visitPurpose': visitPurpose?.apiValue,
      'ageRange': ageRange?.apiValue,
      'gender': gender?.apiValue,
      'lengthOfStay': lengthOfStay?.apiValue,
      'travelParty': travelParty?.apiValue,
      'dataCollectionCompletedAt': dataCollectionCompletedAt?.toIso8601String(),
      'dataCollectionFlags': dataCollectionFlags,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      // Existing fields
      language: json['language'],
      currency: json['currency'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      locationEnabled: json['locationEnabled'] ?? true,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'])
          : [],
      // New fields
      countryOfOrigin: json['countryOfOrigin'],
      userType: UserTypeExtension.fromString(json['userType']),
      visitPurpose: VisitPurposeExtension.fromString(json['visitPurpose']),
      ageRange: AgeRangeExtension.fromString(json['ageRange']),
      gender: GenderExtension.fromString(json['gender']),
      lengthOfStay: LengthOfStayExtension.fromString(json['lengthOfStay']),
      travelParty: TravelPartyExtension.fromString(json['travelParty']),
      dataCollectionCompletedAt: json['dataCollectionCompletedAt'] != null
          ? DateTime.tryParse(json['dataCollectionCompletedAt'])
          : null,
      dataCollectionFlags: json['dataCollectionFlags'] != null
          ? Map<String, bool>.from(json['dataCollectionFlags'])
          : {},
    );
  }

  /// Check if mandatory data collection is complete
  bool get isMandatoryDataComplete {
    return countryOfOrigin != null &&
        countryOfOrigin!.isNotEmpty &&
        userType != null &&
        visitPurpose != null &&
        language != null &&
        language!.isNotEmpty;
  }

  /// Get profile completion percentage (0-100)
  /// Note: lengthOfStay is only counted for visitors, not residents
  int get profileCompletionPercentage {
    // Base fields (always counted)
    int totalFields = 9; // Mandatory + optional fields (excluding lengthOfStay)
    
    // Add lengthOfStay to total only if user is a visitor
    if (userType == UserType.visitor) {
      totalFields = 10; // Include lengthOfStay for visitors
    }

    int completedFields = 0;

    if (countryOfOrigin != null && countryOfOrigin!.isNotEmpty) completedFields++;
    if (userType != null) completedFields++;
    if (visitPurpose != null) completedFields++;
    if (language != null && language!.isNotEmpty) completedFields++;
    if (ageRange != null) completedFields++;
    if (gender != null) completedFields++;
    // Only count lengthOfStay for visitors
    if (userType == UserType.visitor && lengthOfStay != null) completedFields++;
    if (travelParty != null) completedFields++;
    if (interests.isNotEmpty) completedFields++;
    if (currency != null && currency!.isNotEmpty) completedFields++;

    return totalFields > 0 ? ((completedFields / totalFields) * 100).round() : 0;
  }

  /// Create a copy with updated fields
  UserPreferences copyWith({
    String? language,
    String? currency,
    bool? notificationsEnabled,
    bool? locationEnabled,
    List<String>? interests,
    String? countryOfOrigin,
    UserType? userType,
    VisitPurpose? visitPurpose,
    AgeRange? ageRange,
    Gender? gender,
    LengthOfStay? lengthOfStay,
    TravelParty? travelParty,
    DateTime? dataCollectionCompletedAt,
    Map<String, bool>? dataCollectionFlags,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      interests: interests ?? this.interests,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      userType: userType ?? this.userType,
      visitPurpose: visitPurpose ?? this.visitPurpose,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      lengthOfStay: lengthOfStay ?? this.lengthOfStay,
      travelParty: travelParty ?? this.travelParty,
      dataCollectionCompletedAt: dataCollectionCompletedAt ?? this.dataCollectionCompletedAt,
      dataCollectionFlags: dataCollectionFlags ?? this.dataCollectionFlags,
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

// UX-First User Data Collection Enums
enum UserType {
  resident,
  visitor,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.resident:
        return 'Resident';
      case UserType.visitor:
        return 'Visitor';
    }
  }

  String get apiValue {
    switch (this) {
      case UserType.resident:
        return 'resident';
      case UserType.visitor:
        return 'visitor';
    }
  }

  static UserType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'resident':
        return UserType.resident;
      case 'visitor':
        return UserType.visitor;
      default:
        return null;
    }
  }
}

enum VisitPurpose {
  leisure,
  business,
  mice,
}

extension VisitPurposeExtension on VisitPurpose {
  String get displayName {
    switch (this) {
      case VisitPurpose.leisure:
        return 'Leisure';
      case VisitPurpose.business:
        return 'Business';
      case VisitPurpose.mice:
        return 'MICE';
    }
  }

  String get apiValue {
    switch (this) {
      case VisitPurpose.leisure:
        return 'leisure';
      case VisitPurpose.business:
        return 'business';
      case VisitPurpose.mice:
        return 'mice';
    }
  }

  static VisitPurpose? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'leisure':
        return VisitPurpose.leisure;
      case 'business':
        return VisitPurpose.business;
      case 'mice':
        return VisitPurpose.mice;
      default:
        return null;
    }
  }
}

enum AgeRange {
  rangeUnder18,
  range18_25,
  range26_35,
  range36_45,
  range46_55,
  range56Plus,
}

extension AgeRangeExtension on AgeRange {
  String get displayName {
    switch (this) {
      case AgeRange.rangeUnder18:
        return 'Under 18';
      case AgeRange.range18_25:
        return '18-25';
      case AgeRange.range26_35:
        return '26-35';
      case AgeRange.range36_45:
        return '36-45';
      case AgeRange.range46_55:
        return '46-55';
      case AgeRange.range56Plus:
        return '56+';
    }
  }

  String get apiValue {
    switch (this) {
      case AgeRange.rangeUnder18:
        return 'under-18';
      case AgeRange.range18_25:
        return '18-25';
      case AgeRange.range26_35:
        return '26-35';
      case AgeRange.range36_45:
        return '36-45';
      case AgeRange.range46_55:
        return '46-55';
      case AgeRange.range56Plus:
        return '56+';
    }
  }

  static AgeRange? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'under-18':
        return AgeRange.rangeUnder18;
      case '18-25':
        return AgeRange.range18_25;
      case '26-35':
        return AgeRange.range26_35;
      case '36-45':
        return AgeRange.range36_45;
      case '46-55':
        return AgeRange.range46_55;
      case '56+':
        return AgeRange.range56Plus;
      default:
        return null;
    }
  }
}

enum Gender {
  male,
  female,
  other,
  preferNotToSay,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }

  String get apiValue {
    switch (this) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
      case Gender.other:
        return 'other';
      case Gender.preferNotToSay:
        return 'prefer_not_to_say';
    }
  }

  static Gender? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      case 'other':
        return Gender.other;
      case 'prefer_not_to_say':
      case 'prefernottosay':
        return Gender.preferNotToSay;
      default:
        return null;
    }
  }
}

enum LengthOfStay {
  oneToThreeDays,
  fourToSevenDays,
  oneToTwoWeeks,
  twoWeeksPlus,
}

extension LengthOfStayExtension on LengthOfStay {
  String get displayName {
    switch (this) {
      case LengthOfStay.oneToThreeDays:
        return '1-3 days';
      case LengthOfStay.fourToSevenDays:
        return '4-7 days';
      case LengthOfStay.oneToTwoWeeks:
        return '1-2 weeks';
      case LengthOfStay.twoWeeksPlus:
        return '2+ weeks';
    }
  }

  String get apiValue {
    switch (this) {
      case LengthOfStay.oneToThreeDays:
        return '1-3 days';
      case LengthOfStay.fourToSevenDays:
        return '4-7 days';
      case LengthOfStay.oneToTwoWeeks:
        return '1-2 weeks';
      case LengthOfStay.twoWeeksPlus:
        return '2+ weeks';
    }
  }

  static LengthOfStay? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case '1-3 days':
      case '1-3days':
        return LengthOfStay.oneToThreeDays;
      case '4-7 days':
      case '4-7days':
        return LengthOfStay.fourToSevenDays;
      case '1-2 weeks':
      case '1-2weeks':
        return LengthOfStay.oneToTwoWeeks;
      case '2+ weeks':
      case '2+weeks':
        return LengthOfStay.twoWeeksPlus;
      default:
        return null;
    }
  }
}

enum TravelParty {
  solo,
  couple,
  family,
  group,
}

extension TravelPartyExtension on TravelParty {
  String get displayName {
    switch (this) {
      case TravelParty.solo:
        return 'Solo';
      case TravelParty.couple:
        return 'Couple';
      case TravelParty.family:
        return 'Family';
      case TravelParty.group:
        return 'Group';
    }
  }

  String get apiValue {
    switch (this) {
      case TravelParty.solo:
        return 'solo';
      case TravelParty.couple:
        return 'couple';
      case TravelParty.family:
        return 'family';
      case TravelParty.group:
        return 'group';
    }
  }

  static TravelParty? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'solo':
        return TravelParty.solo;
      case 'couple':
        return TravelParty.couple;
      case 'family':
        return TravelParty.family;
      case 'group':
        return TravelParty.group;
      default:
        return null;
    }
  }
}
