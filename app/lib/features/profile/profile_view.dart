import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/navigation/sh_navigation_shell.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 900,
    );
    if (file == null) return;
    profilePhoto.value = await file.readAsBytes();
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfilePhotoAction(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              _ProfilePhotoAction(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              _ProfilePhotoAction(
                icon: Icons.delete_outline,
                label: 'Remove',
                onTap: profilePhoto.value == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        profilePhoto.value = null;
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSection(BuildContext context, String title, String subtitle) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => title == 'Account' ? const AccountView() : ProfileSectionView(title: title, subtitle: subtitle),
      ),
    );
  }

  Future<void> _search(BuildContext context) async {
    const settings = [
      _SettingItem(Icons.person_outline, 'Account', 'Manage your personal information', onTap: null),
      _SettingItem(Icons.palette_outlined, 'Appearance', 'Choose theme and language'),
      _SettingItem(Icons.notifications_none, 'Notifications', 'Manage your notification preferences'),
      _SettingItem(Icons.lock_outline, 'Security', 'Password and security settings'),
      _SettingItem(Icons.hub_outlined, 'Integrations', 'Manage connected services'),
      _SettingItem(Icons.shield_outlined, 'Data & Privacy', 'Manage your data and privacy'),
    ];
    final result = await showShInternalSearch<_SettingItem>(
      context: context,
      hintText: 'Search Profile',
      search: (query) => [
        for (final item in settings)
          if (query.isEmpty ||
              '${item.title} ${item.subtitle}'.toLowerCase().contains(query))
            ShSearchResult<_SettingItem>(
              value: item,
              title: item.title,
              subtitle: item.subtitle,
            ),
      ],
    );
    if (!mounted || result == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (_) => ListTile(
        leading: Icon(result.icon),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShTopBar(
          title: 'Profile',
          onSearch: () => _search(context),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 28),
            children: [
              ValueListenableBuilder<Uint8List?>(
                valueListenable: profilePhoto,
                builder: (context, photo, _) => _ProfileHero(
                  photo: photo,
                  onEdit: _showPhotoOptions,
                ),
              ),
              const SizedBox(height: 18),
              _SettingsGroup(
                items: [
                  _SettingItem(
                    Icons.person_outline,
                    'Account',
                    'Manage your personal information',
                    onTap: () => _openSection(context, 'Account', 'Manage your personal information'),
                  ),
                  _SettingItem(
                    Icons.palette_outlined,
                    'Appearance',
                    'Choose theme and language',
                    onTap: () => _openSection(context, 'Appearance', 'Choose theme and language'),
                  ),
                  _SettingItem(
                    Icons.notifications_none,
                    'Notifications',
                    'Manage your notification preferences',
                    onTap: () => _openSection(context, 'Notifications', 'Manage your notification preferences'),
                  ),
                  _SettingItem(
                    Icons.lock_outline,
                    'Security',
                    'Password and security settings',
                    onTap: () => _openSection(context, 'Security', 'Password and security settings'),
                  ),
                  _SettingItem(
                    Icons.hub_outlined,
                    'Integrations',
                    'Manage connected services',
                    onTap: () => _openSection(context, 'Integrations', 'Manage connected services'),
                  ),
                  _SettingItem(
                    Icons.shield_outlined,
                    'Data & Privacy',
                    'Manage your data and privacy',
                    onTap: () => _openSection(context, 'Data & Privacy', 'Manage your data and privacy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.photo,
    required this.onEdit,
  });

  final Uint8List? photo;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: shBorder, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 112,
              child: ClipPath(
                clipper: _ProfileBannerClipper(),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [shPurple, shElectric],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shBackground,
                  border: Border.all(
                    color: shBackground.withValues(alpha: .9),
                    width: 4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: onEdit,
                  child: ClipOval(
                    child: photo != null
                      ? Image.memory(
                          photo!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        )
                      : Image.asset(
                          'assets/brand/unity.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,

            child: Column(
              children: [
                Text(
                  'Savie',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'savie@secondhead.app',
                  style: TextStyle(
                    fontSize: 12,
                    color: shMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * .64);
    path.cubicTo(
      size.width * .82,
      size.height * .88,
      size.width * .64,
      size.height * .98,
      size.width * .47,
      size.height * .72,
    );
    path.cubicTo(
      size.width * .29,
      size.height * .46,
      size.width * .13,
      size.height * .78,
      0,
      size.height * .58,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ProfilePhotoAction extends StatelessWidget {
  const _ProfilePhotoAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [shPurple, shElectric],
                ),
              ),
              child: Icon(icon),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shBorder, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1)
              const Divider(height: 1, color: shBorder),
          ],
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem(this.icon, this.title, this.subtitle, {this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 25, color: Colors.white70),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: shMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 26,
                color: shMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  String _name = 'Savie';
  String _email = 'savie@secondhead.app';

  Future<void> _editValue({
    required String title,
    required String initial,
    required ValueChanged<String> onSave,
  }) async {
    final controller = TextEditingController(text: initial);
    final value = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: shSurface,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          8,
          18,
          MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.pop(sheetContext, controller.text.trim()),
              decoration: InputDecoration(
                filled: true,
                fillColor: shBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: shBorder),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || value == null || value.isEmpty) return;
    onSave(value);
  }

  Future<void> _editEmail() => _editValue(
        title: 'Email',
        initial: _email,
        onSave: (value) => setState(() => _email = value),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: 'Account',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      final state = context.findAncestorStateOfType<ProfileViewState>();
                      state?._showPhotoOptions();
                    },
                    child: const ShProfileMark(size: 112),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Tap photo to change',
                    style: TextStyle(fontSize: 11, color: shMuted),
                  ),
                ),
                const SizedBox(height: 22),
                _AccountSection(
                  title: 'Personal',
                  rows: [
                    _AccountRow(
                      label: 'Name',
                      value: _name,
                      editable: true,
                      onTap: () => _editValue(
                        title: 'Name',
                        initial: _name,
                        onSave: (value) => setState(() => _name = value),
                      ),
                    ),
                    _AccountRow(
                      label: 'Email',
                      value: _email,
                      editable: true,
                      onTap: _editEmail,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AccountSection(
                  title: 'Identifiers',
                  rows: const [
                    _AccountRow(label: 'Account ID', value: 'xxxxx'),
                    _AccountRow(label: 'SH ID', value: 'xxxxx'),
                  ],
                ),
                const SizedBox(height: 14),
                _AccountSection(
                  title: 'Account',
                  rows: const [
                    _AccountRow(label: 'Account created', value: 'mm-dd-yyyy'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.rows});

  final String title;
  final List<_AccountRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: shSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: shBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1) const Divider(height: 1, color: shBorder),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.value,
    this.editable = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: editable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 14, color: shMuted)),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            if (editable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 20, color: shMuted),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileSectionView extends StatelessWidget {
  const ProfileSectionView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (title == 'Appearance') return const AppearanceView();

    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: title,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: shBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: shMuted, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: shBorder),
                  ),
                  child: const Text(
                    'Dummy page — detail and actions will be implemented in the dedicated Profile workstream.',
                    style: TextStyle(fontSize: 12, color: shMuted, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppearanceView extends StatefulWidget {
  const AppearanceView({super.key});

  @override
  State<AppearanceView> createState() => _AppearanceViewState();
}

class _AppearanceViewState extends State<AppearanceView> {
  ThemeMode get _themeMode => shAppearance.themeMode;
  String get _language => shAppearance.languageCode == 'id' ? 'Indonesia' : 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
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
            color: selected ? shSurface2 : shSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? shPurple : shBorder, width: selected ? 1.7 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: selected ? Colors.white : shMuted),
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
          color: selected ? shSurface2 : shSurface,
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
