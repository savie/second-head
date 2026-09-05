import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/storage/storage_service.dart';
import '../../core/theme/sh_theme.dart';
import '../journey/semantic_hook.dart';
import 'conversation_runtime_bridge.dart';
import 'conversation_service.dart';

final ValueNotifier<String> conversationTitle =
    ValueNotifier<String>('Today Priorities');

final ValueNotifier<int> conversationRevision = ValueNotifier<int>(0);

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => ConversationViewState();
}

class ConversationViewState extends State<ConversationView> {
  static final Map<String, List<ConversationMessage>> _localAttachments = {};

  final ConversationRuntimeBridge _runtime =
      const ConversationRuntimeBridge();
  final TextEditingController _composerController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final Set<int> selected = {};
  final List<ConversationMessage> _messages = [];

  bool _loading = true;
  bool _responding = false;

  String? get _activeConversationId =>
      ConversationService.activeConversationId.value;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    try {
      final conversations = await _runtime.listConversations();
      final activeId = _activeConversationId;
      for (final item in conversations) {
        if (item.conversationId == activeId) {
          conversationTitle.value = item.title;
          break;
        }
      }

      final records = await _runtime.load(limit: 100);
      _messages
        ..clear()
        ..addAll(records.map(_messageFromBackend));

      final attachments = _localAttachments[_activeConversationId ?? 'default'];
      if (attachments != null) _messages.addAll(attachments);
      _sortMessagesChronologically();

      final localState = await StorageService.readConversationState();
      if (records.isEmpty && localState != null) {
        _restoreLocalState(localState);
      }
    } catch (_) {
      try {
        final localState = await StorageService.readConversationState();
        if (localState != null) _restoreLocalState(localState);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _restoreLocalState(Map<String, dynamic> state) {
    final title = state['title'];
    final raw = state['messages'];
    if (title is String && title.trim().isNotEmpty) {
      conversationTitle.value = title;
    }
    if (raw is List) {
      final restored = raw
          .whereType<Map>()
          .map((item) => ConversationMessage.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
      if (restored.isNotEmpty) {
        _messages
          ..clear()
          ..addAll(restored);
      }
    }
  }

  void _sortMessagesChronologically() {
    _messages.sort((a, b) {
      final aTime = a.createdAt;
      final bTime = b.createdAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return -1;
      if (bTime == null) return 1;
      return aTime.compareTo(bTime);
    });
  }

  ConversationMessage _messageFromBackend(ConversationRecord record) =>
      ConversationMessage(
        record.content,
        record.isAssistant,
        _formatTime(record.createdAt),
        runtimeRecordId: record.messageId,
        createdAt: record.createdAt,
      );

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _persistConversation() async {
    await StorageService.saveConversationState(
      title: conversationTitle.value,
      messages: [for (final message in _messages) message.toJson()],
    );
  }

  Future<void> _send() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _responding) return;

    _composerController.clear();
    setState(() => _responding = true);

    try {
      final record = await _runtime.recordUser(text);
      if (!mounted) return;
      setState(() => _messages.add(_messageFromBackend(record)));
      await _processSemantic(text);

      // Dynamic model response remains intentionally deferred.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      const reply =
          'Got it. SH menerima pesan ini dan jalur respons aktif. Respons dinamis akan terhubung ke model AI nanti.';
      final assistant = await _runtime.recordAssistant(reply);
      if (!mounted) return;
      setState(() => _messages.add(_messageFromBackend(assistant)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ConversationMessage(text, false, _now()));
        _messages.add(ConversationMessage(
          'Got it. SH menerima pesan ini dan jalur respons aktif. Respons dinamis akan terhubung ke model AI nanti.',
          true,
          'Now',
        ));
      });
      await _processSemantic(text);
    } finally {
      if (mounted) setState(() => _responding = false);
      await _persistConversation();
    }
  }

  Future<void> _processSemantic(String text) async {
    final candidates = await shFrontendSemanticSimulator.process(
      sourceId: _activeConversationId ?? conversationTitle.value,
      content: text,
    );
    if (!mounted) return;
    for (final candidate in candidates) {
      shAddSemanticRecord(candidate);
    }
  }

  String _now() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickFile() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) return;
    final file = await StorageService.saveConversationFile(
      bytes,
      filename: picked.name,
    );
    _addAttachment(file.path);
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final image = await _picker.pickImage(source: source, imageQuality: 88);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final file = await StorageService.saveConversationImage(
      bytes,
      extension: image.path.split('.').last,
    );
    _addAttachment(file.path);
  }

  void _addAttachment(String path) {
    if (!mounted) return;
    final message = ConversationMessage(
      '',
      false,
      _now(),
      attachmentPath: path,
      createdAt: DateTime.now(),
    );
    final key = _activeConversationId ?? 'default';
    (_localAttachments[key] ??= []).add(message);
    setState(() {
      _messages.add(message);
      _sortMessagesChronologically();
    });
    _persistConversation();
  }

  void _showAttachments() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AttachAction(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
              AttachAction(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              AttachAction(
                icon: Icons.attach_file_outlined,
                label: 'File',
                onTap: _pickFile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _messageActions(int index, {required bool assistant}) {
    final actions = assistant
        ? const ['Copy', 'Delete']
        : const ['Copy', 'Edit', 'Delete'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final action in actions)
              ActionTile(
                icon: action == 'Copy'
                    ? Icons.copy_outlined
                    : action == 'Edit'
                        ? Icons.edit_outlined
                        : Icons.delete_outline,
                label: action,
                onTap: () => _runMessageAction(index, action),
              ),
          ],
        ),
      ),
    );
  }

  void _runMessageAction(int index, String action) {
    Navigator.pop(context);
    if (index >= _messages.length) return;
    final message = _messages[index];
    if (action == 'Copy') {
      if (message.text.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: message.text));
      }
      return;
    }
    if (action == 'Delete') {
      setState(() => _messages.removeAt(index));
      _persistConversation();
      return;
    }
    if (action == 'Edit') {
      final controller = TextEditingController(text: message.text);
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: shSurface,
        showDragHandle: true,
        builder: (sheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.of(sheet).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(controller: controller, maxLines: 5),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheet),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isNotEmpty) {
                          setState(() => message.text = value);
                          _persistConversation();
                        }
                        Navigator.pop(sheet);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).whenComplete(controller.dispose);
    }
  }

  void _enterSelection(int index) => setState(() => selected.add(index));

  void _toggleSelection(int index) => setState(() {
        if (!selected.remove(index)) selected.add(index);
      });

  void _deleteSelected() {
    final indexes = selected.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final index in indexes) {
        if (index < _messages.length) _messages.removeAt(index);
      }
      selected.clear();
    });
    _persistConversation();
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<String>(
          valueListenable: conversationTitle,
          builder: (_, title, __) => ShTopBar(
            title: title,
            actions: [
              IconButton(
                tooltip: 'Conversation menu',
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, size: 28),
              ),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final actualIndex = _messages.length - 1 - index;
              final message = _messages[actualIndex];
              return ConversationBubble(
                message: message,
                selected: selected.contains(actualIndex),
                onLongPress: () => _enterSelection(actualIndex),
                onTap: selected.isEmpty ? null : () => _toggleSelection(actualIndex),
                onActions: () => _messageActions(
                  actualIndex,
                  assistant: message.assistant,
                ),
              );
            },
          ),
        ),
        if (selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Row(
              children: [
                Text('${selected.length} selected', style: const TextStyle(color: shMuted)),
                const Spacer(),
                IconButton(
                  onPressed: _deleteSelected,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Attachment',
                onPressed: _showAttachments,
                icon: const Icon(Icons.add_circle_outline, size: 28),
              ),
              Expanded(
                child: TextField(
                  controller: _composerController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Message SH…',
                    filled: true,
                    fillColor: shSurface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: shBorder, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: shBorder, width: 1.2),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Send',
                onPressed: _responding ? null : _send,
                icon: const Icon(Icons.arrow_upward_rounded, size: 30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConversationMessage {
  ConversationMessage(
    this.text,
    this.assistant,
    this.time, {
    this.attachmentPath,
    this.runtimeRecordId,
    this.createdAt,
  });

  String text;
  final bool assistant;
  final String time;
  final String? attachmentPath;
  final String? runtimeRecordId;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'text': text,
        'assistant': assistant,
        'time': time,
        'attachmentPath': attachmentPath,
        'runtimeRecordId': runtimeRecordId,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      ConversationMessage(
        json['text']?.toString() ?? '',
        json['assistant'] == true,
        json['time']?.toString() ?? 'Now',
        attachmentPath: json['attachmentPath']?.toString(),
        runtimeRecordId: json['runtimeRecordId']?.toString(),
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}

class ConversationBubble extends StatelessWidget {
  const ConversationBubble({
    super.key,
    required this.message,
    required this.selected,
    required this.onLongPress,
    required this.onTap,
    required this.onActions,
  });

  final ConversationMessage message;
  final bool selected;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final isImage = message.attachmentPath != null &&
        RegExp(
          r'\.(jpg|jpeg|png|gif|webp|heic|heif|bmp)$',
          caseSensitive: false,
        ).hasMatch(message.attachmentPath!);
    final alignment =
        message.assistant ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final bubbleColor = message.assistant ? shSurface : shAccent;
    final textColor = message.assistant ? shTextPrimary : shTextOnAccent;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: shAccent, width: 1.4),
              )
            : null,
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.fromLTRB(14, 11, 10, 9),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.attachmentPath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: isImage && File(message.attachmentPath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(message.attachmentPath!),
                                width: 240,
                                height: 170,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: textColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    message.attachmentPath!.split('/').last,
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  if (message.text.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            message.text,
                            style: TextStyle(color: textColor, height: 1.35),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          message.time,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.65),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 2),
                        InkWell(
                          onTap: onActions,
                          child: Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.time,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.65),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 2),
                        InkWell(
                          onTap: onActions,
                          child: Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
}

class AttachAction extends StatelessWidget {
  const AttachAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      );
}
