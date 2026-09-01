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
    final visible = [
      for (var i = 0; i < items.length; i++)
        if (filter == 'All' || items[i].type == filter) i,
    ];

    return Stack(
      children: [
        Column(
          children: [
            ShTopBar(
              title: 'Journey',
              onSearch: () => _search(context),
            ),
            JourneyFilters(
              value: filter,
              onChanged: (value) => setState(() => filter = value),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                itemCount: visible.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 142,
                ),
                itemBuilder: (_, index) {
                  final itemIndex = visible[index];
                  return JourneyCard(
                    item: items[itemIndex],
                    onTap: () => _openDetail(context, itemIndex),
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

  Future<void> _search(BuildContext context) async {
    final result = await showShInternalSearch<int>(
      context: context,
      hintText: 'Search Journey',
      search: (query) {
        return [
          for (var i = 0; i < items.length; i++)
            if (query.isEmpty ||
                [
                  items[i].title,
                  items[i].subtitle,
                  items[i].content,
                  items[i].type,
                ].any((value) => value.toLowerCase().contains(query)))
              ShSearchResult<int>(
                value: i,
                title: items[i].title,
                subtitle: items[i].type,
              ),
        ];
      },
    );

    if (!mounted || result == null || result < 0 || result >= items.length) {
      return;
    }

    _openDetail(context, result);
  }

  void _openDetail(BuildContext context, int itemIndex) {
    if (itemIndex < 0 || itemIndex >= items.length) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JourneyDetail(
          item: items[itemIndex],
          onChanged: () => setState(() {}),
          onDelete: () {
            if (itemIndex < 0 || itemIndex >= items.length) return;
            setState(() => items.removeAt(itemIndex));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create new',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              for (final type in const ['Memory', 'Knowledge', 'Experience'])
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text(type),
                  onTap: () => Navigator.of(sheet).pop(type),
                ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || type == null) return;

    final draft = await _showJourneyEditor(
      context,
      title: 'Create $type',
    );

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          for (final label in const ['All', 'Memory', 'Knowledge', 'Experience'])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => onChanged(label),
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == label
                          ? shPurple.withValues(alpha: .16)
                          : shSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: value == label ? shPurple : shBorder,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: value == label ? Colors.white : shMuted,
                        ),
                      ),
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

  Color get _accent {
    switch (item.type) {
      case 'Memory':
        return shPurple;
      case 'Experience':
        return shCyan;
      default:
        return shElectric;
    }
  }

  IconData get _icon {
    switch (item.type) {
      case 'Memory':
        return Icons.psychology_outlined;
      case 'Experience':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.menu_book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return CustomPaint(
      painter: _JourneyCardPainter(accent: accent),
      child: ClipPath(
        clipper: _JourneyCardClipper(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shBackground.withValues(alpha: .82),
                          border: Border.all(
                            color: accent.withValues(alpha: .48),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: .12),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(_icon, size: 20, color: accent),
                      ),
                      const Spacer(),
                      Text(
                        item.type,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: .04),
                          border: Border.all(
                            color: accent.withValues(alpha: .42),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: accent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.date,
                        style: const TextStyle(
                          fontSize: 8,
                          color: shMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(20, 0)
      ..lineTo(size.width - 48, 0)
      ..quadraticBezierTo(size.width - 8, 2, size.width - 3, 25)
      ..lineTo(size.width, size.height - 42)
      ..quadraticBezierTo(
        size.width - 2,
        size.height - 7,
        size.width - 38,
        size.height - 3,
      )
      ..lineTo(40, size.height)
      ..quadraticBezierTo(4, size.height - 3, 2, size.height - 36)
      ..lineTo(0, 38)
      ..quadraticBezierTo(2, 4, 20, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _JourneyCardClipper oldClipper) => false;
}

class _JourneyCardPainter extends CustomPainter {
  _JourneyCardPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _JourneyCardClipper().getClip(size);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: .12),
          shSurface.withValues(alpha: .96),
          accent.withValues(alpha: .07),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, fill);

    final border = Paint()
      ..color = accent.withValues(alpha: .76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _JourneyCardPainter oldDelegate) =>
      oldDelegate.accent != accent;
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

Future<JourneyDraft?> _showJourneyEditor(
  BuildContext context, {
  required String title,
  String initialTitle = '',
  String initialContent = '',
  bool initialPrivate = true,
}) {
  // Editor is a real route, not an overlay bottom-sheet. This keeps its
  // inherited-widget lifecycle isolated from the navigation shell and avoids
  // the framework _dependents.isEmpty assertion when saving/cancelling or
  // changing policy.
  return Navigator.of(context).push<JourneyDraft>(
    MaterialPageRoute<JourneyDraft>(
      builder: (_) => Scaffold(
        backgroundColor: shBackground,
        body: SafeArea(
          child: JourneyEditorSheet(
            title: title,
            initialTitle: initialTitle,
            initialContent: initialContent,
            initialPrivate: initialPrivate,
          ),
        ),
      ),
    ),
  );
}

class JourneyEditorSheet extends StatefulWidget {
  const JourneyEditorSheet({
    super.key,
    required this.title,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialPrivate = true,
  });

  final String title;
  final String initialTitle;
  final String initialContent;
  final bool initialPrivate;

  @override
  State<JourneyEditorSheet> createState() => _JourneyEditorSheetState();
}

class _JourneyEditorSheetState extends State<JourneyEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _privatePolicy;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _privatePolicy = widget.initialPrivate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final newTitle = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (newTitle.isEmpty || content.isEmpty) return;

    Navigator.of(context).pop(
      JourneyDraft(
        title: newTitle,
        content: content,
        isPrivate: _privatePolicy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              autofocus: widget.initialTitle.isEmpty,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              minLines: 4,
              maxLines: 7,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(hintText: 'Write content...'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PolicyOption(
                    label: 'Private',
                    icon: Icons.lock_outline,
                    selected: _privatePolicy,
                    onTap: () => setState(() => _privatePolicy = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PolicyOption(
                    label: 'Public',
                    icon: Icons.public,
                    selected: !_privatePolicy,
                    onTap: () => setState(() => _privatePolicy = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JourneyDetail extends StatelessWidget {
  const JourneyDetail({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final JourneyItem item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Detail screens own horizontal gestures so the global tab-swipe
    // recognizer cannot hijack Android back / in-page horizontal gestures.
    return Scaffold(
      backgroundColor: shBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) {},
        onHorizontalDragUpdate: (_) {},
        onHorizontalDragEnd: (_) {},
        child: Column(
          children: [
            ShTopBar(
          title: item.type,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
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
                        onTap: () {
                          item.isPrivate = true;
                          onChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PolicyOption(
                        label: 'Public',
                        icon: Icons.public,
                        selected: !item.isPrivate,
                        onTap: () {
                          item.isPrivate = false;
                          onChanged();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final draft = await _showJourneyEditor(
      context,
      title: 'Edit ${item.type}',
      initialTitle: item.title,
      initialContent: item.content,
      initialPrivate: item.isPrivate,
    );

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
