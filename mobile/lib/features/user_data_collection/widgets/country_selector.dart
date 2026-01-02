import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';

/// Widget for selecting country of origin
/// Uses standard country_picker package for consistency with app design patterns
class CountrySelector extends StatelessWidget {
  final String? selectedCountry; // ISO 2-letter code (e.g., "RW", "US")
  final String? autoDetectedCountry; // ISO 2-letter code
  final Function(String) onCountrySelected; // Returns ISO 2-letter code

  const CountrySelector({
    super.key,
    required this.selectedCountry,
    this.autoDetectedCountry,
    required this.onCountrySelected,
  });

  /// Get country name from ISO code
  String? _getCountryName(String? code) {
    if (code == null) return null;
    try {
      final country = Country.parse(code);
      return country.name;
    } catch (e) {
      return code;
    }
  }

  /// Get country flag emoji from ISO code
  String _getCountryFlag(String? code) {
    if (code == null) return '🌍';
    try {
      final country = Country.parse(code);
      return country.flagEmoji;
    } catch (e) {
      return '🌍';
    }
  }

  /// Show country picker bottom sheet
  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false, // We don't need phone codes for country of origin
      favorite: autoDetectedCountry != null
          ? [autoDetectedCountry!]
          : [],
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: context.backgroundColor,
        textStyle: context.bodyLarge.copyWith(
          color: context.primaryTextColor,
        ),
        searchTextStyle: context.bodyMedium.copyWith(
          color: context.primaryTextColor,
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search country',
          hintText: 'Start typing to search',
          prefixIcon: Icon(Icons.search, color: context.secondaryTextColor),
          filled: true,
          fillColor: context.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            borderSide: BorderSide(
              color: context.dividerColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            borderSide: BorderSide(
              color: context.dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            borderSide: BorderSide(
              color: context.primaryColorTheme,
              width: 2,
            ),
          ),
        ),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      onSelect: (Country country) {
        // Return ISO 2-letter code
        onCountrySelected(country.countryCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Auto-detected country hint
        if (autoDetectedCountry != null && selectedCountry == null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
            child: _buildAutoDetectedCard(context),
          ),
        // Country selection button
        InkWell(
          onTap: () => _showCountryPicker(context),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
              border: Border.all(
                color: selectedCountry != null
                    ? context.primaryColorTheme
                    : context.dividerColor,
                width: selectedCountry != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag
                Text(
                  _getCountryFlag(selectedCountry ?? autoDetectedCountry),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppTheme.spacing12),
                // Country name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCountry != null
                            ? _getCountryName(selectedCountry) ?? 'Select country'
                            : autoDetectedCountry != null
                                ? '${_getCountryName(autoDetectedCountry)} (Detected)'
                                : 'Select your country',
                        style: context.bodyLarge.copyWith(
                          color: selectedCountry != null
                              ? context.primaryTextColor
                              : context.secondaryTextColor,
                          fontWeight: selectedCountry != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (selectedCountry == null && autoDetectedCountry != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppTheme.spacing4),
                          child: Text(
                            'Tap to change',
                            style: context.bodySmall.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Chevron icon
                Icon(
                  Icons.chevron_right,
                  color: context.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoDetectedCard(BuildContext context) {
    if (autoDetectedCountry == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: context.primaryColorTheme.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(
          color: context.primaryColorTheme.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: context.primaryColorTheme,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              'We detected ${_getCountryName(autoDetectedCountry)} ${_getCountryFlag(autoDetectedCountry)}',
              style: context.bodySmall.copyWith(
                color: context.primaryColorTheme,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

