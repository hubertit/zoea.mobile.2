import 'dart:io';
import '../models/user.dart';

/// Service for inferring user data from device settings and context
/// Used for silent enrichment of existing users (4,500+)
class DataInferenceService {

  /// Infer country code from device locale
  /// Returns ISO country code (e.g., "RW", "US", "GB")
  Future<String?> inferCountryFromLocale() async {
    try {
      final locale = Platform.localeName;
      // Format: "en_US" or "en-US" -> extract country part
      final parts = locale.split(RegExp(r'[_-]'));
      if (parts.length >= 2) {
        final countryCode = parts[1].toUpperCase();
        // Validate it's a 2-letter country code
        if (countryCode.length == 2) {
          return countryCode;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Infer language code from device locale
  /// Returns language code (e.g., "en", "rw", "fr")
  Future<String?> inferLanguageFromLocale() async {
    try {
      final locale = Platform.localeName;
      // Format: "en_US" or "en-US" -> extract language part
      final parts = locale.split(RegExp(r'[_-]'));
      if (parts.isNotEmpty) {
        final languageCode = parts[0].toLowerCase();
        // Map common language codes
        return _mapLanguageCode(languageCode);
      }
      return 'en'; // Default to English
    } catch (e) {
      return 'en';
    }
  }

  /// Map device language code to our supported languages
  String _mapLanguageCode(String code) {
    switch (code.toLowerCase()) {
      case 'en':
        return 'en';
      case 'rw':
      case 'kin':
        return 'rw';
      case 'fr':
        return 'fr';
      case 'sw':
        return 'sw';
      default:
        return 'en'; // Default to English
    }
  }

  /// Infer user type (resident vs visitor) based on country
  /// If country is Rwanda (RW), assume resident, otherwise visitor
  Future<UserType?> inferUserType({String? countryCode}) async {
    try {
      final country = countryCode ?? await inferCountryFromLocale();
      if (country == null) return null;

      // If country is Rwanda, likely a resident
      // Otherwise, likely a visitor
      return country.toUpperCase() == 'RW' ? UserType.resident : UserType.visitor;
    } catch (e) {
      return null;
    }
  }

  /// Get device country code (for Android/iOS specific detection)
  /// This is a more reliable method than locale parsing
  Future<String?> getDeviceCountryCode() async {
    try {
      if (Platform.isAndroid) {
        // Android doesn't directly provide country, but we can use locale
        return await inferCountryFromLocale();
      } else if (Platform.isIOS) {
        // iOS doesn't directly provide country either
        return await inferCountryFromLocale();
      }
      return await inferCountryFromLocale();
    } catch (e) {
      return null;
    }
  }

  /// Infer all possible data from device
  /// Returns a map with inferred values
  Future<Map<String, dynamic>> inferAllData() async {
    try {
      final country = await getDeviceCountryCode();
      final language = await inferLanguageFromLocale();
      final userType = await inferUserType(countryCode: country);

      return {
        'countryOfOrigin': country,
        'language': language,
        'userType': userType,
      };
    } catch (e) {
      return {};
    }
  }

  /// Check if country is Rwanda
  bool isRwanda(String? countryCode) {
    return countryCode?.toUpperCase() == 'RW';
  }

  /// Get default country if inference fails
  /// Defaults to Rwanda for Zoea app
  String getDefaultCountry() {
    return 'RW';
  }

  /// Get default language if inference fails
  String getDefaultLanguage() {
    return 'en';
  }
}

