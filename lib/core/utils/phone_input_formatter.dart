import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 9 digits for Rwandan numbers
    if (digitsOnly.length > 9) {
      return oldValue;
    }
    
    // Format as 07X XXX XXX
    if (digitsOnly.length >= 3) {
      final formatted = '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}
