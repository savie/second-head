import 'package:flutter/material.dart';

import '../conversation/conversation_runtime_bridge.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim().toLowerCase()));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([_runtime.listProjects(), _runtime.listConversations()]);
      if (!mounted) return;
      setState(() {
        _projects = results[0] as List<ProjectSummary>;
        _conversations = results[1] as List<ConversationSummary>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(error);
    }
  }

  List<ProjectSummary> get _visibleProjects => _projects.where((p) => _query.isEmpty || p.name.toLowerCase().contains(_query)).toList();

  List<ConversationSummary> get _visibleConversations => _conversations.where((c) => _query.isEmpty || c.title.toLowerCase().contains(_query) || c.preview.toLowerCase().contains(_query)).toList();

  Future<void> _createProject() async {
    final name = await _textDialog(title: 'New Project', label: 'Project name');
    if (name == null) return;
    try { await _runtime.createProject(name); await _load(); } catch (error) { _showError(error); }
  }

  Future<void> _createConversation() async {
    final result = await showDialog<_ConversationCreateResult>(
      context: context,
      builder: (_) => _ConversationCreateDialog(projects: _projects),
    );
    if (result == null) return;
    try {
      await _runtime.createConversation(projectId: result.projectId, title: result.title);
      await _load();
    } catch (error) { _showError(error); }
  }

  Future<void> _renameProject(ProjectSummary project) async {
    final name = await _textDialog(title: 'Rename Project', label: 'Project name', initialValue: project.name);
    if (name == null) return;
    try { await _runtime.renameProject(projectId: project.projectId, name: name); await _load(); } catch (error) { _showError(error); }
  }

  Future<void> _deleteProject(ProjectSummary project) async {
    final confirmed = await _confirm('Delete project?', 'This deletes all conversations and messages inside “${project.name}”. Conversations outside this project are not affected.');
    if (!confirmed) return;
    try { await _runtime.deleteProject(projectId: project.projectId); await _load(); } catch (error) { _showError(error); }
  }

  Future<void> _renameConversation(ConversationSummary conversation) async {
    final title = await _textDialog(title: 'Rename Conversation', label: 'Conversation name', initialValue: conversation.title);
    if (title == null) return;
    try { await _runtime.rename(conversationId: conversation.conversationId, title: title); await _load(); } catch (error) { _showError(error); }
  }

  Future<void> _moveConversation(ConversationSummary conversation) async {
    final target = await showDialog<String?>(context: context, builder: (context) => _ProjectPicker(projects: _projects, currentProjectId: conversation.projectId));
    if (target == null) return;
    try {
      if (target == '__remove__') {
        await _runtime.removeConversationFromProject(conversationId: conversation.conversationId);
      } else {
        await _runtime.moveConversation(conversationId: conversation.conversationId, projectId: target);
      }
      await _load();
    } catch (error) { _showError(error); }
  }

  Future<void> _deleteConversation(ConversationSummary conversation) async {
    final confirmed = await _confirm('Delete conversation?', 'This permanently deletes the conversation and its messages.');
    if (!confirmed) return;
    try { await _runtime.deleteConversation(conversationId: conversation.conversationId); await _load(); } catch (error) { _showError(error); }
  }

  Future<String?> _textDialog({required String title, required String label, String? initialValue}) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: label), onSubmitted: (_) => Navigator.pop(context, controller.text.trim())),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save'))],
      ),
    );
    controller.dispose();
    return value?.trim().isEmpty == true ? null : value?.trim();
  }

  Future<bool> _confirm(String title, String message) async => await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title), content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))],
    ),
  ) ?? false;

  void _showError(Object error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Projects & Conversations'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  TextField(controller: _searchController, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search projects and conversations', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                  const SizedBox(height: 28),
                  _sectionHeader(context, 'Projects', Icons.folder_outlined, _createProject),
                  const SizedBox(height: 8),
                  if (_visibleProjects.isEmpty) _empty('No projects found.') else ..._visibleProjects.map((project) => _ProjectTile(project: project, onRename: () => _renameProject(project), onDelete: () => _deleteProject(project))),
                  const SizedBox(height: 28),
                  _sectionHeader(context, 'Conversations', Icons.chat_bubble_outline, _createConversation),
                  const SizedBox(height: 8),
                  if (_visibleConversations.isEmpty) _empty('No conversations found.') else ..._visibleConversations.map((conversation) => _ConversationTile(conversation: conversation, projectName: _projectName(conversation.projectId), onRename: () => _renameConversation(conversation), onMove: () => _moveConversation(conversation), onDelete: () => _deleteConversation(conversation))),
                  const SizedBox(height: 12),
                  Text('Management actions are handled here; the sidebar remains focused on navigation and recent items.', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon, VoidCallback? onAdd) => Row(children: [Icon(icon), const SizedBox(width: 10), Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)), if (onAdd != null) IconButton(onPressed: onAdd, icon: const Icon(Icons.add))]);

  Widget _empty(String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 18), child: Center(child: Text(text)));

  String _projectName(String? projectId) => projectId == null ? 'No Project' : _projects.where((p) => p.projectId == projectId).map((p) => p.name).firstOrNull ?? 'Project';
}

class _ConversationCreateResult {
  const _ConversationCreateResult({required this.title, this.projectId});
  final String title;
  final String? projectId;
}

class _ConversationCreateDialog extends StatefulWidget {
  const _ConversationCreateDialog({required this.projects});
  final List<ProjectSummary> projects;
  @override
  State<_ConversationCreateDialog> createState() => _ConversationCreateDialogState();
}

class _ConversationCreateDialogState extends State<_ConversationCreateDialog> {
  final _controller = TextEditingController(text: 'New Conversation');
  String? _projectId;

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New Conversation'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _controller, autofocus: true, decoration: const InputDecoration(labelText: 'Conversation name')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String?>(
        value: _projectId,
        decoration: const InputDecoration(labelText: 'Project'),
        items: [const DropdownMenuItem<String?>(value: null, child: Text('No Project')), ...widget.projects.map((p) => DropdownMenuItem<String?>(value: p.projectId, child: Text(p.name, overflow: TextOverflow.ellipsis)))],
        onChanged: (value) => setState(() => _projectId = value),
      ),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: () { final title = _controller.text.trim(); if (title.isNotEmpty) Navigator.pop(context, _ConversationCreateResult(title: title, projectId: _projectId)); }, child: const Text('Create')),
    ],
  );
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project, required this.onRename, required this.onDelete});
  final ProjectSummary project;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: const Icon(Icons.folder_outlined), title: Text(project.name), subtitle: const Text('Project'), trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'rename') onRename(); if (value == 'delete') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'rename', child: Text('Rename')), PopupMenuItem(value: 'delete', child: Text('Delete'))])));
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.projectName, required this.onRename, required this.onMove, required this.onDelete});
  final ConversationSummary conversation;
  final String projectName;
  final VoidCallback onRename;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: const Icon(Icons.chat_bubble_outline), title: Text(conversation.title), subtitle: Text(projectName), trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'rename') onRename(); if (value == 'move') onMove(); if (value == 'delete') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'rename', child: Text('Rename')), PopupMenuItem(value: 'move', child: Text('Move / Remove from Project')), PopupMenuItem(value: 'delete', child: Text('Delete'))])));
}

class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({required this.projects, required this.currentProjectId});
  final List<ProjectSummary> projects;
  final String? currentProjectId;
  @override
  Widget build(BuildContext context) => SimpleDialog(title: const Text('Move conversation'), children: [
    ...projects.where((p) => p.projectId != currentProjectId).map((p) => SimpleDialogOption(onPressed: () => Navigator.pop(context, p.projectId), child: Text(p.name))),
    SimpleDialogOption(onPressed: () => Navigator.pop(context, '__remove__'), child: const Text('Remove from Project')),
    SimpleDialogOption(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
  ]);
}
