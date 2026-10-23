import 'package:intl/intl.dart';

/// Helper pemformatan angka menggunakan standard intl.
class NumberFormatHelper {
  static final NumberFormat _dotFormat = NumberFormat('#,###', 'id_ID');

  /// Format angka dengan titik pemisah ribuan (misal: 1000 -> "1.000")
  static String formatWithDots(dynamic number) {
    if (number == null) return '0';
    if (number is num) return _dotFormat.format(number);
    final parsed = num.tryParse(number.toString());
    return parsed != null ? _dotFormat.format(parsed) : number.toString();
  }

  /// Format desimal dengan koma pemisah (misal: 82.8 -> "82,8")
  static String formatDecimalWithComma(double number, {int decimals = 1}) {
    return NumberFormat.decimalPatternDigits(
      locale: 'id_ID',
      decimalDigits: decimals,
    ).format(number);
  }

  /// Format persentase (misal: 0.828 -> "82,8%")
  static String formatPercentage(double value, {int decimals = 1}) {
    final fmt = NumberFormat.percentPattern('id_ID')
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return fmt.format(value);
  }

  /// Format ringkas jutaan/ribuan (misal: 3500000 -> "3,5jt", 4000000 -> "4jt")
  static String formatCompactJt(int val) {
    if (val <= 0) return '';
    if (val >= 1000000) {
      final inJt = val / 1000000;
      final formatted = (inJt == inJt.roundToDouble())
          ? inJt.toInt().toString()
          : inJt.toStringAsFixed(1).replaceAll('.', ',');
      return '${formatted}jt';
    }
    if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}rb';
    }
    return val.toString();
  }

  /// Format rentang gaji ringkas (misal: 3500000 & 4000000 -> "3,5jt - 4jt")
  static String formatSalaryRange(int min, int max) {
    if (min <= 0 && max <= 0) return 'Gaji Dirahasiakan';
    final minStr = formatCompactJt(min);
    final maxStr = formatCompactJt(max);
    if (minStr.isNotEmpty && maxStr.isNotEmpty) {
      return '$minStr - $maxStr';
    }
    return minStr.isNotEmpty ? minStr : maxStr;
  }
}
