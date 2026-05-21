/// Controls which character is inserted between groups of thousands.
enum ThousandSeparator {
  /// Uses a comma: `1,000,000`
  comma,

  /// Uses a period: `1.000.000`
  period;

  /// The actual character string for this separator.
  String get character => switch (this) {
    ThousandSeparator.comma => ',',
    ThousandSeparator.period => '.',
  };
}

/// Controls which character is used as the decimal point.
enum DecimalSeparator {
  /// Uses a comma: `1.000,99`
  comma,

  /// Uses a period: `1,000.99`
  period;

  /// The actual character string for this separator.
  String get character => switch (this) {
    DecimalSeparator.comma => ',',
    DecimalSeparator.period => '.',
  };
}

/// Controls how many decimal digits are accepted.
enum DecimalDigits {
  /// No decimal input — the decimal separator is ignored.
  zero,

  /// Up to two decimal digits.
  two;

  /// The numeric value of this digit count.
  int get value => switch (this) {
    DecimalDigits.zero => 0,
    DecimalDigits.two => 2,
  };
}
