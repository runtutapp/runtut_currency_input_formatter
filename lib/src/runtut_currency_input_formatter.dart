import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:runtut_currency_input_formatter/src/enums.dart';

/// A [TextInputFormatter] that formats numeric input as a currency value.
///
/// Separators are derived from [locale]; decimal digits are derived from
/// [currencyCode] (ISO 4217 — e.g. `'IDR'` → 0, `'USD'` → 2).
///
/// Example:
/// ```dart
/// CurrencyInputFormatter(locale: 'id_ID', currencyCode: 'IDR')
/// CurrencyInputFormatter(locale: 'en_US', currencyCode: 'USD')
/// ```
class CurrencyInputFormatter extends TextInputFormatter {
  /// Locale code used to derive thousand and decimal separators.
  final String locale;

  /// ISO 4217 currency code used to derive decimal digit count.
  final String currencyCode;

  final ThousandSeparator _thousandSeparator;
  final DecimalSeparator _decimalSeparator;
  final DecimalDigits _decimalDigits;

  CurrencyInputFormatter({this.locale = 'id_ID', this.currencyCode = 'IDR'})
    : _decimalSeparator =
          NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP == '.'
          ? DecimalSeparator.period
          : DecimalSeparator.comma,
      _thousandSeparator =
          NumberFormat.decimalPattern(locale).symbols.GROUP_SEP == '.'
          ? ThousandSeparator.period
          : ThousandSeparator.comma,
      _decimalDigits = _digitsFor(currencyCode);

  // ISO 4217 currencies with 0 minor units.
  static DecimalDigits _digitsFor(String code) {
    const zero = {
      'BIF',
      'CLP',
      'DJF',
      'GNF',
      'IDR',
      'ISK',
      'JPY',
      'KMF',
      'KRW',
      'PYG',
      'RWF',
      'UGX',
      'VND',
      'VUV',
      'XAF',
      'XOF',
      'XPF',
    };
    return zero.contains(code.toUpperCase())
        ? DecimalDigits.zero
        : DecimalDigits.two;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final isDeletion = newValue.text.length < oldValue.text.length;

    String input = newValue.text;
    int cursorPos = newValue.selection.baseOffset.clamp(0, input.length);

    // Only digits and the decimal separator are meaningful input —
    // thousand separators are injected by the formatter, not typed.
    final digitAndDecimal = RegExp(
      '[^\\d${RegExp.escape(_decimalSeparator.character)}]',
    );

    final cleanNew = newValue.text.replaceAll(digitAndDecimal, '');
    final cleanOld = oldValue.text.replaceAll(digitAndDecimal, '');

    if (cleanNew == cleanOld && !isDeletion) {
      return oldValue;
    }

    if (cleanNew == cleanOld && isDeletion) {
      final deletedChar = cursorPos < oldValue.text.length
          ? oldValue.text[cursorPos]
          : '';
      // only skip if what was deleted was a formatter-injected thousand separator
      if (deletedChar != _thousandSeparator.character) {
        return oldValue;
      }
    }

    // No decimal separator allowed when _decimalDigits is 0
    if (_decimalDigits.value == 0 &&
        cleanNew.contains(_decimalSeparator.character) &&
        !cleanOld.contains(_decimalSeparator.character)) {
      return oldValue;
    }

    // Thousand separator is formatter-injected — when the user backspaces
    // onto one, consume the real digit to its left instead.
    if (isDeletion && cursorPos < oldValue.text.length) {
      final deletedChar = oldValue.text[cursorPos];
      if (deletedChar == _thousandSeparator.character) {
        input = input.substring(0, cursorPos - 1) + input.substring(cursorPos);
        cursorPos -= 1;
      }
    }

    // Anchor cursor by how far it sits from the right edge —
    // thousand separators shift the left side, never the right.
    final int charsFromEnd = input.length - cursorPos;

    // Strip everything except digits and decimal separator
    input = input.replaceAll(digitAndDecimal, '');

    // Bare decimal separator with no leading digit — treat as '0,'
    if (input == _decimalSeparator.character) {
      return TextEditingValue(
        text: '0${_decimalSeparator.character}',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    // Split on decimal separator
    List<String> parts = input.split(_decimalSeparator.character);

    // Multiple decimal separators typed — only first one counts
    if (parts.length > 2) {
      input =
          '${parts[0]}${_decimalSeparator.character}${parts.sublist(1).join('')}';
      parts = input.split(_decimalSeparator.character);
    }

    if (parts.length == 2) {
      if (_decimalDigits.value == 0) {
        // Drop the decimal part entirely
        parts = [parts[0]];
      } else if (parts[1].length > _decimalDigits.value) {
        parts[1] = parts[1].substring(0, _decimalDigits.value);
      }
    }

    // Inject thousand separators into the integer part
    String integerPart = parts[0];

    if (integerPart.length > 3) {
      integerPart = integerPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}${_thousandSeparator.character}',
      );
    }

    final formatted = parts.length == 2
        ? '$integerPart${_decimalSeparator.character}${parts[1]}'
        : integerPart;

    // Recompute cursor position from the right-side anchor
    int displayCursor = (formatted.length - charsFromEnd).clamp(
      0,
      formatted.length,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: displayCursor),
    );
  }
}
