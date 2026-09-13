// ============================================================================
// Date Format Helper
// ============================================================================
// Helper untuk formatting tanggal ke format Indonesia

import 'package:intl/intl.dart';

class DateFormatHelper {
  /// Pre-clean and parse date string regardless of ISO format, DD-MM-YYYY, trailing Z, or time components.
  static DateTime? parseDate(String input) {
    if (input.trim().isEmpty) return null;
    try {
      String clean = input.trim();
      if (clean.startsWith('0000') || clean.startsWith('0001')) return null;
      // Remove trailing Z or z
      if (clean.toLowerCase().endsWith('z')) {
        clean = clean.substring(0, clean.length - 1).trim();
      }
      // Remove time component if T or space separator exists
      if (clean.contains('T')) {
        clean = clean.split('T')[0].trim();
      } else if (clean.contains(' ')) {
        clean = clean.split(' ')[0].trim();
      }

      // Check if format is DD-MM-YYYY or DD/MM/YYYY
      final dmYMatch = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$').firstMatch(clean);
      if (dmYMatch != null) {
        final day = int.parse(dmYMatch.group(1)!);
        final month = int.parse(dmYMatch.group(2)!);
        final year = int.parse(dmYMatch.group(3)!);
        if (year <= 1) return null;
        return DateTime(year, month, day);
      }

      // Check if format is YYYY-MM-DD or YYYY/MM/DD
      final yMDMatch = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$').firstMatch(clean);
      if (yMDMatch != null) {
        final year = int.parse(yMDMatch.group(1)!);
        final month = int.parse(yMDMatch.group(2)!);
        final day = int.parse(yMDMatch.group(3)!);
        if (year <= 1) return null;
        return DateTime(year, month, day);
      }

      final dt = DateTime.tryParse(clean);
      if (dt != null && dt.year <= 1) return null;
      return dt;
    } catch (_) {
      return null;
    }
  }

  /// Format tanggal ke format Indonesia (dd MMMM yyyy)
  /// Input: "2028-03-08T00:00:00Z" atau "08-03-2028Z"
  /// Output: "08 Maret 2028"
  static String formatToIndonesian(String dateString) {
    final cleanStr = dateString.trim();
    if (cleanStr.isEmpty || cleanStr == '-' || cleanStr.startsWith('0000') || cleanStr.startsWith('0001')) return '-';
    final parsed = parseDate(cleanStr);
    if (parsed != null) {
      try {
        final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
        return formatter.format(parsed);
      } catch (_) {
        final formatter = DateFormat('dd MMMM yyyy');
        return formatter.format(parsed);
      }
    }
    // Fallback: strip Z and time if parse fails
    String clean = cleanStr.replaceAll(RegExp(r'[Zz]'), '').trim();
    if (clean.contains('T')) clean = clean.split('T')[0];
    return clean;
  }

  /// Format tanggal beserta jam ke format Indonesia
  /// Input: "2026-03-16T15:04:45Z" atau "2026-03-16 15:04:45"
  /// Output: "16 Maret 2026, 15:04 WIB"
  static String formatToIndonesianWithTime(String dateString) {
    if (dateString.trim().isEmpty || dateString == '-') return '-';
    try {
      DateTime? dt = DateTime.tryParse(dateString.trim());
      if (dt != null) {
        dt = dt.toLocal();
        try {
          final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
          return '${formatter.format(dt)} WIB';
        } catch (_) {
          final formatter = DateFormat('dd MMMM yyyy, HH:mm');
          return '${formatter.format(dt)} WIB';
        }
      }
    } catch (_) {}
    return formatToIndonesian(dateString);
  }

  /// Format a backend timestamp emitted without an offset as Jakarta time.
  /// Input: "2026-09-11 14:48:35"; output includes seconds and WIB.
  static String formatJakartaWithSeconds(String dateString) {
    final clean = dateString.trim();
    if (clean.isEmpty || clean == '-' || clean.startsWith('0000') || clean.startsWith('0001')) {
      return '-';
    }

    try {
      DateTime? parsed;
      if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$').hasMatch(clean)) {
        parsed = DateTime.parse('${clean.replaceFirst(' ', 'T')}+07:00');
      } else {
        parsed = DateTime.tryParse(clean)?.toLocal();
      }
      if (parsed == null) return clean;
      final formatter = DateFormat('dd MMMM yyyy, HH:mm:ss', 'id_ID');
      return '${formatter.format(parsed)} WIB';
    } catch (_) {
      return clean;
    }
  }

  /// Format tanggal ke format pendek (dd-MM-yyyy)
  /// Input: "2028-03-08Z"
  /// Output: "08-03-2028"
  static String formatToShort(String dateString) {
    if (dateString.trim().isEmpty || dateString == '-') return '-';
    final parsed = parseDate(dateString);
    if (parsed != null) {
      final formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(parsed);
    }
    return dateString.replaceAll(RegExp(r'[Zz]'), '').trim();
  }

  /// Format tanggal ke format lengkap Indonesia
  /// Input: "2028-03-08"
  /// Output: "Rabu, 08 Maret 2028"
  static String formatToLong(String dateString) {
    if (dateString.trim().isEmpty || dateString == '-') return '-';
    final parsed = parseDate(dateString);
    if (parsed != null) {
      try {
        final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
        return formatter.format(parsed);
      } catch (_) {
        final formatter = DateFormat('EEEE, dd MMMM yyyy');
        return formatter.format(parsed);
      }
    }
    return dateString.replaceAll(RegExp(r'[Zz]'), '').trim();
  }

  /// Hitung selisih hari dari sekarang
  /// Input: "2026-06-15"
  /// Output: 16 (jika hari ini 30 Mei 2026)
  static int daysFromNow(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      return date.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Format periode bulan ini dalam bahasa Indonesia (MMMM yyyy)
  /// Contoh: "September 2026"
  static String formatCurrentMonthPeriod([DateTime? date]) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final target = date ?? DateTime.now();
    return '${months[target.month - 1]} ${target.year}';
  }
}
