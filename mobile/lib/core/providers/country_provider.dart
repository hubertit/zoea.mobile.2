import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';
import '../services/countries_service.dart';

/// Provider for CountriesService
final countriesServiceProvider = Provider<CountriesService>((ref) {
  return CountriesService();
});

/// Provider for active countries list
final activeCountriesProvider = FutureProvider<List<Country>>((ref) async {
  final service = ref.watch(countriesServiceProvider);
  return service.getActiveCountries();
});

/// Provider for selected country with persistence
final selectedCountryProvider = StateNotifierProvider<SelectedCountryNotifier, AsyncValue<Country?>>((ref) {
  return SelectedCountryNotifier(ref);
});

class SelectedCountryNotifier extends StateNotifier<AsyncValue<Country?>> {
  final Ref ref;
  static const String _storageKey = 'selected_country_id';
  static const String _storageCodeKey = 'selected_country_code';

  SelectedCountryNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadSavedCountry();
  }

  /// Load saved country from storage or default to Rwanda
  Future<void> _loadSavedCountry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final countryId = prefs.getString(_storageKey);
      
      final service = ref.read(countriesServiceProvider);
      
      if (countryId != null) {
        // Load saved country
        try {
          final country = await service.getCountryById(countryId);
          state = AsyncValue.data(country);
        } catch (e) {
          // If saved country not found, default to Rwanda
          await _setDefaultCountry(service);
        }
      } else {
        // No saved country, default to Rwanda
        await _setDefaultCountry(service);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Set default country (Rwanda)
  Future<void> _setDefaultCountry(CountriesService service) async {
    try {
      final rwanda = await service.getCountryByCode('RW');
      if (rwanda != null) {
        state = AsyncValue.data(rwanda);
        await _saveCountry(rwanda);
      } else {
        // If Rwanda not found in DB, set null and let user choose
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  /// Select a new country
  Future<void> selectCountry(Country country) async {
    state = AsyncValue.data(country);
    await _saveCountry(country);
    
    // Invalidate providers that depend on country
    ref.invalidate(activeCountriesProvider);
  }

  /// Save country to storage
  Future<void> _saveCountry(Country country) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, country.id);
      await prefs.setString(_storageCodeKey, country.code2);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Get current country or null
  Country? get currentCountry {
    return state.value;
  }

  /// Get current country ID or null
  String? get currentCountryId {
    return state.value?.id;
  }

  /// Get current country code or null
  String? get currentCountryCode {
    return state.value?.code2;
  }

  /// Refresh country data
  Future<void> refresh() async {
    await _loadSavedCountry();
  }
}

