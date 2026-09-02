import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

/// Local file storage owned by SECOND HEAD.
///
/// This is intentionally client-side only. It does not replace Supabase
/// persistence for account/conversation data.
class StorageService {
  // App-private local root. The OS-owned parent differs by platform.
  static const profilePhotoName = 'profile_photo.jpg';

  static Future<Directory> root() async {
    final external = await getExternalStorageDirectory();
    final base = external ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/second_head');
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

  static Future<File> saveConversationFile(Uint8List bytes, {required String filename}) async {
    final extension = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'bin';
    final category = _categoryForExtension(extension);
    final dir = await directory(category);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final safeName = filename.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/conversation_${timestamp}_${safeName}');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File> saveConversationImage(Uint8List bytes, {String extension = 'jpg'}) async {
    return saveConversationFile(bytes, filename: 'conversation_image.$extension');
  }

  static String _categoryForExtension(String extension) {
    if (RegExp(r'^(jpg|jpeg|png|gif|webp|heic|heif|bmp)$').hasMatch(extension)) return 'images';
    if (RegExp(r'^(mp4|mov|m4v|webm|avi|mkv|3gp)$').hasMatch(extension)) return 'video';
    if (RegExp(r'^(mp3|m4a|wav|aac|ogg|opus|flac)$').hasMatch(extension)) return 'audio';
    return 'documents';
  }

  static Future<List<File>> listFiles({bool includeExports = true}) async {
    final rootDir = await root();
    final files = <File>[];
    await for (final entity in rootDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        if (!includeExports && entity.path.contains('${Platform.pathSeparator}exports${Platform.pathSeparator}')) continue;
        files.add(entity);
      }
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

  static Future<File> conversationStateFile() async {
    final dir = await directory('temp');
    return File('${dir.path}/conversation_state.json');
  }

  static Future<void> saveConversationState({
    required String title,
    required List<Map<String, dynamic>> messages,
  }) async {
    final file = await conversationStateFile();
    await file.writeAsString(jsonEncode({
      'title': title,
      'messages': messages,
      'savedAt': DateTime.now().toIso8601String(),
    }), flush: true);
  }

  static Future<Map<String, dynamic>?> readConversationState() async {
    final file = await conversationStateFile();
    if (!await file.exists()) return null;
    try {
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Future<int> totalBytes() async {
    var total = 0;
    for (final file in await listFiles(includeExports: false)) {
      total += await file.length();
    }
    return total;
  }
}
