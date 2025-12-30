import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for selecting country of origin
/// Uses chip-based selection with auto-detected country highlighted
class CountrySelector extends StatelessWidget {
  final String? selectedCountry;
  final String? autoDetectedCountry;
  final Function(String) onCountrySelected;
  final List<String> commonCountries;

  const CountrySelector({
    super.key,
    required this.selectedCountry,
    this.autoDetectedCountry,
    required this.onCountrySelected,
    this.commonCountries = const [
      'RW', // Rwanda
      'US', // United States
      'GB', // United Kingdom
      'KE', // Kenya
      'UG', // Uganda
      'TZ', // Tanzania
      'ZA', // South Africa
      'NG', // Nigeria
      'FR', // France
      'DE', // Germany
      'IT', // Italy
      'ES', // Spain
      'CA', // Canada
      'AU', // Australia
      'IN', // India
      'CN', // China
      'JP', // Japan
      'BR', // Brazil
    ],
  });

  String _getCountryName(String code) {
    const countryNames = {
      'RW': 'Rwanda',
      'US': 'United States',
      'GB': 'United Kingdom',
      'KE': 'Kenya',
      'UG': 'Uganda',
      'TZ': 'Tanzania',
      'ZA': 'South Africa',
      'NG': 'Nigeria',
      'FR': 'France',
      'DE': 'Germany',
      'IT': 'Italy',
      'ES': 'Spain',
      'CA': 'Canada',
      'AU': 'Australia',
      'IN': 'India',
      'CN': 'China',
      'JP': 'Japan',
      'BR': 'Brazil',
    };
    return countryNames[code] ?? code;
  }

  String _getCountryFlag(String code) {
    // Simple emoji flags for common countries
    const flags = {
      'RW': '🇷🇼',
      'US': '🇺🇸',
      'GB': '🇬🇧',
      'KE': '🇰🇪',
      'UG': '🇺🇬',
      'TZ': '🇹🇿',
      'ZA': '🇿🇦',
      'NG': '🇳🇬',
      'FR': '🇫🇷',
      'DE': '🇩🇪',
      'IT': '🇮🇹',
      'ES': '🇪🇸',
      'CA': '🇨🇦',
      'AU': '🇦🇺',
      'IN': '🇮🇳',
      'CN': '🇨🇳',
      'JP': '🇯🇵',
      'BR': '🇧🇷',
    };
    return flags[code] ?? '🌍';
  }

  @override
  Widget build(BuildContext context) {
    // Show auto-detected country first if available
    final countriesToShow = autoDetectedCountry != null &&
            !commonCountries.contains(autoDetectedCountry)
        ? [autoDetectedCountry!, ...commonCountries]
        : commonCountries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (autoDetectedCountry != null && selectedCountry == null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
            child: _buildAutoDetectedCard(),
          ),
        Wrap(
          spacing: AppTheme.spacing8,
          runSpacing: AppTheme.spacing8,
          children: countriesToShow.map((countryCode) {
            final isSelected = selectedCountry == countryCode;
            final isAutoDetected = autoDetectedCountry == countryCode;

            return FilterChip(
              avatar: Text(
                _getCountryFlag(countryCode),
                style: const TextStyle(fontSize: 20),
              ),
              label: Text(
                _getCountryName(countryCode),
                style: AppTheme.bodyMedium.copyWith(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.primaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onCountrySelected(countryCode),
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
              backgroundColor: isAutoDetected && !isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : AppTheme.backgroundColor,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryColor
                    : isAutoDetected
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : AppTheme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing12,
                vertical: AppTheme.spacing8,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAutoDetectedCard() {
    if (autoDetectedCountry == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              'We detected ${_getCountryName(autoDetectedCountry!)} ${_getCountryFlag(autoDetectedCountry!)}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

