import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/theme/sh_theme.dart';
import 'semantic_hook.dart';

enum ShSemanticDomain { memory, knowledge, experience }

extension ShSemanticDomainLabel on ShSemanticDomain {
  String get label {
    switch (this) {
      case ShSemanticDomain.memory: return 'Memory';
      case ShSemanticDomain.knowledge: return 'Knowledge';
      case ShSemanticDomain.experience: return 'Experience';
    }
  }
  IconData get icon {
    switch (this) {
      case ShSemanticDomain.memory: return Icons.psychology_outlined;
      case ShSemanticDomain.knowledge: return Icons.menu_book_outlined;
      case ShSemanticDomain.experience: return Icons.auto_awesome_outlined;
    }
  }
}

class SemanticDomainView extends StatefulWidget {
  const SemanticDomainView({super.key, required this.domain});
  final ShSemanticDomain domain;
  @override
  State<SemanticDomainView> createState() => _SemanticDomainViewState();
}

class _SemanticDomainViewState extends State<SemanticDomainView> {
  late final List<SemanticDomainItem> items = [
    SemanticDomainItem(
      title: _seedTitle(widget.domain),
      content: _seedContent(widget.domain),
      date: 'Local',
      isPrivate: true,
      semanticSourceId: null,
    ),
  ];

  String _seedTitle(ShSemanticDomain domain) {
    switch (domain) {
      case ShSemanticDomain.memory: return 'Personal Context';
      case ShSemanticDomain.knowledge: return 'SH Reference';
      case ShSemanticDomain.experience: return 'Recent Experience';
    }
  }

  String _seedContent(ShSemanticDomain domain) {
    switch (domain) {
      case ShSemanticDomain.memory: return 'Retained context associated with the user.';
      case ShSemanticDomain.knowledge: return 'Reference material available to Second Head.';
      case ShSemanticDomain.experience: return 'An experience record captured for later use.';
    }
  }

  @override
  void initState() {
    super.initState();
    _syncSemanticRecords();
    shSemanticRecords.addListener(_syncSemanticRecords);
  }

  @override
  void dispose() {
    shSemanticRecords.removeListener(_syncSemanticRecords);
    super.dispose();
  }

  void _syncSemanticRecords() {
    final records = shSemanticRecords.value
        .where((record) => record.domain == widget.domain)
        .toList();
    for (final record in records) {
      final exists = items.any((item) => item.semanticSourceId == record.sourceId + '|' + record.content);
      if (!exists) {
        items.insert(0, SemanticDomainItem(
          title: record.content,
          content: 'Created from explicit Conversation command.',
          date: 'Just now',
          isPrivate: true,
          semanticSourceId: record.sourceId + '|' + record.content,
        ));
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final domain = widget.domain;
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: domain.label,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                tooltip: 'Journey',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const ShSectionNavIcon.journey(),
              ),
            ],
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No entries yet.', style: TextStyle(color: shMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => _DomainCard(
                      item: items[index],
                      icon: domain.icon,
                      onTap: () => _edit(index),
                      onDelete: () => _delete(index),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'domain-add-' + domain.name,
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _create() async {
    final draft = await _editor('Create ' + widget.domain.label);
    if (!mounted || draft == null) return;
    setState(() => items.insert(0, SemanticDomainItem(
      title: draft.title, content: draft.content, date: 'Just now', isPrivate: draft.isPrivate,
    )));
  }

  Future<void> _edit(int index) async {
    final item = items[index];
    final draft = await _editor(
      'Edit ' + widget.domain.label,
      initialTitle: item.title,
      initialContent: item.content,
      initialPrivate: item.isPrivate,
    );
    if (!mounted || draft == null) return;
    setState(() {
      item.title = draft.title;
      item.content = draft.content;
      item.isPrivate = draft.isPrivate;
    });
  }

  Future<void> _delete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Delete ' + widget.domain.label),
        content: const Text('Delete this local entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) setState(() => items.removeAt(index));
  }

  Future<SemanticDomainDraft?> _editor(
    String title, {
    String initialTitle = '',
    String initialContent = '',
    bool initialPrivate = true,
  }) {
    final titleController = TextEditingController(text: initialTitle);
    final contentController = TextEditingController(text: initialContent);
    var privatePolicy = initialPrivate;
    return showModalBottomSheet<SemanticDomainDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, MediaQuery.viewInsetsOf(sheet).bottom + 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(controller: titleController, autofocus: initialTitle.isEmpty, decoration: const InputDecoration(hintText: 'Title')),
                const SizedBox(height: 10),
                TextField(controller: contentController, minLines: 4, maxLines: 7, decoration: const InputDecoration(hintText: 'Write content...')),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Policy(label: 'Owner Only', icon: Icons.lock_outline, selected: privatePolicy, onTap: () => setSheetState(() => privatePolicy = true))),
                  const SizedBox(width: 10),
                  Expanded(child: _Policy(label: 'Shared', icon: Icons.public, selected: !privatePolicy, onTap: () => setSheetState(() => privatePolicy = false))),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheet), child: const Text('Cancel'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton(
                    onPressed: () {
                      final t = titleController.text.trim();
                      final c = contentController.text.trim();
                      if (t.isEmpty || c.isEmpty) return;
                      Navigator.pop(sheet, SemanticDomainDraft(title: t, content: c, isPrivate: privatePolicy));
                    },
                    child: const Text('Save'),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      titleController.dispose();
      contentController.dispose();
    });
  }
}

class SemanticDomainItem {
  SemanticDomainItem({required this.title, required this.content, required this.date, required this.isPrivate, this.semanticSourceId});
  String title;
  String content;
  String date;
  bool isPrivate;
  final String? semanticSourceId;
}

class SemanticDomainDraft {
  const SemanticDomainDraft({required this.title, required this.content, required this.isPrivate});
  final String title;
  final String content;
  final bool isPrivate;
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({required this.item, required this.icon, required this.onTap, required this.onDelete});
  final SemanticDomainItem item;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(
    color: shSurface,
    child: ListTile(
      leading: Icon(icon, color: shPurple),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.content, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<String>(
        onSelected: (value) { if (value == 'edit') onTap(); if (value == 'delete') onDelete(); },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: onTap,
    ),
  );
}

class _Policy extends StatelessWidget {
  const _Policy({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? shPurple.withValues(alpha: .13) : shSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? shPurple : shBorder),
      ),
      child: Row(children: [
        Icon(icon, size: 19),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        if (selected) const Icon(Icons.check_rounded, size: 17),
      ]),
    ),
  );
}
