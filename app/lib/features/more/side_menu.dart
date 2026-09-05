import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/theme/sh_theme.dart';
import '../auth/auth_screens.dart';
import '../conversation/conversation_runtime_bridge.dart';
import '../conversation/conversation_service.dart';
import 'about/about_view.dart';
import 'help_support/help_support_view.dart';
import 'more_widgets.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key, required this.onSelectPage});
  final ValueChanged<int> onSelectPage;
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final ConversationRuntimeBridge _runtime = const ConversationRuntimeBridge();
  bool _projectExpanded = true;
  bool _conversationExpanded = true;
  bool _loading = true;
  List<ProjectSummary> _projects = const [];
  List<ConversationSummary> _conversations = const [];

  @override
  void initState() {
    super.initState();
    _loadSidebar();
  }

  Future<void> _loadSidebar() async {
    try {
      final results = await Future.wait([
        _runtime.listProjects(),
        _runtime.listConversations(),
      ]);
      if (!mounted) return;
      setState(() {
        _projects = results[0] as List<ProjectSummary>;
        _conversations = results[1] as List<ConversationSummary>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _closeDrawer() => Navigator.of(context).pop();

  void _openPage(int index) {
    _closeDrawer();
    widget.onSelectPage(index);
  }

  Future<void> _startNewConversation({String? projectId}) async {
    try {
      final id = await _runtime.createConversation(projectId: projectId, title: 'New Conversation');
      await _runtime.selectConversation(id);
      await _loadSidebar();
      if (!mounted) return;
      _closeDrawer();
      widget.onSelectPage(0);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to create conversation')));
    }
  }

  Future<void> _openConversation(ConversationSummary item) async {
    try {
      await _runtime.selectConversation(item.conversationId);
      if (!mounted) return;
      _closeDrawer();
      widget.onSelectPage(0);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open conversation')));
    }
  }

  Future<void> _createProject() async {
    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(18, 8, 18, MediaQuery.of(sheet).viewInsets.bottom + 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('New Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: controller, autofocus: true, textInputAction: TextInputAction.done, decoration: const InputDecoration(hintText: 'Project name')),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheet), child: const Text('Cancel'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheet, controller.text.trim()), child: const Text('Save'))),
          ]),
        ]),
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.isEmpty) return;
    try {
      await _runtime.createProject(name);
      await _loadSidebar();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to create project')));
    }
  }

  Future<void> _rename(BuildContext context, ConversationSummary item) async {
    final controller = TextEditingController(text: item.title);
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(18, 8, 18, MediaQuery.of(sheet).viewInsets.bottom + 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Rename conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: controller, autofocus: true),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheet), child: const Text('Cancel'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(sheet, controller.text.trim()), child: const Text('Save'))),
          ]),
        ]),
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.isEmpty) return;
    try {
      await _runtime.rename(conversationId: item.conversationId, title: name);
      await _loadSidebar();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to rename conversation')));
    }
  }

  Widget _sectionAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 36, right: 10, bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: shBorder)),
          child: Row(children: [Icon(icon, size: 18, color: shCyan), const SizedBox(width: 9), Text(label, style: const TextStyle(fontSize: 11, color: shCyan))]),
        ),
      ),
    );
  }

  Widget _projectsEntries() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10, bottom: 6),
      child: Column(children: [
        _sectionAction(icon: Icons.add, label: 'New Project', onTap: _createProject),
        const Padding(padding: EdgeInsets.only(left: 38, top: 3, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Text('Recent Projects', style: TextStyle(fontSize: 9, color: shMuted)))),
        for (final project in _projects)
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
            contentPadding: const EdgeInsets.only(left: 36, right: 4),
            leading: const Icon(Icons.folder_outlined, size: 16, color: shMuted),
            title: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
            trailing: Text('${_conversations.where((c) => c.projectId == project.projectId).length}', style: const TextStyle(fontSize: 9, color: shMuted)),
            onTap: () => setState(() => _conversationExpanded = true),
          ),
        if (!_loading && _projects.isEmpty)
          const Padding(padding: EdgeInsets.fromLTRB(38, 6, 8, 8), child: Align(alignment: Alignment.centerLeft, child: Text('No projects yet', style: TextStyle(fontSize: 10, color: shMuted))),
      ]),
    );
  }

  Widget _conversationEntries() {
    return ValueListenableBuilder<String?>(
      valueListenable: ConversationService.activeConversationId,
      builder: (context, activeId, _) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 6),
        child: Column(children: [
          _sectionAction(icon: Icons.add, label: 'New Conversation', onTap: () => _startNewConversation()),
          const Padding(padding: EdgeInsets.only(left: 38, top: 3, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Text('Recent Conversations', style: TextStyle(fontSize: 9, color: shMuted)))),
          for (final item in _conversations)
            GestureDetector(
              onLongPress: () => _rename(context, item),
              child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                contentPadding: const EdgeInsets.only(left: 36, right: 4),
                leading: Icon(Icons.chat_bubble_outline, size: 16, color: activeId == item.conversationId ? shCyan : shMuted),
                title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: activeId == item.conversationId ? shCyan : null)),
                onTap: () => _openConversation(item),
              ),
            ),
          if (!_loading && _conversations.isEmpty)
            const Padding(padding: EdgeInsets.fromLTRB(38, 6, 8, 8), child: Align(alignment: Alignment.centerLeft, child: Text('No conversations yet', style: TextStyle(fontSize: 10, color: shMuted))),
        ]),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthSession.service.signOut();
    } finally {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }
  }

  Widget _primaryPanel(BuildContext context) {
    return SizedBox(
      width: 292,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              const ShProfileMark(size: 52),
              const SizedBox(width: 10),
              Expanded(child: ValueListenableBuilder<String>(valueListenable: profileName, builder: (context, name, _) => ValueListenableBuilder<String>(valueListenable: profileEmail, builder: (context, email, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), Text(email, style: const TextStyle(fontSize: 9, color: shMuted))]))),
            ]),
          ),
          const Divider(color: shBorder),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: [
              MenuTile(icon: Icons.folder_outlined, label: 'Project', onTap: () => setState(() => _projectExpanded = !_projectExpanded)),
              if (_projectExpanded) _projectsEntries(),
              MenuTile(icon: Icons.chat_bubble_outline, label: 'Conversation', onTap: () => setState(() => _conversationExpanded = !_conversationExpanded)),
              if (_conversationExpanded) _conversationEntries(),
              MenuTile(customIcon: const ShSectionNavIcon.journey(), label: 'Journey', onTap: () => _openPage(1)),
              MenuTile(customIcon: const ShSectionNavIcon.lifecycle(), label: 'Lifecycle', onTap: () => _openPage(2)),
              MenuTile(icon: Icons.person_outline, label: 'Profile', onTap: () => _openPage(3)),
              MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () { _closeDrawer(); Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HelpSupportView())); }),
              MenuTile(icon: Icons.info_outline, label: 'About', onTap: () { _closeDrawer(); Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AboutView())); }),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 8), child: Align(alignment: Alignment.centerLeft, child: MenuTile(icon: Icons.logout_outlined, label: 'Log Out', onTap: _logout, danger: true)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Drawer(backgroundColor: shBackground, width: 292, child: _primaryPanel(context));
}
