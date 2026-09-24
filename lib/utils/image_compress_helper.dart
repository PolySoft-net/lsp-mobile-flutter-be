import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressHelper {
  const ImageCompressHelper._();

  static const List<String> _imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  static bool isImage(String filePath) {
    final lower = filePath.toLowerCase();
    return _imageExtensions.any((ext) => lower.endsWith(ext));
  }

  static Future<String> compressImage(
    String filePath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 80,
  }) async {
    if (!isImage(filePath)) {
      return filePath;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return filePath;
      }

      final fileName = filePath.split(Platform.pathSeparator).last.split('/').last;
      final targetPath =
          '${Directory.systemTemp.path}/cmp_${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
      );

      if (compressed != null && await File(compressed.path).exists()) {
        return compressed.path;
      }
    } catch (_) {
      // Fallback safely to original file if compression fails
    }

    return filePath;
  }

  static Future<List<String>> compressAll(List<String> filePaths) async {
    final results = <String>[];
    for (final path in filePaths) {
      results.add(await compressImage(path));
    }
    return results;
  }
}
