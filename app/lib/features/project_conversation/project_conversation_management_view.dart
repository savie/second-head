import 'package:flutter/material.dart';

import '../conversation/conversation_runtime_bridge.dart';
import '../../core/theme/sh_theme.dart';

class ProjectConversationManagementView extends StatefulWidget {
  const ProjectConversationManagementView({super.key});

  @override
  State<ProjectConversationManagementView> createState() => _ProjectConversationManagementViewState();
}

class _ProjectConversationManagementViewState extends State<ProjectConversationManagementView> {
  final ConversationRuntimeBridge _runtime = const ConversationRuntimeBridge();
  final TextEditingController _searchController = TextEditingController();

  List<ProjectSummary> _projects = const [];
  List<ConversationSummary> _conversations = const [];
  bool _loading = true;
  String _query = '';
  ProjectSummary? _selectedProject;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _runtime.listProjects(),
        _runtime.listConversations(),
      ]);
      if (!mounted) return;
      final projects = results[0] as List<ProjectSummary>;
      final conversations = results[1] as List<ConversationSummary>;
      ProjectSummary? selected;
      if (_selectedProject != null) {
        for (final project in projects) {
          if (project.projectId == _selectedProject!.projectId) {
            selected = project;
            break;
          }
        }
      }
      setState(() {
        _projects = projects;
        _conversations = conversations;
        _selectedProject = selected;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(error);
    }
  }

  List<ProjectSummary> get _visibleProjects => _projects
      .where((p) => _query.isEmpty || p.name.toLowerCase().contains(_query))
      .toList();

  List<ConversationSummary> get _visibleConversations {
    final scoped = _selectedProject == null
        ? _conversations.where((c) => c.projectId == null)
        : _conversations.where((c) => c.projectId == _selectedProject!.projectId);
    return scoped
        .where((c) => _query.isEmpty || c.title.toLowerCase().contains(_query) || c.preview.toLowerCase().contains(_query))
        .toList();
  }

  int _projectConversationCount(String projectId) =>
      _conversations.where((c) => c.projectId == projectId).length;

  Future<void> _createProject() async {
    final name = await _textDialog(title: 'New Project', label: 'Project name');
    if (name == null) return;
    try {
      await _runtime.createProject(name);
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _createConversation() async {
    final result = await showDialog<_ConversationCreateResult>(
      context: context,
      builder: (_) => _ConversationCreateDialog(),
    );
    if (result == null) return;
    try {
      await _runtime.createConversation(
        projectId: _selectedProject?.projectId,
        title: result.title,
      );
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _renameProject(ProjectSummary project) async {
    final name = await _textDialog(
      title: 'Rename Project',
      label: 'Project name',
      initialValue: project.name,
    );
    if (name == null) return;
    try {
      await _runtime.renameProject(projectId: project.projectId, name: name);
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteProject(ProjectSummary project) async {
    final confirmed = await _confirm(
      'Delete project?',
      'This deletes all conversations and messages inside “${project.name}”. Conversations outside this project are not affected.',
    );
    if (!confirmed) return;
    try {
      await _runtime.deleteProject(projectId: project.projectId);
      if (mounted && _selectedProject?.projectId == project.projectId) {
        setState(() => _selectedProject = null);
      }
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _renameConversation(ConversationSummary conversation) async {
    final title = await _textDialog(
      title: 'Rename Conversation',
      label: 'Conversation name',
      initialValue: conversation.title,
    );
    if (title == null) return;
    try {
      await _runtime.rename(conversationId: conversation.conversationId, title: title);
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _moveConversation(ConversationSummary conversation) async {
    final target = await showDialog<String?>(
      context: context,
      builder: (context) => _ProjectPicker(
        projects: _projects,
        currentProjectId: conversation.projectId,
      ),
    );
    if (target == null) return;
    try {
      if (target == '__remove__') {
        await _runtime.removeConversationFromProject(
          conversationId: conversation.conversationId,
        );
      } else {
        await _runtime.moveConversation(
          conversationId: conversation.conversationId,
          projectId: target,
        );
      }
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteConversation(ConversationSummary conversation) async {
    final confirmed = await _confirm(
      'Delete conversation?',
      'This permanently deletes the conversation and its messages.',
    );
    if (!confirmed) return;
    try {
      await _runtime.deleteConversation(conversationId: conversation.conversationId);
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<String?> _textDialog({required String title, required String label, String? initialValue}) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => _ManagerTextEditor(
        title: title,
        label: label,
        initialValue: initialValue,
      ),
    );
    return value?.trim().isEmpty == true ? null : value?.trim();
  }

  Future<bool> _confirm(String title, String message) async => await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: shSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: shBorder),
          ),
          title: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(28),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          ]),
          content: Text(message, style: const TextStyle(color: shMuted, height: 1.45)),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ?? false;

  void _showError(Object error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: shSurface2,
          content: Text(error.toString()),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  void _openProject(ProjectSummary project) {
    _searchController.clear();
    setState(() => _selectedProject = project);
  }

  void _closeProject() {
    _searchController.clear();
    setState(() => _selectedProject = null);
  }

  @override
  Widget build(BuildContext context) {
    final project = _selectedProject;
    return Scaffold(
      backgroundColor: shBackground,
      appBar: AppBar(
        backgroundColor: shBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: project == null ? 'Back' : 'Back to Management',
          onPressed: project == null ? () => Navigator.maybePop(context) : _closeProject,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project?.name ?? 'Management', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              project == null ? 'Organize your conversations and projects.' : 'Conversations in this project.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: shMuted, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(tooltip: 'Refresh', onPressed: _load, icon: const Icon(Icons.refresh_rounded, size: 20)),
          const SizedBox(width: 4),
          if (project != null)
            FilledButton.icon(
              onPressed: _createConversation,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Conversation'),
              style: FilledButton.styleFrom(
                backgroundColor: shPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _createProject,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Project'),
              style: FilledButton.styleFrom(
                backgroundColor: shPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
            ),
          const SizedBox(width: 20),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: shPurple,
              backgroundColor: shSurface,
              onRefresh: _load,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      _buildSearch(project != null),
                      const SizedBox(height: 22),
                      if (project == null) ...[
                        _buildConversations(),
                        const SizedBox(height: 28),
                        _buildProjects(wide: wide),
                      ] else
                        _buildProjectDetail(project),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSearch(bool inProject) => Container(
        height: 48,
        decoration: BoxDecoration(
          color: shSurface.withAlpha(210),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: shBorder),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 12.5),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, size: 19, color: shMuted),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.close_rounded, size: 17, color: shMuted), onPressed: _searchController.clear),
            hintText: inProject ? 'Search conversations in this project...' : 'Search projects or conversations...',
            hintStyle: const TextStyle(fontSize: 12, color: shMuted),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      );

  Widget _buildConversations() => _ManagementSection(
        title: 'Conversations',
        count: _visibleConversations.length,
        icon: Icons.chat_bubble_outline_rounded,
        actionLabel: 'New Conversation',
        onAction: _createConversation,
        child: _visibleConversations.isEmpty
            ? _emptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: _query.isEmpty ? 'No conversations yet' : 'No conversations found',
                subtitle: _query.isEmpty ? 'Start a new conversation to capture your thoughts.' : 'Nothing matched “${_searchController.text.trim()}”.',
                onCreate: _query.isEmpty ? _createConversation : null,
                createLabel: 'New Conversation',
              )
            : Column(
                children: _visibleConversations
                    .map((conversation) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _ConversationTile(
                            conversation: conversation,
                            onRename: () => _renameConversation(conversation),
                            onMove: () => _moveConversation(conversation),
                            onDelete: () => _deleteConversation(conversation),
                          ),
                        ))
                    .toList(),
              ),
      );

  Widget _buildProjects({required bool wide}) => _ManagementSection(
        title: 'Projects',
        count: _visibleProjects.length,
        icon: Icons.folder_outlined,
        actionLabel: 'New Project',
        onAction: _createProject,
        child: _visibleProjects.isEmpty
            ? _emptyState(
                icon: Icons.folder_outlined,
                title: _query.isEmpty ? 'No projects yet' : 'No projects found',
                subtitle: _query.isEmpty ? 'Create a project to organize your conversations.' : 'Nothing matched “${_searchController.text.trim()}”.',
                onCreate: _query.isEmpty ? _createProject : null,
                createLabel: 'New Project',
              )
            : Column(
                children: _visibleProjects
                    .map((project) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ProjectTile(
                            project: project,
                            conversationCount: _projectConversationCount(project.projectId),
                            onOpen: () => _openProject(project),
                            onRename: () => _renameProject(project),
                            onDelete: () => _deleteProject(project),
                          ),
                        ))
                    .toList(),
              ),
      );

  Widget _buildProjectDetail(ProjectSummary project) => _ManagementSection(
        title: 'Conversations',
        count: _visibleConversations.length,
        icon: Icons.chat_bubble_outline_rounded,
        actionLabel: 'New Conversation',
        onAction: _createConversation,
        child: _visibleConversations.isEmpty
            ? _emptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: _query.isEmpty ? 'No conversations yet' : 'No conversations found',
                subtitle: _query.isEmpty ? 'Start a conversation in ${project.name}.' : 'Nothing matched “${_searchController.text.trim()}”.',
                onCreate: _query.isEmpty ? _createConversation : null,
                createLabel: 'New Conversation',
              )
            : Column(
                children: _visibleConversations
                    .map((conversation) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _ConversationTile(
                            conversation: conversation,
                            onRename: () => _renameConversation(conversation),
                            onMove: () => _moveConversation(conversation),
                            onDelete: () => _deleteConversation(conversation),
                          ),
                        ))
                    .toList(),
              ),
      );

  Widget _emptyState({required IconData icon, required String title, required String subtitle, VoidCallback? onCreate, required String createLabel}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(color: shSurface.withAlpha(150), borderRadius: BorderRadius.circular(16), border: Border.all(color: shBorder)),
        child: Column(children: [
          Icon(icon, size: 34, color: shMuted),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: shMuted, height: 1.45)),
          if (onCreate != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_rounded, size: 17), label: Text(createLabel)),
          ],
        ]),
      );
}

class _ManagerTextEditor extends StatefulWidget {
  const _ManagerTextEditor({required this.title, required this.label, this.initialValue});
  final String title;
  final String label;
  final String? initialValue;

  @override
  State<_ManagerTextEditor> createState() => _ManagerTextEditorState();
}

class _ManagerTextEditorState extends State<_ManagerTextEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: shSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: shBorder)),
        title: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: TextField(controller: _controller, autofocus: true, decoration: InputDecoration(labelText: widget.label), onSubmitted: (_) => Navigator.pop(context, _controller.text.trim())),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: const Text('Save')),
        ],
      );
}

class _ManagementSection extends StatelessWidget {
  const _ManagementSection({required this.title, required this.count, required this.icon, required this.actionLabel, required this.onAction, required this.child});
  final String title;
  final int count;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(color: shSurface.withAlpha(115), borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: shPurple.withAlpha(22), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: shPurple)),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(20)), child: Text('$count', style: const TextStyle(fontSize: 9, color: shMuted, fontWeight: FontWeight.w600))),
            const Spacer(),
            OutlinedButton.icon(onPressed: onAction, icon: const Icon(Icons.add_rounded, size: 15), label: Text(actionLabel, style: const TextStyle(fontSize: 10)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)))),
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project, required this.conversationCount, required this.onOpen, required this.onRename, required this.onDelete});
  final ProjectSummary project;
  final int conversationCount;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(13), border: Border.all(color: shBorder)),
        child: ListTile(
          onTap: onOpen,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: shPurple.withAlpha(22), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.folder_outlined, color: shPurple, size: 20)),
          title: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          subtitle: Padding(padding: const EdgeInsets.only(top: 2), child: Text('$conversationCount conversations', style: const TextStyle(fontSize: 9, color: shMuted))),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('$conversationCount', style: const TextStyle(fontSize: 10, color: shMuted)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 19, color: shMuted),
            _ActionMenu(items: [
              _ActionItem(icon: Icons.edit_outlined, label: 'Rename', onTap: onRename),
              _ActionItem(icon: Icons.delete_outline_rounded, label: 'Delete', onTap: onDelete, destructive: true),
            ]),
          ]),
        ),
      );
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onRename, required this.onMove, required this.onDelete});
  final ConversationSummary conversation;
  final VoidCallback onRename;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(13), border: Border.all(color: shBorder)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: shPurple.withAlpha(18), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat_bubble_outline_rounded, color: shPurple, size: 19)),
          title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          subtitle: conversation.preview.isEmpty ? null : Text(conversation.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: shMuted)),
          trailing: _ActionMenu(items: [
            _ActionItem(icon: Icons.edit_outlined, label: 'Rename', onTap: onRename),
            _ActionItem(icon: Icons.folder_open_outlined, label: 'Move to Project', onTap: onMove),
            _ActionItem(icon: Icons.delete_outline_rounded, label: 'Delete', onTap: onDelete, destructive: true),
          ]),
        ),
      );
}

class _ActionItem {
  const _ActionItem({required this.icon, required this.label, required this.onTap, this.destructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({required this.items});
  final List<_ActionItem> items;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_ActionItem>(
        tooltip: 'More actions',
        icon: const Icon(Icons.more_vert_rounded, size: 19, color: shMuted),
        color: shSurface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: shBorder)),
        onSelected: (item) => item.onTap(),
        itemBuilder: (_) => items.map((item) => PopupMenuItem<_ActionItem>(
              value: item,
              child: Row(children: [Icon(item.icon, size: 18, color: item.destructive ? Colors.redAccent : shMuted), const SizedBox(width: 10), Text(item.label, style: TextStyle(fontSize: 12, color: item.destructive ? Colors.redAccent : null))]),
            )).toList(),
      );
}

class _ConversationCreateResult {
  const _ConversationCreateResult({required this.title});
  final String title;
}

class _ConversationCreateDialog extends StatefulWidget {
  const _ConversationCreateDialog();

  @override
  State<_ConversationCreateDialog> createState() => _ConversationCreateDialogState();
}

class _ConversationCreateDialogState extends State<_ConversationCreateDialog> {
  final _controller = TextEditingController(text: 'New Conversation');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: shSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: shBorder)),
        title: const Text('New Conversation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: TextField(controller: _controller, autofocus: true, decoration: const InputDecoration(labelText: 'Conversation name')),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final title = _controller.text.trim();
              if (title.isNotEmpty) Navigator.pop(context, _ConversationCreateResult(title: title));
            },
            child: const Text('Create'),
          ),
        ],
      );
}

class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({required this.projects, required this.currentProjectId});
  final List<ProjectSummary> projects;
  final String? currentProjectId;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        backgroundColor: shSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: shBorder)),
        title: const Text('Move conversation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        children: [
          ...projects.where((p) => p.projectId != currentProjectId).map((p) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, p.projectId),
                child: Row(children: [const Icon(Icons.folder_outlined, size: 18, color: shMuted), const SizedBox(width: 10), Expanded(child: Text(p.name, overflow: TextOverflow.ellipsis))]),
              )),
          const Divider(color: shBorder),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, '__remove__'), child: const Row(children: [Icon(Icons.folder_off_outlined, size: 18, color: shMuted), SizedBox(width: 10), Text('Remove from Project')])),
          SimpleDialogOption(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: shMuted))),
        ],
      );
}
