/// Helper pemformatan dan parsing tipe data JSON yang dinamis dari backend.
class JsonHelper {
  /// Mengonversi nilai dynamic (int, num, string angka) ke int dengan aman.
  static int asInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  /// Mengonversi nilai dynamic (double, num, string angka) ke double dengan aman.
  static double asDouble(dynamic v, [double fallback = 0.0]) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? fallback;
  }

  /// Mengonversi nilai dynamic ke String dengan aman (null/kosong -> fallback).
  static String asString(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    if (v is String) return v;
    return v.toString();
  }

  /// Mengonversi nilai dynamic (bool, int 1/0, string '1'/'0'/'true') ke bool dengan aman.
  static bool asBool(dynamic v, [bool fallback = false]) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes' || s == 'ya') return true;
      if (s == 'false' || s == '0' || s == 'no' || s == 'tidak') return false;
    }
    return fallback;
  }
}
