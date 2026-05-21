import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runtut_currency_input_formatter/runtut_currency_input_formatter.dart';

TextEditingValue val(String text, {int? cursor}) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

TextEditingValue format(
  CurrencyInputFormatter f,
  String oldText,
  String newText, {
  int? oldCursor,
  int? newCursor,
}) => f.formatEditUpdate(
  val(oldText, cursor: oldCursor),
  val(newText, cursor: newCursor),
);

void main() {
  group(
    'CurrencyInputFormatter — IDR (period thousand, comma decimal, 0dp)',
    () {
      final f = CurrencyInputFormatter();

      test('empty input passes through', () {
        final result = format(f, '', '');
        expect(result.text, '');
      });

      test('digits under 4 get no separator', () {
        expect(format(f, '', '1').text, '1');
        expect(format(f, '', '123').text, '123');
      });

      test('4 digits get one thousand separator', () {
        expect(format(f, '', '1000').text, '1.000');
      });

      test('7 digits get two thousand separators', () {
        expect(format(f, '', '1000000').text, '1.000.000');
      });

      test('10 digits get three thousand separators', () {
        expect(format(f, '', '1000000000').text, '1.000.000.000');
      });

      test('decimal separator input is rejected', () {
        expect(format(f, '1', '1,').text, '1');
      });

      test('non-digit non-separator characters are stripped', () {
        expect(format(f, '', '1a2b3').text, '123');
      });
    },
  );

  group(
    'CurrencyInputFormatter — USD (comma thousand, period decimal, 2dp)',
    () {
      final f = CurrencyInputFormatter(locale: 'en_US', currencyCode: 'USD');

      test('4 digits use comma as thousand separator', () {
        expect(format(f, '', '1000').text, '1,000');
      });

      test('decimal uses period', () {
        expect(format(f, '', '1000.50').text, '1,000.50');
      });

      test('decimal part is preserved up to 2 digits', () {
        expect(format(f, '', '1000.5').text, '1,000.5');
        expect(format(f, '', '1000.50').text, '1,000.50');
      });

      test('decimal part is truncated to 2 digits', () {
        expect(format(f, '', '1.999').text, '1.99');
      });

      test('bare decimal separator becomes 0.', () {
        expect(format(f, '', '.').text, '0.');
      });

      test('multiple decimal separators — only first counts', () {
        expect(format(f, '1.2', '1.2.3').text, '1.23');
      });
    },
  );

  group(
    'CurrencyInputFormatter — EUR via de_DE (period thousand, comma decimal, 2dp)',
    () {
      final f = CurrencyInputFormatter(locale: 'de_DE', currencyCode: 'EUR');

      test('4 digits use dot as thousand separator', () {
        expect(format(f, '', '1000').text, '1.000');
      });

      test('decimal uses comma', () {
        expect(format(f, '', '1000,50').text, '1.000,50');
      });

      test('bare comma becomes 0,', () {
        expect(format(f, '', ',').text, '0,');
      });
    },
  );

  group('CurrencyInputFormatter — JPY (period thousand, no decimal)', () {
    final f = CurrencyInputFormatter(locale: 'ja_JP', currencyCode: 'JPY');

    test('decimal separator input is rejected', () {
      expect(format(f, '1', '1.').text, '1');
    });

    test('thousand separators still applied', () {
      expect(format(f, '', '2500').text, '2,500');
    });
  });

  group('CurrencyInputFormatter — deletion', () {
    final f = CurrencyInputFormatter();

    test('deleting a regular digit reformats', () {
      // "1.000" → user deletes last '0' → "100"
      final result = format(f, '1.000', '1.00', oldCursor: 5, newCursor: 4);
      expect(result.text, '100');
    });

    test(
      'cursor anchors to right side after thousand separator is removed',
      () {
        // "1.000.000" → remove middle group digit → "100.000"
        final result = format(
          f,
          '1.000.000',
          '1.00.000',
          oldCursor: 4,
          newCursor: 3,
        );
        expect(result.text, '100.000');
      },
    );
  });
}
