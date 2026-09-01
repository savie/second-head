import 'dart:math' as math;
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
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: GestureDetector(
              key: ValueKey(index),
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
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _selectPage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, size: 22),
              selectedIcon: Icon(Icons.chat_bubble, size: 22),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.hexagon_outlined, size: 22),
              selectedIcon: Icon(Icons.hexagon, size: 22),
              label: 'Journey',
            ),
            NavigationDestination(
              icon: _LifecycleNavGlyph(),
              selectedIcon: _LifecycleNavGlyph(selected: true),
              label: 'Lifecycle',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 22),
              selectedIcon: Icon(Icons.person, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _LifecycleNavGlyph extends StatelessWidget {
  const _LifecycleNavGlyph({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(25, 25),
      painter: _LifecycleNavPainter(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _LifecycleNavPainter extends CustomPainter {
  _LifecycleNavPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .38;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final hex = Path();
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + (i * math.pi / 3);
      final p = Offset(
        center.dx + radius * 1.05 * math.cos(a),
        center.dy + radius * 1.05 * math.sin(a),
      );
      if (i == 0) {
        hex.moveTo(p.dx, p.dy);
      } else {
        hex.lineTo(p.dx, p.dy);
      }
    }
    hex.close();
    canvas.drawPath(hex, paint);
    canvas.drawCircle(center, radius * .32, paint);
    canvas.drawCircle(center, radius * .12, paint);
  }

  @override
  bool shouldRepaint(covariant _LifecycleNavPainter oldDelegate) =>
      oldDelegate.color != color;
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
