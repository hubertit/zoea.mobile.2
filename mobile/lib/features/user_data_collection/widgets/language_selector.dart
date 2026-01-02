import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/text_theme_extensions.dart';

/// Widget for selecting language
/// Auto-detects language and allows user to change
class LanguageSelector extends StatelessWidget {
  final String? selectedLanguage;
  final String? autoDetectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    this.autoDetectedLanguage,
    required this.onLanguageSelected,
  });

  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'rw', 'name': 'Kinyarwanda', 'native': 'Ikinyarwanda'},
    {'code': 'fr', 'name': 'French', 'native': 'Français'},
    {'code': 'sw', 'name': 'Swahili', 'native': 'Kiswahili'},
  ];

  String _getLanguageName(String code) {
    final language = _languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code, 'native': code},
    );
    return language['name'] ?? code;
  }

  String _getLanguageNative(String code) {
    final language = _languages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'code': code, 'name': code, 'native': code},
    );
    return language['native'] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    // Show auto-detected language first if available
    final languagesToShow = autoDetectedLanguage != null &&
            !_languages.any((lang) => lang['code'] == autoDetectedLanguage)
        ? [
            {
              'code': autoDetectedLanguage!,
              'name': autoDetectedLanguage!,
              'native': autoDetectedLanguage!
            },
            ..._languages
          ]
        : _languages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (autoDetectedLanguage != null && selectedLanguage == null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
            child: _buildAutoDetectedCard(context),
          ),
        Wrap(
          spacing: AppTheme.spacing8,
          runSpacing: AppTheme.spacing8,
          children: languagesToShow.map((lang) {
            final code = lang['code']!;
            final isSelected = selectedLanguage == code;
            final isAutoDetected = autoDetectedLanguage == code;

            return FilterChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getLanguageName(code),
                    style: context.bodyMedium.copyWith(
                      color: isSelected
                          ? context.primaryColorTheme
                          : context.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (_getLanguageNative(code) != _getLanguageName(code))
                    Text(
                      _getLanguageNative(code),
                      style: context.bodySmall.copyWith(
                        color: isSelected
                            ? context.primaryColorTheme.withOpacity(0.8)
                            : context.secondaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onLanguageSelected(code),
              selectedColor: context.primaryColorTheme.withOpacity(0.2),
              checkmarkColor: context.primaryColorTheme,
              backgroundColor: isAutoDetected && !isSelected
                  ? context.primaryColorTheme.withOpacity(0.1)
                  : context.backgroundColor,
              side: BorderSide(
                color: isSelected
                    ? context.primaryColorTheme
                    : isAutoDetected
                        ? context.primaryColorTheme.withOpacity(0.3)
                        : context.dividerColor,
                width: isSelected ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAutoDetectedCard(BuildContext context) {
    if (autoDetectedLanguage == null) return const SizedBox.shrink();

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
            Icons.translate,
            color: context.primaryColorTheme,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              'We detected ${_getLanguageName(autoDetectedLanguage!)}',
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

