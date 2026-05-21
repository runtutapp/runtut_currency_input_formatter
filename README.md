# runtut_currency_input_formatter

A lightweight Flutter package for formatting currency input fields.

Pass a locale and an ISO 4217 currency code — separators and decimal digits are derived automatically.

---

## Why

Most currency formatters either hardcode a locale or make you configure separators by hand. This one takes a locale and a currency code and figures out the rest: `id_ID` + `IDR` gives you `.` thousands and `,` decimal with no decimal places; `en_US` + `USD` gives you `,` thousands and `.` decimal with 2 places.

---

## Usage

```dart
import 'package:runtut_currency_input_formatter/runtut_currency_input_formatter.dart';

TextField(
  inputFormatters: [
    CurrencyInputFormatter(locale: 'id_ID', currencyCode: 'IDR'),
  ],
)
```

### IDR — `1.000.000`

```dart
CurrencyInputFormatter() // defaults to locale: 'id_ID', currencyCode: 'IDR'
```

### USD — `1,000,000.99`

```dart
CurrencyInputFormatter(locale: 'en_US', currencyCode: 'USD')
```

### EUR — `1.000.000,99`

```dart
CurrencyInputFormatter(locale: 'de_DE', currencyCode: 'EUR')
```

### JPY — `1,000,000`

```dart
CurrencyInputFormatter(locale: 'ja_JP', currencyCode: 'JPY')
```

---

## Options

| Parameter      | Type     | Default   | Description                                          |
| -------------- | -------- | --------- | ---------------------------------------------------- |
| `locale`       | `String` | `'id_ID'` | Locale code — determines thousand and decimal separators |
| `currencyCode` | `String` | `'IDR'`   | ISO 4217 currency code — determines decimal digit count  |

Currencies with 0 decimal places (e.g. `IDR`, `JPY`, `KRW`, `VND`) reject decimal input entirely. All others use 2 decimal places.

---

## Notes

- Cursor position is preserved correctly across formatting changes
- Thousand separators injected by the formatter are transparent to backspace — deleting one consumes the digit to its left instead

---

Built with care. Extracted from [Runtut](https://runtut.app) — a financial journal for everyday spending.
