import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Shared pre-upload file-size guard.
///
/// `PlatformFile` carries no `size`, so the size is read with
/// `dart:io File(path).length()`. Invoke immediately after selection, before
/// the file enters state, preview, navigation, or any upload service.
/// Rejected files never return true and always trigger a SnackBar naming the
/// file and the limit.
class UploadFileValidator {
  const UploadFileValidator._();

  /// Per-feature limits in MB (must match backend).
  static const int digitalProductMaxMB = 10;
  static const int profilePhotoMaxMB = 5;
  static const int beritaMaxMB = 10;
  static const int ticketAttachmentMaxMB = 5;
  static const int certificateMaxMB = 5;
  static const int asesiDocMaxMB = 2;
  static const int ia04EvidenceMaxMB = 25;

  /// Returns true when [file] exists on disk and fits within [maxSizeMB].
  /// Shows a concise warning naming the file and the limit otherwise.
  static Future<bool> isValid(
    ScaffoldMessengerState messenger,
    PlatformFile file,
    int maxSizeMB,
  ) async {
    final path = file.path;
    if (path == null || path.isEmpty) {
      _warn(messenger, '${file.name}: path file tidak tersedia.');
      return false;
    }
    final int bytes;
    try {
      bytes = await File(path).length();
    } catch (_) {
      _warn(messenger, '${file.name}: file tidak dapat dibaca.');
      return false;
    }
    if (bytes > maxSizeMB * 1024 * 1024) {
      _warn(messenger, '${file.name} melebihi batas $maxSizeMB MB.');
      return false;
    }
    return true;
  }

  /// Keeps only valid files; warns once per rejected file via [isValid].
  static Future<List<PlatformFile>> filterValid(
    ScaffoldMessengerState messenger,
    Iterable<PlatformFile> files,
    int maxSizeMB,
  ) async {
    final valid = <PlatformFile>[];
    for (final file in files) {
      if (await isValid(messenger, file, maxSizeMB)) {
        valid.add(file);
      }
    }
    return valid;
  }

  static void _warn(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
