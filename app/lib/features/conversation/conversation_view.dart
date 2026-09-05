import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/storage/storage_service.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../journey/semantic_hook.dart';
import 'conversation_runtime_bridge.dart';

final ValueNotifier<String> conversationTitle =
    ValueNotifier<String>('Today Priorities');

final ValueNotifier<int> conversationRevision = ValueNotifier<int>(0);

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => ConversationViewState();
}

class ConversationViewState extends State<ConversationView> {
  final Connectivity _connectivity = Connectivity();
  final ConversationRuntimeBridge _conversationRuntime =
      const ConversationRuntimeBridge();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  bool _isLoadingConversation = true;
  bool _staticReplyPending = false;
  String _conversationStatus = 'Ready';
  Timer? _internetCheckTimer;

  @override
  void initState() {
    super.initState();
    conversationRevision.addListener(_resetConversation);
    _loadConversation();
    _refreshConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((_) => _refreshConnectivity());
    _internetCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshConnectivity(),
    );
  }

  Future<void> _refreshConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.every((result) => result == ConnectivityResult.none)) {
      if (mounted && _isOnline) setState(() => _isOnline = false);
      return;
    }

    bool online = false;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3)
      ..idleTimeout = const Duration(seconds: 3);

    try {
      final request = await client
          .getUrl(Uri.parse('https://www.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      request.headers.add(HttpHeaders.cacheControlHeader, 'no-cache');
      final response =
          await request.close().timeout(const Duration(seconds: 3));
      online = response.statusCode >= 200 && response.statusCode < 400;
      await response.drain<void>();
    } catch (_) {
      online = false;
    } finally {
      client.close(force: true);
    }

    if (mounted && online != _isOnline) {
      setState(() => _isOnline = online);
    }
  }

  void _resetConversation() {
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..add(ConversationMessage(
          'Hi, Savie! 👋\nHow can I help you today?',
          true,
          'Now',
        ));
    });
  }

  final Set<int> selected = {};
  final List<ConversationMessage> _messages = [
    ConversationMessage(
      'Hi, Savie! 👋\nHow can I help you today?',
      true,
      '09:41',
    ),
    ConversationMessage(
      'Help me summarize my main plan for today and top priorities.',
      false,
      '09:41',
    ),
    ConversationMessage(
      'Sure! Here is your summary and top priorities.',
      true,
      '09:42',
    ),
  ];
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  Future<void> _persistConversation() async {
    await StorageService.saveConversationState(
      title: conversationTitle.value,
      messages: [for (final m in _messages) m.toJson()],
    );
  }

  Future<void> _loadConversation() async {
    List<ConversationRecord> backendRecords = const [];
    Object? backendError;

    try {
      backendRecords = await _conversationRuntime.load(limit: 100);
    } catch (error) {
      backendError = error;
    }

    if (!mounted) return;

    if (backendError == null && backendRecords.isNotEmpty) {
      // The runtime load contract returns newest → oldest. Normalize the
      // application message list to oldest → newest so the chat viewport can
      // use the normal bottom-anchored conversation behavior.
      final chronological = backendRecords.reversed;
      _messages
        ..clear()
        ..addAll(chronological.map(_messageFromBackend));
      await _persistConversation();
      if (!mounted) return;
      setState(() {
        _isLoadingConversation = false;
        _conversationStatus = 'Ready';
      });
    } else {
      final state = await StorageService.readConversationState();
      if (!mounted) return;
      if (state != null) {
        final title = state['title'];
        final raw = state['messages'];
        if (title is String && title.trim().isNotEmpty) {
          conversationTitle.value = title;
        }
        if (raw is List) {
          final restored = raw
              .whereType<Map>()
              .map(
                (m) => ConversationMessage.fromJson(
                  Map<String, dynamic>.from(m),
                ),
              )
              .toList();
          if (restored.isNotEmpty) {
            _messages
              ..clear()
              ..addAll(restored);
          }
        }
      }
      setState(() {
        _isLoadingConversation = false;
        _conversationStatus =
            backendError == null ? 'Ready' : 'Local only — backend sync unavailable';
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  ConversationMessage _messageFromBackend(ConversationRecord record) {
    return ConversationMessage(
      record.content,
      record.role == 'assistant',
      _formatTime(record.createdAt),
      runtimeRecordId: record.conversationId,
      createdAt: record.createdAt,
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _send() async {
    final t = _composerController.text.trim();
    if (t.isEmpty || _staticReplyPending) return;

    _composerController.clear();
    setState(() {
      _staticReplyPending = true;
      _conversationStatus = 'SH is responding…';
    });

    ConversationRecord? userRecord;
    try {
      userRecord = await _conversationRuntime.recordUser(t);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ConversationMessage(t, false, 'Now'));
        _conversationStatus = 'Local only — message not synced';
      });
      await _persistConversation();
      _processFrontendSemantic(t);
      _staticReplyPending = false;
      if (mounted) setState(() => _conversationStatus = 'Local only — backend sync unavailable');
      return;
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_messageFromBackend(userRecord!));
    });
    await _persistConversation();
    _processFrontendSemantic(t);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    const reply =
        'Got it. SH menerima pesan ini dan jalur respons aktif. Respons dinamis akan terhubung ke model AI nanti.';

    try {
      final assistantRecord = await _conversationRuntime.recordAssistant(reply);
      if (!mounted) return;
      setState(() {
        _messages.add(_messageFromBackend(assistantRecord));
        _staticReplyPending = false;
        _conversationStatus = 'Ready';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ConversationMessage(reply, true, 'Now'));
        _staticReplyPending = false;
        _conversationStatus = 'Local only — assistant response not synced';
      });
    }

    await _persistConversation();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  Future<void> _processFrontendSemantic(String text) async {
    final candidates = await shFrontendSemanticSimulator.process(
      sourceId: conversationTitle.value,
      content: text,
    );
    if (!mounted || candidates.isEmpty) return;
    for (final candidate in candidates) {
      shAddSemanticRecord(candidate);
    }
  }

  void _scrollToLatest() {
    if (!_messageScrollController.hasClients) return;
    _messageScrollController.animateTo(
      _messageScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickFile() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) return;
    final stored = await StorageService.saveConversationFile(
      bytes,
      filename: picked.name,
    );
    if (!mounted) return;
    setState(() => _messages.add(
          ConversationMessage('', false, 'Now', attachmentPath: stored.path),
        ));
    await _persistConversation();
  }

  Future<void> _pick(ImageSource source) async {
    Navigator.pop(context);
    final f = await _picker.pickImage(source: source, imageQuality: 88);
    if (f == null) return;
    final b = await f.readAsBytes();
    final stored = await StorageService.saveConversationImage(
      b,
      extension: f.path.split('.').last,
    );
    if (!mounted) return;
    setState(() => _messages.add(
          ConversationMessage('', false, 'Now', attachmentPath: stored.path),
        ));
    await _persistConversation();
  }

  void _showAttachments() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AttachAction(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () => _pick(ImageSource.camera),
            ),
            AttachAction(
              icon: Icons.photo_library_outlined,
              label: 'Photos',
              onTap: () => _pick(ImageSource.gallery),
            ),
            AttachAction(
              icon: Icons.attach_file_outlined,
              label: 'File',
              onTap: _pickFile,
            ),
          ],
        ),
      ),
    );
  }

  void _conversationMenu() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: shSurface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionTile(
                  icon: Icons.copy_outlined,
                  label: 'Copy',
                  onTap: () => Navigator.pop(context),
                ),
                ActionTile(
                  icon: Icons.clear_all,
                  label: 'Clear',
                  onTap: () => Navigator.pop(context),
                ),
                ActionTile(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onTap: () => Navigator.pop(context),
                ),
                ActionTile(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );

  void _copyText(String text) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _messageActions(int index, {required bool assistant}) {
    final actions = assistant
        ? const ['Copy', 'Regenerate', 'Delete']
        : const ['Copy', 'Edit', 'Delete'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final a in actions)
                ActionTile(
                  icon: a == 'Copy'
                      ? Icons.copy_outlined
                      : a == 'Edit'
                          ? Icons.edit_outlined
                          : a == 'Regenerate'
                              ? Icons.refresh_outlined
                              : Icons.delete_outline,
                  label: a,
                  onTap: () => _runMessageAction(context, index, a),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _enterSelection(int index) => setState(() => selected.add(index));

  void _toggleSelection(int index) => setState(() {
        if (selected.contains(index)) {
          selected.remove(index);
        } else {
          selected.add(index);
        }
      });

  void _deleteSelected() {
    setState(() {
      final ids = selected.toList()..sort((a, b) => b.compareTo(a));
      for (final i in ids) {
        if (i < _messages.length) _messages.removeAt(i);
      }
      selected.clear();
    });
    _persistConversation();
  }

  void _runMessageAction(BuildContext context, int index, String action) {
    Navigator.pop(context);
    if (index >= _messages.length) return;
    final m = _messages[index];
    if (action == 'Copy') {
      _copyText(m.text);
    } else if (action == 'Delete') {
      setState(() => _messages.removeAt(index));
      _persistConversation();
    } else if (action == 'Regenerate') {
      setState(() => m.text = 'Regenerated response — ready to continue.');
      _persistConversation();
    } else if (action == 'Edit') {
      final ctl = TextEditingController(text: m.text);
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
              TextField(controller: ctl, maxLines: 5),
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
                        if (ctl.text.trim().isNotEmpty) {
                          setState(() => m.text = ctl.text.trim());
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
      ).whenComplete(ctl.dispose);
    }
  }

  @override
  void dispose() {
    conversationRevision.removeListener(_resetConversation);
    _connectivitySubscription?.cancel();
    _internetCheckTimer?.cancel();
    _composerController.dispose();
    _messageScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      appBar: AppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: conversationTitle,
          builder: (_, title, __) => Text(title),
        ),
        actions: [
          IconButton(
            onPressed: _conversationMenu,
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoadingConversation)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView.builder(
                controller: _messageScrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ConversationBubble(
                    message: message,
                    selected: selected.contains(index),
                    onLongPress: () => _enterSelection(index),
                    onTap: selected.isEmpty
                        ? null
                        : () => _toggleSelection(index),
                    onActions: () =>
                        _messageActions(index, assistant: message.assistant),
                  );
                },
              ),
            ),
            if (selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text('${selected.length} selected'),
                    const Spacer(),
                    IconButton(
                      onPressed: _deleteSelected,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _showAttachments,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _composerController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: _isOnline ? 'Message SH…' : 'Message SH (local only)…',
                        filled: true,
                        fillColor: shSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward_rounded),
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

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'];
    return ConversationMessage(
      json['text'] is String ? json['text'] as String : '',
      json['assistant'] == true,
      json['time'] is String ? json['time'] as String : 'Now',
      attachmentPath: json['attachmentPath'] is String
          ? json['attachmentPath'] as String
          : null,
      runtimeRecordId: json['runtimeRecordId'] is String
          ? json['runtimeRecordId'] as String
          : null,
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }
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
    final alignment = message.assistant
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;
    final color = message.assistant ? shSurface : shAccent;
    final textColor = message.assistant ? shTextPrimary : shTextOnAccent;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: shAccent, width: 1.5),
              )
            : null,
        padding: const EdgeInsets.all(2),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.fromLTRB(14, 11, 10, 9),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: message.attachmentPath == null
                        ? Text(
                            message.text,
                            style: TextStyle(color: textColor, height: 1.35),
                          )
                        : Text(
                            message.text.isEmpty
                                ? 'Attachment: ${message.attachmentPath!.split('/').last}'
                                : message.text,
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 68,
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
  Widget build(BuildContext context) {
    return InkWell(
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
}
