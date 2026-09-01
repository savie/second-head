import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/theme/sh_theme.dart';

class JourneyView extends StatefulWidget {
  const JourneyView({super.key});

  @override
  State<JourneyView> createState() => JourneyViewState();
}

class JourneyViewState extends State<JourneyView> {
  String filter = 'All';
  int? selected;

  final List<JourneyItem> items = [
    JourneyItem(
      'Project SH Roadmap',
      'Documented roadmap and key milestones',
      '2 days ago',
      'Knowledge',
      'The documented roadmap and key milestones for Second Head.',
      true,
    ),
    JourneyItem(
      'Client Meeting Notes',
      'Important notes from the meeting about feature priorities.',
      'Yesterday',
      'Experience',
      'Important notes captured from the client meeting and its feature priorities.',
      false,
    ),
    JourneyItem(
      'Ideas – AI Personalization',
      'Ideas about personalization based on user behavior.',
      'May 29',
      'Memory',
      'Ideas and retained context about personalization based on user behavior.',
      true,
    ),
    JourneyItem(
      'Reference – Runtime Contract',
      'Notes about runtime contract and future calling.',
      'May 25',
      'Knowledge',
      'Reference material describing the runtime contract and future calling.',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (selected != null) {
      final item = items[selected!];

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && mounted) {
            setState(() => selected = null);
          }
        },
        child: JourneyDetail(
          item: item,
          onBack: () => setState(() => selected = null),
          onChanged: () => setState(() {}),
          onDelete: () {
            final index = selected;
            if (index == null || index < 0 || index >= items.length) return;
            setState(() {
              items.removeAt(index);
              selected = null;
            });
          },
        ),
      );
    }

    final visible = [
      for (var i = 0; i < items.length; i++)
        if (filter == 'All' || items[i].type == filter) i,
    ];

    return Stack(
      children: [
        Column(
          children: [
            const ShTopBar(title: 'Journey'),
            JourneyFilters(
              value: filter,
              onChanged: (value) => setState(() => filter = value),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                itemCount: visible.length,
                itemBuilder: (_, index) {
                  final itemIndex = visible[index];
                  return JourneyCard(
                    item: items[itemIndex],
                    onTap: () => setState(() => selected = itemIndex),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton(
            heroTag: 'journey-add',
            onPressed: () => _create(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create new',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            for (final type in const ['Memory', 'Knowledge', 'Experience'])
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(type),
                onTap: () => Navigator.pop(sheet, type),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || type == null) return;

    final titleController = TextEditingController();
    final contentController = TextEditingController();
    var privatePolicy = true;

    final draft = await showModalBottomSheet<JourneyDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (_, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.of(sheet).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create $type',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                maxLines: 7,
                decoration: const InputDecoration(hintText: 'Write content...'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PolicyOption(
                      label: 'Private',
                      icon: Icons.lock_outline,
                      selected: privatePolicy,
                      onTap: () => setLocal(() => privatePolicy = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PolicyOption(
                      label: 'Public',
                      icon: Icons.public,
                      selected: !privatePolicy,
                      onTap: () => setLocal(() => privatePolicy = false),
                    ),
                  ),
                ],
              ),
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
                        final title = titleController.text.trim();
                        final content = contentController.text.trim();
                        if (title.isEmpty || content.isEmpty) return;
                        Navigator.pop(
                          sheet,
                          JourneyDraft(
                            title: title,
                            content: content,
                            isPrivate: privatePolicy,
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    titleController.dispose();
    contentController.dispose();

    if (!mounted || draft == null) return;

    setState(
      () => items.insert(
        0,
        JourneyItem(
          draft.title,
          draft.content,
          'Just now',
          type,
          draft.content,
          draft.isPrivate,
        ),
      ),
    );
  }
}

class JourneyFilters extends StatelessWidget {
  const JourneyFilters({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          for (final label in const ['All', 'Memory', 'Knowledge', 'Experience'])
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onChanged(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: value == label
                        ? shPurple.withValues(alpha: .16)
                        : shSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: value == label ? shPurple : shBorder,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: value == label ? Colors.white : shMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class JourneyItem {
  JourneyItem(
    this.title,
    this.subtitle,
    this.date,
    this.type,
    this.content,
    this.isPrivate,
  );

  String title;
  String subtitle;
  String date;
  String type;
  String content;
  bool isPrivate;
}

class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final JourneyItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: shBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: shPurple.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.type,
                          style: const TextStyle(
                            fontSize: 9,
                            color: shMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: shMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.date,
                    style: const TextStyle(fontSize: 9, color: shMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 25,
              color: shMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class JourneyDraft {
  const JourneyDraft({
    required this.title,
    required this.content,
    required this.isPrivate,
  });

  final String title;
  final String content;
  final bool isPrivate;
}

class JourneyDetail extends StatelessWidget {
  const JourneyDetail({
    super.key,
    required this.item,
    required this.onBack,
    required this.onChanged,
    required this.onDelete,
  });

  final JourneyItem item;
  final VoidCallback onBack;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShTopBar(
          title: item.type,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              tooltip: 'Edit',
              onPressed: () => _edit(context),
              icon: const Icon(Icons.edit_outlined, size: 19),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_outline, size: 19),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: shBorder),
                  ),
                  child: Text(
                    item.content,
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Policy',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: PolicyOption(
                        label: 'Private',
                        icon: Icons.lock_outline,
                        selected: item.isPrivate,
                        onTap: null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PolicyOption(
                        label: 'Public',
                        icon: Icons.public,
                        selected: !item.isPrivate,
                        onTap: null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context) async {
    final titleController = TextEditingController(text: item.title);
    final contentController = TextEditingController(text: item.content);
    var privatePolicy = item.isPrivate;

    final draft = await showModalBottomSheet<JourneyDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (_, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.of(sheet).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit ' + item.type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                maxLines: 7,
                decoration: const InputDecoration(hintText: 'Write content...'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PolicyOption(
                      label: 'Private',
                      icon: Icons.lock_outline,
                      selected: privatePolicy,
                      onTap: () => setLocal(() => privatePolicy = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PolicyOption(
                      label: 'Public',
                      icon: Icons.public,
                      selected: !privatePolicy,
                      onTap: () => setLocal(() => privatePolicy = false),
                    ),
                  ),
                ],
              ),
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
                        final title = titleController.text.trim();
                        final content = contentController.text.trim();
                        if (title.isEmpty || content.isEmpty) return;
                        Navigator.pop(
                          sheet,
                          JourneyDraft(
                            title: title,
                            content: content,
                            isPrivate: privatePolicy,
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    titleController.dispose();
    contentController.dispose();

    if (!context.mounted || draft == null) return;

    item.title = draft.title;
    item.content = draft.content;
    item.subtitle = draft.content;
    item.isPrivate = draft.isPrivate;
    onChanged();
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete journey'),
        content: const Text('Delete this journey entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) onDelete();
  }
}

class PolicyOption extends StatelessWidget {
  const PolicyOption({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? shPurple.withValues(alpha: .13) : shSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? shPurple : shBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
