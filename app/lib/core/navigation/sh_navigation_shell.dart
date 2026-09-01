import 'package:flutter/material.dart';

import '../theme/sh_theme.dart';

class ShNavigationShell extends StatefulWidget {
  const ShNavigationShell({
    super.key,
    required this.pages,
    required this.drawerBuilder,
  });

  final List<Widget> pages;
  final Widget Function(BuildContext context, ValueChanged<int> onSelectPage) drawerBuilder;

  @override
  State<ShNavigationShell> createState() => _ShNavigationShellState();
}

class _ShNavigationShellState extends State<ShNavigationShell> {
  int index = 0;

  void _selectPage(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && index > 0) _selectPage(index - 1);
      },
      child: Scaffold(
        drawer: widget.drawerBuilder(context, _selectPage),
        drawerEdgeDragWidth: 96,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(index),
              child: widget.pages[index],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _selectPage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, size: 22),
              selectedIcon: Icon(Icons.chat_bubble_outline, size: 22),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_repeat_outlined, size: 22),
              selectedIcon: Icon(Icons.event_repeat_outlined, size: 22),
              label: 'Journey',
            ),
            NavigationDestination(
              icon: Icon(Icons.hexagon_outlined, size: 22),
              selectedIcon: Icon(Icons.hexagon_outlined, size: 22),
              label: 'Lifecycle',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 22),
              selectedIcon: Icon(Icons.person_outline, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class ShTopBar extends StatelessWidget {
  const ShTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.onSearch,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          leading ??
              IconButton(
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, size: 21),
              ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          if (onSearch != null)
            IconButton(
              tooltip: 'Search',
              onPressed: onSearch,
              icon: const Icon(Icons.search_outlined, size: 21),
            ),
          ...actions,
        ],
      ),
    );
  }
}


class ShSearchResult<T> {
  const ShSearchResult({
    required this.value,
    required this.title,
    this.subtitle,
  });

  final T value;
  final String title;
  final String? subtitle;
}

Future<T?> showShInternalSearch<T>({
  required BuildContext context,
  required String hintText,
  required List<ShSearchResult<T>> Function(String query) search,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: shSurface,
    showDragHandle: true,
    builder: (sheet) => _ShInternalSearchSheet<T>(
      hintText: hintText,
      search: search,
    ),
  );
}

class _ShInternalSearchSheet<T> extends StatefulWidget {
  const _ShInternalSearchSheet({
    required this.hintText,
    required this.search,
  });

  final String hintText;
  final List<ShSearchResult<T>> Function(String query) search;

  @override
  State<_ShInternalSearchSheet<T>> createState() =>
      _ShInternalSearchSheetState<T>();
}

class _ShInternalSearchSheetState<T>
    extends State<_ShInternalSearchSheet<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() => query = _controller.text);

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.search(query.trim().toLowerCase());
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 6, 18, bottom + 10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_outlined),
                hintText: widget.hintText,
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: _controller.clear,
                        icon: const Icon(Icons.close_outlined),
                      ),
              ),
            ),
            if (results.isNotEmpty) ...[
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: shBorder),
                  itemBuilder: (_, index) {
                    final result = results[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(result.title),
                      subtitle: result.subtitle == null
                          ? null
                          : Text(
                              result.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: const Icon(Icons.chevron_right_outlined),
                      onTap: () => Navigator.pop(sheet, result.value),
                    );
                  },
                ),
              ),
            ] else if (query.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'No results found.',
                  style: TextStyle(color: shMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
