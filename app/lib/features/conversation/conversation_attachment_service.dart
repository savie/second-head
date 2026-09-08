import 'dart:typed_data';

import '../../core/backend/backend_client.dart';

const String conversationAttachmentBucket = 'second-head-conversation';

class ConversationAttachment {
  const ConversationAttachment({
    required this.attachmentId,
    required this.accountId,
    required this.shId,
    required this.messageId,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.storageRef,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.persistedAt,
    this.localPath,
  });

  final String attachmentId;
  final String accountId;
  final String shId;
  final String? messageId;
  final String filename;
  final String mimeType;
  final int sizeBytes;
  final String storageRef;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? persistedAt;
  final String? localPath;

  bool get isPending => status == 'PENDING';
  bool get isPersisted => status == 'PERSISTED';
  bool get isFailed => status == 'FAILED';

  ConversationAttachment copyWith({
    String? messageId,
    String? localPath,
    String? status,
    DateTime? updatedAt,
    DateTime? persistedAt,
  }) {
    return ConversationAttachment(
      attachmentId: attachmentId,
      accountId: accountId,
      shId: shId,
      messageId: messageId ?? this.messageId,
      filename: filename,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      storageRef: storageRef,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      persistedAt: persistedAt ?? this.persistedAt,
      localPath: localPath ?? this.localPath,
    );
  }

  factory ConversationAttachment.fromMap(Map<String, dynamic> row, {String? localPath}) {
    final attachmentId = row['attachment_id']?.toString();
    final accountId = row['account_id']?.toString();
    final shId = row['sh_id']?.toString();
    final filename = row['filename']?.toString();
    final mimeType = row['mime_type']?.toString();
    final storageRef = row['storage_ref']?.toString();
    final status = row['status']?.toString();
    final createdAt = DateTime.tryParse(row['created_at']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(row['updated_at']?.toString() ?? '');
    final sizeRaw = row['size_bytes'];
    final sizeBytes = sizeRaw is int ? sizeRaw : int.tryParse(sizeRaw?.toString() ?? '');
    if (attachmentId == null || accountId == null || shId == null || filename == null || mimeType == null || storageRef == null || status == null || createdAt == null || updatedAt == null || sizeBytes == null) {
      throw StateError('Conversation attachment runtime returned an incomplete attachment.');
    }
    return ConversationAttachment(
      attachmentId: attachmentId,
      accountId: accountId,
      shId: shId,
      messageId: row['message_id']?.toString(),
      filename: filename,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      storageRef: storageRef,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      persistedAt: DateTime.tryParse(row['persisted_at']?.toString() ?? ''),
      localPath: localPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'attachment_id': attachmentId,
        'account_id': accountId,
        'sh_id': shId,
        'message_id': messageId,
        'filename': filename,
        'mime_type': mimeType,
        'size_bytes': sizeBytes,
        'storage_ref': storageRef,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'persisted_at': persistedAt?.toIso8601String(),
        'local_path': localPath,
      };
}

class ConversationAttachmentService {
  const ConversationAttachmentService();

  Future<ConversationAttachment> create({
    required String filename,
    required String mimeType,
    required int sizeBytes,
    String? localPath,
  }) async {
    final result = await backendClient.rpc(
      'runtime_create_conversation_attachment',
      params: {
        'p_filename': filename,
        'p_mime_type': mimeType,
        'p_size_bytes': sizeBytes,
      },
    );
    final row = result is List && result.isNotEmpty ? result.first : result;
    if (row is! Map) throw StateError('Attachment runtime returned no attachment.');
    return ConversationAttachment.fromMap(Map<String, dynamic>.from(row), localPath: localPath);
  }

  Future<ConversationAttachment> uploadAndFinalize({
    required ConversationAttachment attachment,
    required Uint8List bytes,
    required String messageId,
  }) async {
    try {
      await backendClient.storage.from(conversationAttachmentBucket).uploadBinary(
        attachment.storageRef,
        bytes,
        fileOptions: const FileOptions(upsert: false),
      );
      final result = await backendClient.rpc(
        'runtime_finalize_conversation_attachment',
        params: {
          'p_attachment_id': attachment.attachmentId,
          'p_message_id': messageId,
        },
      );
      final row = result is List && result.isNotEmpty ? result.first : result;
      if (row is! Map) throw StateError('Attachment finalize returned no attachment.');
      return ConversationAttachment.fromMap(Map<String, dynamic>.from(row), localPath: attachment.localPath);
    } catch (_) {
      try {
        await backendClient.rpc(
          'runtime_fail_conversation_attachment',
          params: {'p_attachment_id': attachment.attachmentId},
        );
      } catch (_) {}
      rethrow;
    }
  }

  Future<List<ConversationAttachment>> loadForMessage(String messageId) async {
    final result = await backendClient.rpc(
      'runtime_load_conversation_attachments',
      params: {'p_message_id': messageId},
    );
    if (result is! List) return const [];
    return result
        .whereType<Map>()
        .map((row) => ConversationAttachment.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> detach(String attachmentId) async {
    await backendClient.rpc(
      'runtime_detach_conversation_attachment',
      params: {'p_attachment_id': attachmentId},
    );
  }

  Future<Uint8List> download(ConversationAttachment attachment) async {
    if (!attachment.isPersisted) {
      throw StateError('Only persisted attachments can be downloaded.');
    }
    return backendClient.storage.from(conversationAttachmentBucket).download(attachment.storageRef);
  }
}
