import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
            child: ValueListenableBuilder<String>(
              valueListenable: profileName,
              builder: (context, name, _) => ValueListenableBuilder<String>(
                valueListenable: profileEmail,
                builder: (context, email, _) => Column(
                  children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: shMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                  ],
                ),
              ),
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
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (i != items.length - 1) const SizedBox(height: 10),
        ],
      ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [shSurface2, shSurface]),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: shBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: shSurface2,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: shBorder),
                ),
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
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
        initial: profileEmail.value,
        onSave: (value) => profileEmail.value = value,
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
                    onTap: _showPhotoOptions,
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
                ValueListenableBuilder<String>(
                  valueListenable: profileName,
                  builder: (context, name, _) => ValueListenableBuilder<String>(
                    valueListenable: profileEmail,
                    builder: (context, email, _) => _AccountSection(
                      title: 'Personal',
                      rows: [
                        _AccountRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Name',
                          value: name,
                          editable: true,
                          onTap: () => _editValue(
                            title: 'Name',
                            initial: name,
                            onSave: (value) => profileName.value = value,
                          ),
                        ),
                        _AccountRow(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          value: email,
                          editable: true,
                          onTap: () => _editEmail(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AccountSection(
                  title: 'Identifiers',
                  rows: const [
                    _AccountRow(
                      icon: Icons.badge_outlined,
                      label: 'Account ID',
                      value: 'xxxxx',
                    ),
                    _AccountRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'SH ID',
                      value: 'xxxxx',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AccountSection(
                  title: 'Account',
                  rows: const [
                    _AccountRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Account created',
                      value: 'mm-dd-yyyy',
                    ),
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
        Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.label,
    required this.value,
    this.editable = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: editable ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          decoration: BoxDecoration(
            color: shSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: shBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: shSurface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: shBorder),
                ),
                child: Icon(icon, size: 21, color: Colors.white),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: shMuted),
                    ),
                  ],
                ),
              ),
              if (editable)
                const Icon(Icons.chevron_right_rounded, size: 21, color: shMuted),
            ],
          ),
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
    if (title == 'Notifications') return const NotificationsView();
    if (title == 'Security') return const SecurityView();
    if (title == 'Integrations') return const IntegrationsView();
    if (title == 'Data & Privacy') return const DataPrivacyView();

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

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});
  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool message = true, activity = true, updates = true, sound = true, vibration = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(
        title: 'Notifications',
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
        children: [
          _NotificationSection(title: 'General', children: [
            _NotificationRow(icon: Icons.chat_bubble_outline, label: 'Message notifications', description: 'Alerts when new messages arrive', value: message, onChanged: (v) => setState(() => message = v)),
            _NotificationRow(icon: Icons.notifications_none_rounded, label: 'Activity notifications', description: 'Updates about activity in SH', value: activity, onChanged: (v) => setState(() => activity = v)),
          ]),
          const SizedBox(height: 16),
          _NotificationSection(title: 'Updates', children: [
            _NotificationRow(icon: Icons.auto_awesome_outlined, label: 'Second Head updates', description: 'Product and system updates', value: updates, onChanged: (v) => setState(() => updates = v)),
          ]),
          const SizedBox(height: 16),
          _NotificationSection(title: 'Notification behavior', children: [
            _NotificationRow(icon: Icons.volume_up_outlined, label: 'Sound', description: 'Play notification sounds', value: sound, onChanged: (v) => setState(() => sound = v)),
            _NotificationRow(icon: Icons.vibration_rounded, label: 'Vibration', description: 'Vibrate for notifications', value: vibration, onChanged: (v) => setState(() => vibration = v)),
          ]),
        ],
      )),
    ]),
  );
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600),
        ),
      ),
      Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    ],
  );
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: shSurface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: shBorder),
            ),
            child: Icon(icon, size: 21, color: value ? Colors.white : shMuted),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(fontSize: 11.5, color: shMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: 'Security',
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
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Authentication',
                    style: TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600),
                  ),
                ),
                _SecurityRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Sign-in method',
                  value: 'Email',
                ),
                const SizedBox(height: 10),
                _SecurityRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Password',
                  value: 'Not configured yet',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const PasswordView()),
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

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: shBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: shSurface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: shBorder),
              ),
              child: Icon(icon, size: 21, color: onTap == null ? shMuted : Colors.white),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontSize: 11.5, color: shMuted)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, size: 21, color: shMuted),
          ],
        ),
      ),
    ),
  );
}

class PasswordView extends StatefulWidget {
  const PasswordView({super.key});

  @override
  State<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _confirm() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password configuration is not connected yet.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shBackground,
      body: SafeArea(
        child: Column(
          children: [
            ShTopBar(
              title: 'Password',
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    decoration: BoxDecoration(
                      color: shSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: shBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 28,
                          color: shCyan,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Set your password',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Create a password for your email sign-in.',
                          style: TextStyle(
                            fontSize: 13,
                            color: shMuted,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _confirm,
                          child: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'Password changes are currently frontend-only.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: shMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IntegrationsView extends StatefulWidget {

  const IntegrationsView({super.key});

  @override State<IntegrationsView> createState() => _IntegrationsViewState();

}

class _IntegrationsViewState extends State<IntegrationsView> {

  final List<_AuthRequest> pending = [

    _AuthRequest('Inheritance', 'SH-A', 'SH-B', true),

    _AuthRequest('Succession', 'SH-C', 'SH-D', false),

    _AuthRequest('Legacy', 'SH-E', 'SH-F', true),

  ];

  final List<_AuthRequest> authorized = [_AuthRequest('Inheritance', 'SH-X', 'SH-Y', true)];

  void _accept(_AuthRequest r) => setState(() { pending.remove(r); authorized.add(r); });

  void _reject(_AuthRequest r) => setState(() => pending.remove(r));

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: shBackground, body: Column(children: [

    ShTopBar(title: 'Integrations', leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded))),

    Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(14,12,14,30), children: [

      _IntegrationHeader(title: 'Pending', subtitle: pending.isEmpty ? 'Nothing needs your attention' : pending.length.toString() + ' authorization requests', icon: Icons.pending_actions_rounded),

      const SizedBox(height:10),

      if (pending.isEmpty) _IntegrationEmpty(icon: Icons.check_circle_outline_rounded, text: 'All caught up')

      else ...pending.map((r) => Padding(padding: const EdgeInsets.only(bottom:10), child: _PendingAuthCard(request:r, onAccept:() => _accept(r), onReject:() => _reject(r)))),

      const SizedBox(height:14),

      _IntegrationHeader(title:'Authorized', subtitle:authorized.length.toString() + ' active', icon:Icons.verified_user_outlined),

      const SizedBox(height:10),

      if (authorized.isEmpty) _IntegrationEmpty(icon:Icons.link_off_rounded, text:'No active authorizations')

      else ...authorized.map((r) => Padding(padding: const EdgeInsets.only(bottom:10), child:_AuthorizedCard(request:r, onRevoke:() => setState(() => authorized.remove(r))))),

    ])),

  ]));

}

class _AuthRequest { _AuthRequest(this.type,this.from,this.to,this.incoming); final String type,from,to; final bool incoming; }

class _IntegrationHeader extends StatelessWidget {

  const _IntegrationHeader({required this.title,required this.subtitle,required this.icon}); final String title,subtitle; final IconData icon;

  @override Widget build(BuildContext context) => Row(children:[Container(width:38,height:38,decoration:BoxDecoration(color:shSurface2,borderRadius:BorderRadius.circular(12),border:Border.all(color:shBorder)),child:Icon(icon,size:20,color:Colors.white)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)),const SizedBox(height:2),Text(subtitle,style:const TextStyle(fontSize:11,color:shMuted))]))]);

}

class _PendingAuthCard extends StatelessWidget {

  const _PendingAuthCard({required this.request,required this.onAccept,required this.onReject}); final _AuthRequest request; final VoidCallback onAccept,onReject;

  @override Widget build(BuildContext context) => Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:LinearGradient(colors:[shSurface2,shSurface]),borderRadius:BorderRadius.circular(22),border:Border.all(color:shBorder)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[

    Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),decoration:BoxDecoration(color:shPurple.withValues(alpha: .14),borderRadius:BorderRadius.circular(9)),child:Text(request.type,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700))),const Spacer(),Text(request.incoming?'Needs your approval':'Waiting for approval',style:TextStyle(fontSize:10,color:request.incoming?shCyan:shMuted,fontWeight:FontWeight.w600))]),

    const SizedBox(height:14),Row(children:[_PartyPill(label:request.from),const Padding(padding:EdgeInsets.symmetric(horizontal:8),child:Icon(Icons.arrow_forward_rounded,size:16,color:shMuted)),_PartyPill(label:request.to)]),

    if(request.incoming)...[const SizedBox(height:15),Row(children:[Expanded(child:_AuthAction(label:'Reject',icon:Icons.close_rounded,onTap:onReject)),const SizedBox(width:8),Expanded(child:_AuthAction(label:'Accept',icon:Icons.check_rounded,onTap:onAccept,primary:true))])]

  ]));

}

class _AuthorizedCard extends StatelessWidget { const _AuthorizedCard({required this.request,required this.onRevoke}); final _AuthRequest request; final VoidCallback onRevoke;

  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:shSurface,borderRadius:BorderRadius.circular(20),border:Border.all(color:shBorder)),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:shSurface2,borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.verified_rounded,size:21,color:shCyan)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(request.type,style:const TextStyle(fontSize:14,fontWeight:FontWeight.w700)),const SizedBox(height:3),Text(request.from+' → '+request.to,style:const TextStyle(fontSize:12,color:shMuted))])),IconButton(tooltip:'Revoke',onPressed:onRevoke,icon:const Icon(Icons.link_off_rounded,size:20))]));

}

class _PartyPill extends StatelessWidget { const _PartyPill({required this.label}); final String label; @override Widget build(BuildContext context)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(horizontal:11,vertical:10),decoration:BoxDecoration(color:shSurface,borderRadius:BorderRadius.circular(13),border:Border.all(color:shBorder)),child:Row(children:[const Icon(Icons.person_outline_rounded,size:16,color:shMuted),const SizedBox(width:7),Expanded(child:Text(label,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w600)))]))); }

class _AuthAction extends StatelessWidget { const _AuthAction({required this.label,required this.icon,required this.onTap,this.primary=false}); final String label; final IconData icon; final VoidCallback onTap; final bool primary; @override Widget build(BuildContext context)=>InkWell(borderRadius:BorderRadius.circular(13),onTap:onTap,child:Container(height:44,decoration:BoxDecoration(color:primary?shSurface2:shSurface,borderRadius:BorderRadius.circular(13),border:Border.all(color:primary?shPurple:shBorder)),child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,size:17),const SizedBox(width:7),Text(label,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))]))); }

class _IntegrationEmpty extends StatelessWidget { const _IntegrationEmpty({required this.icon,required this.text}); final IconData icon; final String text; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:28),decoration:BoxDecoration(color:shSurface,borderRadius:BorderRadius.circular(20),border:Border.all(color:shBorder)),child:Column(children:[Icon(icon,size:28,color:shMuted),const SizedBox(height:9),Text(text,style:const TextStyle(fontSize:12,color:shMuted))])); }


class DataPrivacyView extends StatelessWidget {

  const DataPrivacyView({super.key});

  @override Widget build(BuildContext context) => Scaffold(backgroundColor:shBackground,body:Column(children:[

    ShTopBar(title:'Data & Privacy',leading:IconButton(tooltip:'Back',onPressed:()=>Navigator.of(context).pop(),icon:const Icon(Icons.arrow_back_rounded))),

    Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(14,14,14,32),children:[

      const _DPSectionLabel('YOUR DATA'),const SizedBox(height:8),

      _DPCard(icon:Icons.folder_copy_outlined,title:'Data & Files',subtitle:'Manage local images, files, audio and video',onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const _DataFilesView()))),

      const SizedBox(height:10),

      _DPCard(icon:Icons.file_download_outlined,title:'Export Data',subtitle:'Get a copy of your SH data',onTap:()=>_showDPPlaceholder(context,'Export Data')),

      const SizedBox(height:10),

      _DPCard(icon:Icons.delete_outline_rounded,title:'Delete Data',subtitle:'Remove selected SH data',destructive:true,onTap:()=>_showDPPlaceholder(context,'Delete Data')),

      const SizedBox(height:22),const _DPSectionLabel('PRIVACY'),const SizedBox(height:8),

      _DPCard(icon:Icons.privacy_tip_outlined,title:'Privacy Information',subtitle:'How your data is handled',onTap:()=>_showDPPlaceholder(context,'Privacy Information')),

    ])),

  ]));

  void _showDPPlaceholder(BuildContext context,String title){showModalBottomSheet(context:context,backgroundColor:shSurface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(26))),builder:(_)=>SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,8,20,28),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w700)),const SizedBox(height:8),const Text('This area is ready for its full SH workflow.',style:TextStyle(fontSize:13,color:shMuted))]))));}

}

class _DataFilesView extends StatefulWidget { const _DataFilesView(); @override State<_DataFilesView> createState()=>_DataFilesViewState(); }

class _DataFilesViewState extends State<_DataFilesView> {

  bool _loading=true,_clearing=false; int _total=0,_images=0,_videos=0,_audio=0,_files=0,_uploaded=0,_generated=0;

  @override void initState(){super.initState();_refresh();}

  Future<Directory> _root() async { final base=await getApplicationSupportDirectory(); final dir=Directory(base.path+'/second_head/attachments'); await Directory(dir.path+'/uploaded').create(recursive:true); await Directory(dir.path+'/generated').create(recursive:true); return dir; }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final root = await _root();
    final files = <File>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File) files.add(entity);
    }
    int image = 0, video = 0, audio = 0, other = 0;
    int bytes = 0, uploaded = 0, generated = 0;
    for (final file in files) {
      final name = file.path.toLowerCase();
      final stat = await file.stat();
      bytes += stat.size;
      if (name.contains('/uploaded/')) uploaded++;
      if (name.contains('/generated/')) generated++;
      if (RegExp(r'\.(jpg|jpeg|png|gif|webp|heic)$').hasMatch(name)) image++;
      else if (RegExp(r'\.(mp4|mov|m4v|webm|avi)$').hasMatch(name)) video++;
      else if (RegExp(r'\.(mp3|m4a|wav|aac|ogg|opus)$').hasMatch(name)) audio++;
      else other++;
    }
    if (!mounted) return;
    setState(() {
      _total = bytes; _images = image; _videos = video; _audio = audio; _files = other;
      _uploaded = uploaded; _generated = generated; _loading = false;
    });
  }

  Future<void> _clearLocalFiles() async { final root=await _root();setState(()=>_clearing=true);await for(final e in root.list(recursive:true,followLinks:false)){if(e is File)await e.delete();}if(!mounted)return;setState(()=>_clearing=false);await _refresh(); }

  String _size(int b){if(b<1024)return '$b B';if(b<1024*1024)return '${(b/1024).toStringAsFixed(1)} KB';if(b<1024*1024*1024)return '${(b/(1024*1024)).toStringAsFixed(1)} MB';return '${(b/(1024*1024*1024)).toStringAsFixed(2)} GB';}

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(title: 'Data & Files', leading: IconButton(
        tooltip: 'Back', onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      )),
      Expanded(child: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [shSurface2, shSurface]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: shBorder),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('LOCAL STORAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: shMuted)),
                    const SizedBox(height: 8),
                    Text(_size(_total), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                    Text('${_uploaded + _generated} attachments on this device', style: const TextStyle(fontSize: 12, color: shMuted)),
                  ]),
                ),
                const SizedBox(height: 18), const _DPSectionLabel('BY TYPE'), const SizedBox(height: 8),
                _DPFileStat(icon: Icons.image_outlined, label: 'Images', count: _images),
                _DPFileStat(icon: Icons.videocam_outlined, label: 'Videos', count: _videos),
                _DPFileStat(icon: Icons.graphic_eq_rounded, label: 'Audio', count: _audio),
                _DPFileStat(icon: Icons.insert_drive_file_outlined, label: 'Files', count: _files),
                const SizedBox(height: 18), const _DPSectionLabel('SOURCE'), const SizedBox(height: 8),
                _DPFileStat(icon: Icons.file_upload_outlined, label: 'Uploaded', count: _uploaded),
                _DPFileStat(icon: Icons.auto_awesome_outlined, label: 'Generated by SH', count: _generated),
                const SizedBox(height: 18),
                Material(color: Colors.transparent, child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _clearing ? null : _clearLocalFiles,
                  child: Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: shBorder)),
                    child: Row(children: [
                      Container(width: 42, height: 42, decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(13)),
                        child: _clearing ? const Padding(padding: EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cleaning_services_outlined, size: 20, color: Colors.redAccent)),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Clear Local Files', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                        SizedBox(height: 3), Text('Removes attachment copies from this device only', style: TextStyle(fontSize: 11, color: shMuted)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
                    ]),
                  ),
                )),
              ],
            ),
          )),
    ]),
  );

}

class _DPFileStat extends StatelessWidget { const _DPFileStat({required this.icon,required this.label,required this.count}); final IconData icon; final String label; final int count; @override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),decoration:BoxDecoration(color:shSurface,borderRadius:BorderRadius.circular(16),border:Border.all(color:shBorder)),child:Row(children:[Icon(icon,size:19,color:shMuted),const SizedBox(width:11),Expanded(child:Text(label,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w600))),Text('$count',style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700,color:shMuted))])); }

class _DPSectionLabel extends StatelessWidget {
  const _DPSectionLabel(this.text);
  final String text;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: shMuted)),
  );
}

class _DPCard extends StatelessWidget {
  const _DPCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.destructive = false});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool destructive;
  @override Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [shSurface2, shSurface]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: shBorder),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: destructive ? shSurface : shSurface2,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: shBorder),
            ),
            child: Icon(icon, size: 22, color: destructive ? Colors.redAccent : Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: destructive ? Colors.redAccent : Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
          ])),
          const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
        ]),
      ),
    ),
  );
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