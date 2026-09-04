import 'package:flutter/material.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import '../../../core/theme/sh_theme.dart';

class AppearanceView extends StatefulWidget {
  const AppearanceView({super.key});

  @override
  State<AppearanceView> createState() => _AppearanceViewState();
}

class _AppearanceViewState extends State<AppearanceView> {
  ThemeMode get _themeMode => shAppearance.themeMode;
  String get _language => shAppearance.languageCode == 'id' ? 'Indonesia' : 'English';

  @override
  void initState() {
    super.initState();
    shAppearance.addListener(_appearanceChanged);
  }

  @override
  void dispose() {
    shAppearance.removeListener(_appearanceChanged);
    super.dispose();
  }

  void _appearanceChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          ShTopBar(
            title: 'Appearance',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('Theme', style: TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600)),
                ),
                Row(
                  children: [
                    _ThemeCard(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark',
                      selected: _themeMode == ThemeMode.dark,
                      onTap: () => shAppearance.setThemeMode(ThemeMode.dark),
                    ),
                    const SizedBox(width: 8),
                    _ThemeCard(
                      icon: Icons.light_mode_outlined,
                      label: 'Light',
                      selected: _themeMode == ThemeMode.light,
                      onTap: () => shAppearance.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 8),
                    _ThemeCard(
                      icon: Icons.brightness_auto_outlined,
                      label: 'System',
                      selected: _themeMode == ThemeMode.system,
                      onTap: () => shAppearance.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('Language', style: TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600)),
                ),
                _LanguageCard(
                  code: 'EN',
                  label: 'English',
                  selected: _language == 'English',
                  onTap: () => shAppearance.setLanguage('en'),
                ),
                const SizedBox(height: 8),
                _LanguageCard(
                  code: 'ID',
                  label: 'Indonesia',
                  selected: _language == 'Indonesia',
                  onTap: () => shAppearance.setLanguage('id'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 128,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? shPurple : shBorder, width: selected ? 1.7 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
              if (selected) ...[
                const SizedBox(height: 6),
                const Icon(Icons.check_circle, size: 15, color: shCyan),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.code, required this.label, required this.selected, required this.onTap});
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? shPurple : shBorder, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Text(code, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: shCyan)),
            const SizedBox(width: 18),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: selected
                  ? const Icon(Icons.check_circle, key: ValueKey('selected'), size: 20, color: shCyan)
                  : const SizedBox(key: ValueKey('unselected'), width: 20),
            ),
          ],
        ),
      ),
    );
  }
}
