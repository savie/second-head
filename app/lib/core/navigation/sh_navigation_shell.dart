import 'package:flutter/material.dart';

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
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

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
          ...actions,
        ],
      ),
    );
  }
}
