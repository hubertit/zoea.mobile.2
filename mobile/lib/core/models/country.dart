/// Country model for app operation countries
class Country {
  final String id;
  final String name;
  final String code; // ISO 3-letter code (RWA, KEN, UGA, TZA)
  final String code2; // ISO 2-letter code (RW, KE, UG, TZ)
  final String? phoneCode;
  final String? currencyCode;
  final String? currencySymbol;
  final String? flagEmoji;
  final String? defaultLanguage;
  final List<String>? supportedLanguages;
  final String? timezone;
  final bool isActive;
  final DateTime? launchedAt;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.code2,
    this.phoneCode,
    this.currencyCode,
    this.currencySymbol,
    this.flagEmoji,
    this.defaultLanguage,
    this.supportedLanguages,
    this.timezone,
    required this.isActive,
    this.launchedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      code2: json['code2'] as String,
      phoneCode: json['phoneCode'] as String?,
      currencyCode: json['currencyCode'] as String?,
      currencySymbol: json['currencySymbol'] as String?,
      flagEmoji: json['flagEmoji'] as String?,
      defaultLanguage: json['defaultLanguage'] as String?,
      supportedLanguages: json['supportedLanguages'] != null
          ? List<String>.from(json['supportedLanguages'] as List)
          : null,
      timezone: json['timezone'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      launchedAt: json['launchedAt'] != null
          ? DateTime.parse(json['launchedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'code2': code2,
      'phoneCode': phoneCode,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'flagEmoji': flagEmoji,
      'defaultLanguage': defaultLanguage,
      'supportedLanguages': supportedLanguages,
      'timezone': timezone,
      'isActive': isActive,
      'launchedAt': launchedAt?.toIso8601String(),
    };
  }

  Country copyWith({
    String? id,
    String? name,
    String? code,
    String? code2,
    String? phoneCode,
    String? currencyCode,
    String? currencySymbol,
    String? flagEmoji,
    String? defaultLanguage,
    List<String>? supportedLanguages,
    String? timezone,
    bool? isActive,
    DateTime? launchedAt,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      code2: code2 ?? this.code2,
      phoneCode: phoneCode ?? this.phoneCode,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      timezone: timezone ?? this.timezone,
      isActive: isActive ?? this.isActive,
      launchedAt: launchedAt ?? this.launchedAt,
    );
  }

  @override
  String toString() => 'Country(name: $name, code: $code2, flagEmoji: $flagEmoji)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

