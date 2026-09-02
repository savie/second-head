import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Local file storage owned by SECOND HEAD.
///
/// This is intentionally client-side only. It does not replace Supabase
/// persistence for account/conversation data.
class StorageService {
  // App-private local root. The OS-owned parent differs by platform.\n  // Callers must never hard-code the platform path.\n  static const _rootName = 'second_head';
  static const profilePhotoName = 'profile_photo.jpg';

  static Future<Directory> root() async {
    final external = await getExternalStorageDirectory();
    final base = external ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/$_rootName');
    await dir.create(recursive: true);
    for (final name in ['images', 'audio', 'video', 'documents', 'exports', 'temp']) {
      await Directory('${dir.path}/$name').create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> directory(String category) async {
    final rootDir = await root();
    final dir = Directory('${rootDir.path}/$category');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<File> profilePhotoFile() async {
    final dir = await directory('images');
    return File('${dir.path}/$profilePhotoName');
  }

  static Future<void> saveProfilePhoto(Uint8List bytes) async {
    final file = await profilePhotoFile();
    await file.writeAsBytes(bytes, flush: true);
  }

  static Future<Uint8List?> readProfilePhoto() async {
    final file = await profilePhotoFile();
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  static Future<void> removeProfilePhoto() async {
    final file = await profilePhotoFile();
    if (await file.exists()) await file.delete();
  }

  static Future<List<File>> listFiles({bool includeExports = true}) async {
    final rootDir = await root();
    final files = <File>[];
    await for (final entity in rootDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {\n        if (!includeExports && entity.path.contains('${Platform.pathSeparator}exports${Platform.pathSeparator}')) {\n          continue;\n        }\n        files.add(entity);\n      }
    }
    return files;
  }

  static String categoryFor(File file) {
    final path = file.path.toLowerCase();
    if (RegExp(r'\.(jpg|jpeg|png|gif|webp|heic)$').hasMatch(path)) return 'images';
    if (RegExp(r'\.(mp4|mov|m4v|webm|avi)$').hasMatch(path)) return 'video';
    if (RegExp(r'\.(mp3|m4a|wav|aac|ogg|opus)$').hasMatch(path)) return 'audio';
    return 'documents';
  }

  static Future<int> totalBytes() async {
    var total = 0;
    for (final file in await listFiles(includeExports: false)) {
      total += await file.length();
    }
    return total;
  }
}
