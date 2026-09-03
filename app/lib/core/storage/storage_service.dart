import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Local file storage owned by SECOND HEAD.
class StorageService {
  static const profilePhotoName = 'profile_photo.jpg';

  static bool _legacyMigrationDone = false;

  static Future<Directory> root() async {
    final external = await getExternalStorageDirectory();
    if (external == null) {
      throw StateError('SECOND HEAD external storage directory is unavailable.');
    }
    final dir = Directory(external.path);
    await dir.create(recursive: true);
    for (final name in ['images', 'audio', 'video', 'documents', 'exports']) {
      await Directory('${dir.path}/$name').create(recursive: true);
    }
    await _migrateLegacyStorage(dir);
    return dir;
  }

  static Future<Directory> directory(String category) async {
    final rootDir = await root();
    final dir = Directory('${rootDir.path}/$category');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> internalRoot() async {
    final dir = Directory('/data/data/com.secondhead.app/files');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> internalDirectory(String category) async {
    final rootDir = await internalRoot();
    final dir = Directory('${rootDir.path}/$category');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<void> _migrateLegacyStorage(Directory externalRoot) async {
    if (_legacyMigrationDone) return;

    final legacyRoot = Directory('${externalRoot.path}/second_head');
    if (!await legacyRoot.exists()) {
      _legacyMigrationDone = true;
      return;
    }

    final externalCategories = ['images', 'audio', 'video', 'documents', 'exports'];
    for (final category in externalCategories) {
      final sourceDir = Directory('${legacyRoot.path}/$category');
      if (!await sourceDir.exists()) continue;
      final targetDir = Directory('${externalRoot.path}/$category');
      await targetDir.create(recursive: true);
      await for (final entity in sourceDir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final relative = entity.path.substring(sourceDir.path.length + 1);
        final target = File('${targetDir.path}/$relative');
        await target.parent.create(recursive: true);
        if (await target.exists()) {
          await entity.delete();
        } else {
          await entity.rename(target.path);
        }
      }
    }

    final legacyTemp = Directory('${legacyRoot.path}/temp');
    if (await legacyTemp.exists()) {
      final targetTemp = await internalDirectory('temp');
      await for (final entity in legacyTemp.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        final relative = entity.path.substring(legacyTemp.path.length + 1);
        final target = File('${targetTemp.path}/$relative');
        await target.parent.create(recursive: true);
        if (await target.exists()) {
          await entity.delete();
        } else {
          // Legacy temp lived on external storage; copy into app-private
          // storage because this may cross filesystem boundaries.
          await target.writeAsBytes(await entity.readAsBytes(), flush: true);
          await entity.delete();
        }
      }
    }

    // Only remove the legacy container after all known content has moved.
    // Never recursively delete unknown legacy files.
    try {
      await legacyRoot.delete();
    } catch (_) {}
    _legacyMigrationDone = true;
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

  static Future<File> saveConversationFile(
    Uint8List bytes, {
    required String filename,
  }) async {
    final extension =
        filename.contains('.') ? filename.split('.').last.toLowerCase() : 'bin';
    final category = _categoryForExtension(extension);
    final dir = await directory(category);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final safeName =
        filename.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/conversation_${timestamp}_$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File> saveConversationImage(
    Uint8List bytes, {
    String extension = 'jpg',
  }) {
    return saveConversationFile(
      bytes,
      filename: 'conversation_image.$extension',
    );
  }

  static String _categoryForExtension(String extension) {
    if (RegExp(r'^(jpg|jpeg|png|gif|webp|heic|heif|bmp)$')
        .hasMatch(extension)) {
      return 'images';
    }
    if (RegExp(r'^(mp4|mov|m4v|webm|avi|mkv|3gp)$').hasMatch(extension)) {
      return 'video';
    }
    if (RegExp(r'^(mp3|m4a|wav|aac|ogg|opus|flac)$').hasMatch(extension)) {
      return 'audio';
    }
    return 'documents';
  }

  static Future<List<File>> listFiles({bool includeExports = true}) async {
    final rootDir = await root();
    final files = <File>[];
    await for (final entity
        in rootDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        if (!includeExports &&
            entity.path.contains(
              '${Platform.pathSeparator}exports${Platform.pathSeparator}',
            )) {
          continue;
        }
        files.add(entity);
      }
    }
    return files;
  }

  static String categoryFor(File file) {
    final path = file.path.toLowerCase();
    if (RegExp(r'\.(jpg|jpeg|png|gif|webp|heic)$').hasMatch(path)) {
      return 'images';
    }
    if (RegExp(r'\.(mp4|mov|m4v|webm|avi)$').hasMatch(path)) {
      return 'video';
    }
    if (RegExp(r'\.(mp3|m4a|wav|aac|ogg|opus)$').hasMatch(path)) {
      return 'audio';
    }
    return 'documents';
  }

  static Future<File> conversationStateFile() async {
    final dir = await internalDirectory('temp');
    return File('${dir.path}/conversation_state.json');
  }

  static Future<void> saveConversationState({
    required String title,
    required List<Map<String, dynamic>> messages,
  }) async {
    final file = await conversationStateFile();
    await file.writeAsString(
      jsonEncode({
        'title': title,
        'messages': messages,
        'savedAt': DateTime.now().toIso8601String(),
      }),
      flush: true,
    );
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

  /// Recovery snapshots are canonical local export files.
  /// Data & Privacy and Export both read this same directory.
  static Future<Directory> recoverySnapshotsDirectory() {
    return directory('exports');
  }

  static Future<List<File>> listRecoverySnapshotFiles() async {
    final dir = await recoverySnapshotsDirectory();
    final files = <File>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is File &&
          RegExp(r'^recovery_snapshots_\d{6}_\d{6}\.json$')
              .hasMatch(entity.uri.pathSegments.last)) {
        files.add(entity);
      }
    }
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  static Future<File> recoverySnapshotFileFor(DateTime createdAt) async {
    final dir = await recoverySnapshotsDirectory();
    String two(int n) => n.toString().padLeft(2, '0');
    final filename =
        'recovery_snapshots_${two(createdAt.month)}${two(createdAt.day)}'
        '${createdAt.year.toString().substring(2)}_'
        '${two(createdAt.hour)}${two(createdAt.minute)}${two(createdAt.second)}.json';
    return File('${dir.path}/$filename');
  }

  static Future<File> journeyItemsFile() async {
    final dir = await internalDirectory('temp');
    return File('${dir.path}/journey_items.json');
  }

  static Future<File> integrationAuthorizationsFile() async {
    final dir = await internalDirectory('temp');
    return File('${dir.path}/integration_authorizations.json');
  }

  static Future<List<Map<String, dynamic>>> listPersistentFilesForRecovery() async {
    final result = <Map<String, dynamic>>[];

    Future<void> collect(Directory base, String prefix, {String? excludedPath}) async {
      if (!await base.exists()) return;
      await for (final entity in base.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        if (excludedPath != null &&
            entity.path.contains(
              '${Platform.pathSeparator}$excludedPath${Platform.pathSeparator}',
            )) {
          continue;
        }
        final relative = entity.path.substring(base.path.length + 1);
        result.add({
          'path': '$prefix/$relative',
          'bytes_base64': base64Encode(await entity.readAsBytes()),
        });
      }
    }

    await collect(await internalRoot(), 'internal');
    await collect(await root(), 'external', excludedPath: 'exports');
    return result;
  }

  static Future<void> clearApplicationData() async {
    final dir = await internalRoot();
    if (await dir.exists()) {
      await for (final entity in dir.list(followLinks: false)) {
        await entity.delete(recursive: true);
      }
    }
    final cache = await getTemporaryDirectory();
    if (await cache.exists()) {
      await for (final entity in cache.list(followLinks: false)) {
        await entity.delete(recursive: true);
      }
    }
    await internalDirectory('temp');
  }

  static Future<int> totalBytes() async {
    var total = 0;
    for (final file in await listFiles(includeExports: false)) {
      total += await file.length();
    }
    return total;
  }
}
