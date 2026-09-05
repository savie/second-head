import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/sh_theme.dart';
import '../journey/semantic_hook.dart';
import 'conversation_runtime_bridge.dart';

final ValueNotifier<String> conversationTitle = ValueNotifier<String>('Today Priorities');
final ValueNotifier<int> conversationRevision = ValueNotifier<int>(0);

class ConversationView extends StatefulWidget {
  const ConversationView({super.key});

  @override
  State<ConversationView> createState() => ConversationViewState();
}

class ConversationViewState extends State<ConversationView> {
  final Connectivity _connectivity = Connectivity();
  final ConversationRuntimeBridge _runtime = const ConversationRuntimeBridge();
  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final Set<int> selected = {};
  final List<ConversationMessage> _messages = [];

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _internetCheckTimer;
  bool _isOnline = true;
  bool _isLoadingConversation = true;
  bool _staticReplyPending = false;
  String _conversationStatus = 'Ready';

  @override
  void initState() {
    super.initState();
    conversationRevision.addListener(_resetConversation);
    _loadConversation();
    _refreshConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
      _refreshConnectivity();
    });
    _internetCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshConnectivity(),
    );
  }

  void _resetConversation() {
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _conversationStatus = 'Ready';
    });
  }

  Future<void> _refreshConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.every((result) => result == ConnectivityResult.none)) {
      if (mounted && _isOnline) setState(() => _isOnline = false);
      return;
    }

    var online = false;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3)
      ..idleTimeout = const Duration(seconds: 3);
    try {
      final request = await client
          .getUrl(Uri.parse('https://www.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      request.headers.add(HttpHeaders.cacheControlHeader, 'no-cache');
      final response = await request.close().timeout(const Duration(seconds: 3));
      online = response.statusCode >= 200 && response.statusCode < 400;
      await response.drain<void>();
    } catch (_) {
      online = false;
    } finally {
      client.close(force: true);
    }
    if (mounted && online != _isOnline) setState(() => _isOnline = online);
  }

  Future<void> _loadConversation() async {
    try {
      final records = await _runtime.load(limit: 100);
      if (!mounted) return;

      final summaries = await _runtime.listConversations();
      final activeId = _runtime.activeConversationId;
      ConversationSummary? summary;
      for (final item in summaries) {
        if (item.conversationId == activeId) {
          summary = item;
          break;
        }
      }

      _messages
        ..clear()
        ..addAll(records.map(_messageFromBackend));
      if (summary != null) conversationTitle.value = summary.title;
      await _persistConversation();

      if (!mounted) return;
      setState(() {
        _isLoadingConversation = false;
        _conversationStatus = 'Ready';
      });
    } catch (_) {
      final state = await StorageService.readConversationState();
      if (!mounted) return;

      _messages.clear();
      if (state != null) {
        final title = state['title'];
        final raw = state['messages'];
        if (title is String && title.trim().isNotEmpty) {
          conversationTitle.value = title;
        }
        if (raw is List) {
          _messages.addAll(
            raw.whereType<Map>().map(
              (m) => ConversationMessage.fromJson(
                Map<String, dynamic>.from(m),
              ),
            ),
          );
        }
      }

      setState(() {
        _isLoadingConversation = false;
        _conversationStatus = 'Local only — backend sync unavailable';
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  ConversationMessage _messageFromBackend(ConversationRecord record) {
    return ConversationMessage(
      record.content,
      record.role == 'assistant',
      _formatTime(record.createdAt),
      runtimeRecordId: record.messageId,
      createdAt: record.createdAt,
    );
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _persistConversation() {
    return StorageService.saveConversationState(
      title: conversationTitle.value,
      messages: [for (final message in _messages) message.toJson()],
    );
  }

  Future<void> _send() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _staticReplyPending) return;

    _composerController.clear();
    setState(() {
      _staticReplyPending = true;
      _conversationStatus = 'SH is responding…';
    });

    try {
      final user = await _runtime.recordUser(text);
      if (!mounted) return;
      setState(() => _messages.add(_messageFromBackend(user)));
      await _persistConversation();
      _processFrontendSemantic(text);
      _scrollToLatest();

      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;

      const reply =
          'Got it. SH menerima pesan ini dan jalur respons aktif. Respons dinamis akan terhubung ke model AI nanti.';
      final assistant = await _runtime.recordAssistant(reply);
      if (!mounted) return;
      setState(() {
        _messages.add(_messageFromBackend(assistant));
        _staticReplyPending = false;
        _conversationStatus = 'Ready';
      });
      await _persistConversation();
      _scrollToLatest();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(ConversationMessage(text, false, 'Now'));
        _staticReplyPending = false;
        _conversationStatus = 'Local only — backend sync unavailable';
      });
      await _persistConversation();
    }
  }

  Future<void> _processFrontendSemantic(String text) async {
    final candidates = await shFrontendSemanticSimulator.process(
      sourceId: conversationTitle.value,
      content: text,
    );
    if (!mounted) return;
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
    if (picked.bytes == null) return;

    final stored = await StorageService.saveConversationFile(
      picked.bytes!,
      filename: picked.name,
    );
    if (!mounted) return;
    setState(() {
      _messages.add(
        ConversationMessage('', false, 'Now', attachmentPath: stored.path),
      );
    });
    await _persistConversation();
  }

  Future<void> _pick(ImageSource source) async {
    Navigator.pop(context);
    final file = await _picker.pickImage(source: source, imageQuality: 88);
    if (file == null) return;

    final stored = await StorageService.saveConversationImage(
      await file.readAsBytes(),
      extension: file.path.split('.').last,
    );
    if (!mounted) return;
    setState(() {
      _messages.add(
        ConversationMessage('', false, 'Now', attachmentPath: stored.path),
      );
    });
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

  String _allText() {
    return _messages
        .where((message) => message.text.trim().isNotEmpty)
        .map((message) => '${message.assistant ? 'SH' : 'You'}: ${message.text}')
        .join('\n\n');
  }

  Future<void> _copyAll() async {
    final text = _allText();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conversation copied'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareAll() async {
    final text = _allText();
    if (text.isEmpty) return;
    await Share.share(text, subject: conversationTitle.value);
  }

  Future<void> _clearConversation() async {
    Navigator.pop(context);
    final records = List<ConversationMessage>.from(_messages);
    try {
      for (final message in records) {
        final id = message.runtimeRecordId;
        if (id != null) {
          await _runtime.deleteMessage(
            conversationId: id,
            createdAt: message.createdAt ?? DateTime.now(),
            role: message.assistant ? 'assistant' : 'user',
            content: message.text,
          );
        }
      }
      if (!mounted) return;
      setState(() => _messages.clear());
      await _persistConversation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to clear conversation')),
        );
      }
    }
  }

  Future<void> _deleteConversation() async {
    Navigator.pop(context);
    final id = _runtime.activeConversationId;
    try {
      if (id != null && id.isNotEmpty) {
        await _runtime.deleteConversation(conversationId: id);
      }
      final newId = await _runtime.createConversation(title: 'New Conversation');
      await _runtime.selectConversation(newId);
      if (!mounted) return;
      setState(() => _messages.clear());
      conversationTitle.value = 'New Conversation';
      await _persistConversation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete conversation')),
        );
      }
    }
  }

  void _conversationMenu() {
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
              ActionTile(icon: Icons.copy_outlined, label: 'Copy', onTap: _copyAll),
              ActionTile(icon: Icons.clear_all, label: 'Clear', onTap: _clearConversation),
              ActionTile(icon: Icons.delete_outline, label: 'Delete', onTap: _deleteConversation),
              ActionTile(icon: Icons.share_outlined, label: 'Share', onTap: _shareAll),
            ],
          ),
        ),
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
              for (final action in actions)
                ActionTile(
                  icon: action == 'Copy'
                      ? Icons.copy_outlined
                      : action == 'Edit'
                          ? Icons.edit_outlined
                          : action == 'Regenerate'
                              ? Icons.refresh_outlined
                              : Icons.delete_outline,
                  label: action,
                  onTap: () => _runMessageAction(index, action),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runMessageAction(int index, String action) async {
    Navigator.pop(context);
    if (index < 0 || index >= _messages.length) return;
    final message = _messages[index];

    if (action == 'Copy') {
      _copyText(message.text);
      return;
    }

    if (action == 'Delete') {
      try {
        if (message.runtimeRecordId != null) {
          await _runtime.deleteMessage(
            conversationId: message.runtimeRecordId!,
            createdAt: message.createdAt ?? DateTime.now(),
            role: message.assistant ? 'assistant' : 'user',
            content: message.text,
          );
        }
        if (!mounted) return;
        setState(() => _messages.removeAt(index));
        await _persistConversation();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to delete message')),
          );
        }
      }
      return;
    }

    if (action == 'Regenerate') {
      const regenerated = 'Regenerated response — ready to continue.';
      try {
        if (message.runtimeRecordId != null) {
          await _runtime.updateMessage(
            conversationId: message.runtimeRecordId!,
            createdAt: message.createdAt ?? DateTime.now(),
            role: 'assistant',
            oldContent: message.text,
            newContent: regenerated,
          );
        }
        if (!mounted) return;
        setState(() => message.text = regenerated);
        await _persistConversation();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to regenerate message')),
          );
        }
      }
      return;
    }

    if (action == 'Edit') {
      await _editMessage(index);
    }
  }

  Future<void> _editMessage(int index) async {
    final message = _messages[index];
    final controller = TextEditingController(text: message.text);
    final value = await showModalBottomSheet<String>(
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
                    onPressed: () => Navigator.pop(sheet, controller.text.trim()),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (!mounted || value == null || value.isEmpty) return;
    try {
      if (message.runtimeRecordId != null) {
        await _runtime.updateMessage(
          conversationId: message.runtimeRecordId!,
          createdAt: message.createdAt ?? DateTime.now(),
          role: message.assistant ? 'assistant' : 'user',
          oldContent: message.text,
          newContent: value,
        );
      }
      if (!mounted) return;
      setState(() => message.text = value);
      await _persistConversation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update message')),
        );
      }
    }
  }

  void _copyText(String text) {
    if (text.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _deleteSelected() async {
    final ids = selected.toList()..sort((a, b) => b.compareTo(a));
    try {
      for (final index in ids) {
        if (index >= _messages.length) continue;
        final message = _messages[index];
        if (message.runtimeRecordId != null) {
          await _runtime.deleteMessage(
            conversationId: message.runtimeRecordId!,
            createdAt: message.createdAt ?? DateTime.now(),
            role: message.assistant ? 'assistant' : 'user',
            content: message.text,
          );
        }
      }
      if (!mounted) return;
      setState(() {
        for (final index in ids) {
          if (index < _messages.length) _messages.removeAt(index);
        }
        selected.clear();
      });
      await _persistConversation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete selected messages')),
        );
      }
    }
  }

  Future<void> _showSearch(BuildContext context) async {
    final result = await showShInternalSearch<int>(
      context: context,
      hintText: 'Search conversation',
      search: (query) => [
        for (var i = 0; i < _messages.length; i++)
          if (query.isEmpty ||
              _messages[i].text.toLowerCase().contains(query) ||
              _messages[i].time.toLowerCase().contains(query))
            ShSearchResult<int>(
              value: i,
              title: _messages[i].text.isEmpty ? 'Image message' : _messages[i].text,
              subtitle: _messages[i].time,
            ),
      ],
    );

    if (!mounted || result == null || !_messageScrollController.hasClients) return;
    await _messageScrollController.animateTo(
      (result * 115.0).clamp(0.0, _messageScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _renameConversation(BuildContext context, String title) async {
    final controller = TextEditingController(text: title);
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => SingleChildScrollView(
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
              'Rename conversation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(controller: controller, autofocus: true),
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
                    onPressed: () => Navigator.pop(sheet, controller.text.trim()),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    controller.dispose();

    if (!mounted || value == null || value.isEmpty) return;
    try {
      final id = _runtime.activeConversationId;
      if (id != null && id.isNotEmpty) {
        await _runtime.rename(conversationId: id, title: value);
      }
      conversationTitle.value = value;
      await _persistConversation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to rename conversation')),
        );
      }
    }
  }

  @override
  void dispose() {
    conversationRevision.removeListener(_resetConversation);
    _composerController.dispose();
    _searchController.dispose();
    _messageScrollController.dispose();
    _connectivitySubscription?.cancel();
    _internetCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selecting = selected.isNotEmpty;
    return Column(
      children: [
        ValueListenableBuilder<String>(
          valueListenable: conversationTitle,
          builder: (context, title, _) => ConversationHeader(
            title: title,
            onTitleTap: () => _renameConversation(context, title),
            onSearch: () => _showSearch(context),
            onMenu: _conversationMenu,
            isOnline: _isOnline,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            controller: _messageScrollController,
            children: [
              if (_isLoadingConversation)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
              if (!_isLoadingConversation) DateLabel(_conversationStatus),
              if (_isLoadingConversation) const DateLabel('Today'),
              for (var i = 0; i < _messages.length; i++)
                SelectableMessage(
                  index: i,
                  assistant: _messages[i].assistant,
                  selected: selected.contains(i),
                  onLongPress: () => setState(() => selected.add(i)),
                  onTap: () => selecting ? _toggleSelection(i) : null,
                  child: Message(
                    text: _messages[i].text,
                    time: _messages[i].time,
                    assistant: _messages[i].assistant,
                    attachmentPath: _messages[i].attachmentPath,
                    onAvatarTap: () => _messageActions(
                      i,
                      assistant: _messages[i].assistant,
                    ),
                  ),
                ),
              const SummaryCard(),
            ],
          ),
        ),
        if (selecting)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
            decoration: const BoxDecoration(color: shSurface),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionTile(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onTap: _deleteSelected,
                ),
              ],
            ),
          )
        else
          Composer(
            controller: _composerController,
            onSend: _send,
            onAttach: _showAttachments,
          ),
      ],
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selected.contains(index)) {
        selected.remove(index);
      } else {
        selected.add(index);
      }
    });
  }
}

class SelectableMessage extends StatelessWidget {
  const SelectableMessage({
    required this.index,
    required this.assistant,
    required this.selected,
    required this.onLongPress,
    required this.onTap,
    required this.child,
  });

  final int index;
  final bool assistant;
  final bool selected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: onLongPress,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? shPurple.withValues(alpha: .12) : Colors.transparent,
          ),
          child: Stack(
            children: [
              child,
              if (selected)
                const Positioned(
                  right: 4,
                  top: 4,
                  child: Icon(Icons.check_circle, size: 17),
                ),
            ],
          ),
        ),
      );
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
        json['text'] is String ? json['text'] as String : '',
        json['assistant'] == true,
        json['time'] is String ? json['time'] as String : 'Now',
        attachmentPath: json['attachmentPath'] is String
            ? json['attachmentPath'] as String
            : null,
        runtimeRecordId: json['runtimeRecordId'] is String
            ? json['runtimeRecordId'] as String
            : null,
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [shPurple, shElectric]),
                ),
                child: Icon(icon, size: 25),
              ),
              const SizedBox(height: 7),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
}

class ConversationHeader extends StatelessWidget {
  const ConversationHeader({
    super.key,
    required this.title,
    required this.onTitleTap,
    required this.onSearch,
    required this.onMenu,
    required this.isOnline,
  });

  final String title;
  final VoidCallback onTitleTap;
  final VoidCallback onSearch;
  final VoidCallback onMenu;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: topInset + 64,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              IconButton(
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, size: 30),
              ),
              const SizedBox(width: 2),
              SizedBox(
                width: 112,
                child: _AssistantHeaderIdentity(isOnline: isOnline),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: onTitleTap,
                  behavior: HitTestBehavior.opaque,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Search',
                onPressed: onSearch,
                icon: const Icon(Icons.search_outlined, size: 29),
              ),
              IconButton(
                tooltip: 'More',
                onPressed: onMenu,
                icon: const Icon(Icons.more_vert, size: 27),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantHeaderIdentity extends StatelessWidget {
  const _AssistantHeaderIdentity({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [shPurple, shElectric]),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/brand/unity.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 6,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontSize: 9, color: shMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DateLabel extends StatelessWidget {
  const DateLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(text, style: const TextStyle(fontSize: 9, color: shMuted)),
        ),
      );
}

Future<void> _openAttachment(BuildContext context, String path) async {
  final opened = await launchUrl(
    Uri.file(path),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No application can open this file.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class Message extends StatelessWidget {
  const Message({
    required this.text,
    required this.time,
    required this.assistant,
    required this.onAvatarTap,
    this.attachmentPath,
  });

  final String text;
  final String time;
  final bool assistant;
  final VoidCallback onAvatarTap;
  final String? attachmentPath;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: assistant
            ? null
            : const LinearGradient(colors: [shPurple, shElectric]),
        color: assistant ? shSurface2 : null,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(assistant ? 5 : 18),
          bottomRight: Radius.circular(assistant ? 18 : 5),
        ),
        border: assistant ? Border.all(color: shBorder) : null,
      ),
      child: Column(
        crossAxisAlignment:
            assistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (attachmentPath != null)
            _AttachmentPreview(
              path: attachmentPath!,
              onOpen: () => _openAttachment(context, attachmentPath!),
            ),
          if (attachmentPath != null && text.isNotEmpty)
            const SizedBox(height: 7),
          if (text.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.45),
              ),
            ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 9, color: shMuted)),
        ],
      ),
    );

    return Align(
      alignment: assistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (assistant)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAvatarTap,
                child: const ChatAvatar(assistant: true),
              ),
            ),
          bubble,
          if (!assistant)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAvatarTap,
                child: const ChatAvatar(assistant: false),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.path, required this.onOpen});
  final String path;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final category = StorageService.categoryFor(File(path));
    if (category == 'images') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          width: 245,
          height: 175,
          fit: BoxFit.cover,
        ),
      );
    }

    final icon = category == 'audio'
        ? Icons.audio_file_outlined
        : category == 'video'
            ? Icons.video_file_outlined
            : Icons.insert_drive_file_outlined;
    final name = path.split(Platform.pathSeparator).last;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onOpen,
      child: Container(
        width: 245,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: shSurface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: shBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({required this.assistant});
  final bool assistant;

  @override
  Widget build(BuildContext context) {
    if (assistant) {
      return Container(
        width: 22,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [shPurple, shElectric]),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/brand/unity.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
    }

    return ValueListenableBuilder<Uint8List?>(
      valueListenable: profilePhoto,
      builder: (context, photo, _) => CircleAvatar(
        radius: 11,
        backgroundColor: shSurface2,
        backgroundImage: photo != null ? MemoryImage(photo) : null,
        child: photo == null
            ? const Icon(Icons.person_outline, size: 13, color: shMuted)
            : null,
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: shBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today Summary',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              '• Meeting with team SH – 10:00 AM\n• Review document R6 – 1:00 PM\n• Implement feature A – 3:00 PM',
              style: TextStyle(fontSize: 10, color: shMuted, height: 1.55),
            ),
            SizedBox(height: 9),
            Text(
              'Top Priorities',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 5),
            Text(
              '1. Complete feature A\n2. Integrate calendar\n3. Write documentation',
              style: TextStyle(fontSize: 10, color: shMuted, height: 1.55),
            ),
          ],
        ),
      );
}

class Composer extends StatelessWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onAttach,
              icon: const Icon(Icons.add_circle_outline, size: 28),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50, maxHeight: 130),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Message SH...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 50,
              height: 50,
              child: IconButton(
                onPressed: onSend,
                tooltip: 'Send',
                icon: const Icon(Icons.arrow_upward, size: 25),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [shPurple, shElectric]),
                ),
                child: Icon(icon),
              ),
              const SizedBox(height: 7),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
}

class RecentConversationEntry {
  const RecentConversationEntry(this.title, this.preview);
  final String title;
  final String preview;
}

final ValueNotifier<List<RecentConversationEntry>> recentConversations =
    ValueNotifier<List<RecentConversationEntry>>([]);
