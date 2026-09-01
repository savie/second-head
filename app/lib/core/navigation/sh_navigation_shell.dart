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
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -250 && index < widget.pages.length - 1) {
              _selectPage(index + 1);
            } else if (velocity > 250 && index > 0) {
              _selectPage(index - 1);
            }
          },
          child: widget.pages[index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, size: 19),
            selectedIcon: Icon(Icons.chat_bubble, size: 19),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.hexagon_outlined, size: 19),
            selectedIcon: Icon(Icons.hexagon, size: 19),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined, size: 19),
            selectedIcon: Icon(Icons.event_note, size: 19),
            label: 'Lifecycle',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 19),
            selectedIcon: Icon(Icons.person, size: 19),
            label: 'Profile',
          ),
        ],
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
