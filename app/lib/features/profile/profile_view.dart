import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import '../../core/storage/storage_service.dart';
import '../../core/storage/recovery_snapshot_store.dart';
import '../integrations/integration_authorization_store.dart';

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
    final bytes = await file.readAsBytes();
    await StorageService.saveProfilePhoto(bytes);
    profilePhoto.value = bytes;
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
                        StorageService.removeProfilePhoto().then((_) {
                          if (mounted) setState(() => profilePhoto.value = null);
                        });
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

  @override
  State<IntegrationsView> createState() => _IntegrationsViewState();
}

class _IntegrationsViewState extends State<IntegrationsView> {
  final store = IntegrationAuthorizationStore.instance;

  String _authorizationStatusLabel(IntegrationAuthorization request) {
    switch (request.status) {
      case IntegrationAuthorizationStatus.pending:
        return request.incoming
            ? 'Needs your approval'
            : 'Waiting for approval';
      case IntegrationAuthorizationStatus.approved:
        return 'Active authorization';
      case IntegrationAuthorizationStatus.rejected:
        return 'Rejected';
      case IntegrationAuthorizationStatus.revoked:
        return 'Revoked';
    }
  }

  Color _authorizationStatusColor(IntegrationAuthorization request) {
    switch (request.status) {
      case IntegrationAuthorizationStatus.pending:
        return request.incoming ? shCyan : shMuted;
      case IntegrationAuthorizationStatus.approved:
        return shCyan;
      case IntegrationAuthorizationStatus.rejected:
      case IntegrationAuthorizationStatus.revoked:
        return shMuted;
    }
  }

  String _formatAuthorizationDate(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  Future<void> _showAuthorizationDetail(
    BuildContext context,
    IntegrationAuthorization request,
  ) async {
    final scopeRows = <MapEntry<String, String>>[
      MapEntry('Memory', 'memory_ids'),
      MapEntry('Knowledge', 'knowledge_ids'),
      MapEntry('Experience', 'experience_ids'),
      MapEntry('Journey', 'journey_event_ids'),
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shSurface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: shSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: request.status ==
                                  IntegrationAuthorizationStatus.approved
                              ? shCyan.withValues(alpha: .45)
                              : shPurple.withValues(alpha: .45),
                        ),
                      ),
                      child: Icon(
                        request.status ==
                                IntegrationAuthorizationStatus.approved
                            ? Icons.verified_rounded
                            : Icons.security_outlined,
                        color: request.status ==
                                IntegrationAuthorizationStatus.approved
                            ? shCyan
                            : shPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.type,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _authorizationStatusLabel(request),
                            style: TextStyle(
                              fontSize: 11,
                              color: _authorizationStatusColor(request),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _IntegrationDetailRow(
                  label: 'Source SH',
                  value: request.sourceShId,
                ),
                _IntegrationDetailRow(
                  label: 'Target',
                  value: request.targetAccountId,
                ),
                _IntegrationDetailRow(
                  label: 'Created',
                  value: _formatAuthorizationDate(request.createdAt),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AUTHORIZED DATA',
                  style: TextStyle(
                    fontSize: 10,
                    color: shMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 8),
                for (final row in scopeRows)
                  _IntegrationScopeRow(
                    label: row.key,
                    count: request.scope[row.value]?.length ?? 0,
                  ),
                if (request.status == IntegrationAuthorizationStatus.approved) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        store.revoke(request.id);
                      },
                      icon: const Icon(Icons.link_off_rounded, size: 18),
                      label: const Text('Revoke Authorization'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) => Scaffold(
          backgroundColor: shBackground,
          body: Column(
            children: [
              ShTopBar(
                title: 'Integrations',
                leading: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
                  children: [
                    _IntegrationOverview(
                      pendingCount: store.pending.length,
                      authorizedCount: store.authorized.length,
                    ),
                    const SizedBox(height: 18),
                    _IntegrationHeader(
                      title: 'Pending',
                      subtitle: store.pending.isEmpty
                          ? 'No authorization requests'
                          : '${store.pending.length} authorization '
                              '${store.pending.length == 1 ? 'request' : 'requests'}',
                      icon: Icons.pending_actions_rounded,
                    ),
                    const SizedBox(height: 10),
                    if (store.pending.isEmpty)
                      const _IntegrationEmpty(
                        icon: Icons.check_circle_outline_rounded,
                        text: 'All caught up',
                      )
                    else
                      ...store.pending.map(
                        (request) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PendingAuthCard(
                            request: request,
                            onTap: () => _showAuthorizationDetail(context, request),
                            onAccept: () => store.approve(request.id),
                            onReject: () => store.reject(request.id),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _IntegrationHeader(
                      title: 'Authorized',
                      subtitle: store.authorized.isEmpty
                          ? 'No active authorizations'
                          : '${store.authorized.length} active',
                      icon: Icons.verified_user_outlined,
                    ),
                    const SizedBox(height: 10),
                    if (store.authorized.isEmpty)
                      const _IntegrationEmpty(
                        icon: Icons.link_off_rounded,
                        text: 'No active authorizations',
                      )
                    else
                      ...store.authorized.map(
                        (request) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AuthorizedCard(
                            request: request,
                            onTap: () => _showAuthorizationDetail(context, request),
                            onRevoke: () => store.revoke(request.id),
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

class _IntegrationOverview extends StatelessWidget {
  const _IntegrationOverview({
    required this.pendingCount,
    required this.authorizedCount,
  });

  final int pendingCount;
  final int authorizedCount;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              shSurface2.withValues(alpha: .92),
              shSurface.withValues(alpha: .96),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: shBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: shBackground.withValues(alpha: .75),
                shape: BoxShape.circle,
                border: Border.all(color: shPurple.withValues(alpha: .38)),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: shPurple,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Authorization Hub',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pendingCount == 0
                        ? 'No pending requests'
                        : '$pendingCount pending · $authorizedCount active',
                    style: const TextStyle(
                      fontSize: 11,
                      color: shMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$authorizedCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'active',
                  style: TextStyle(fontSize: 9, color: shMuted),
                ),
              ],
            ),
          ],
        ),
      );
}

class _IntegrationHeader extends StatelessWidget {
  const _IntegrationHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: shSurface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: shBorder),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: shMuted),
                ),
              ],
            ),
          ),
        ],
      );
}

class _PendingAuthCard extends StatelessWidget {
  const _PendingAuthCard({
    required this.request,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final IntegrationAuthorization request;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final needsApproval = request.incoming;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [shSurface2.withValues(alpha: .96), shSurface],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: needsApproval
                  ? shCyan.withValues(alpha: .28)
                  : shBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IntegrationTypeBadge(
                    type: request.type,
                    pending: true,
                  ),
                  const Spacer(),
                  _IntegrationStatusPill(
                    label: needsApproval
                        ? 'Needs your approval'
                        : 'Waiting for approval',
                    accent: needsApproval ? shCyan : shMuted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _IntegrationParty(
                      label: 'Source SH',
                      value: request.sourceShId,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: shMuted,
                    ),
                  ),
                  Expanded(
                    child: _IntegrationParty(
                      label: 'Target',
                      value: request.targetAccountId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _IntegrationScopeSummary(
                text: _scopeText(request),
              ),
              if (needsApproval) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _AuthAction(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        onTap: onReject,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _AuthAction(
                        label: 'Accept',
                        icon: Icons.check_rounded,
                        onTap: onAccept,
                        primary: true,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 9,
                    color: shMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scopeText(IntegrationAuthorization request) {
    final parts = <String>[];
    void add(String key, String label) {
      final count = request.scope[key]?.length ?? 0;
      if (count > 0) parts.add('$count $label');
    }

    add('memory_ids', 'Memory');
    add('knowledge_ids', 'Knowledge');
    add('experience_ids', 'Experience');
    add('journey_event_ids', 'Journey');
    return parts.isEmpty ? 'No data scope' : parts.join(' · ');
  }
}

class _AuthorizedCard extends StatelessWidget {
  const _AuthorizedCard({
    required this.request,
    required this.onTap,
    required this.onRevoke,
  });

  final IntegrationAuthorization request;
  final VoidCallback onTap;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 10, 14),
            decoration: BoxDecoration(
              color: shSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: shCyan.withValues(alpha: .22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: shSurface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 21,
                    color: shCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.type,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const _IntegrationStatusPill(
                            label: 'Active',
                            accent: shCyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.sourceShId} → ${request.targetAccountId}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: shMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _scopeText(request),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: shMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Revoke',
                  onPressed: onRevoke,
                  icon: const Icon(Icons.link_off_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
      );

  String _scopeText(IntegrationAuthorization request) {
    final parts = <String>[];
    void add(String key, String label) {
      final count = request.scope[key]?.length ?? 0;
      if (count > 0) parts.add('$count $label');
    }

    add('memory_ids', 'Memory');
    add('knowledge_ids', 'Knowledge');
    add('experience_ids', 'Experience');
    add('journey_event_ids', 'Journey');
    return parts.isEmpty ? 'No data scope' : parts.join(' · ');
  }
}

class _IntegrationTypeBadge extends StatelessWidget {
  const _IntegrationTypeBadge({
    required this.type,
    required this.pending,
  });

  final String type;
  final bool pending;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: (pending ? shPurple : shCyan).withValues(alpha: .14),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          type,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _IntegrationStatusPill extends StatelessWidget {
  const _IntegrationStatusPill({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: accent.withValues(alpha: .25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _IntegrationEmpty extends StatelessWidget {
  const _IntegrationEmpty({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        decoration: BoxDecoration(
          color: shSurface.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: shBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: shMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 11, color: shMuted),
              ),
            ),
          ],
        ),
      );
}

class _AuthAction extends StatelessWidget {
  const _AuthAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: primary ? shSurface : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primary ? shPurple : shBorder,
                width: primary ? 1.4 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: primary ? shPurple : shMuted),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary ? shPurple : shMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _IntegrationParty extends StatelessWidget {
  const _IntegrationParty({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
        decoration: BoxDecoration(
          color: shBackground.withValues(alpha: .48),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: shBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: shMuted),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: shMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _IntegrationScopeSummary extends StatelessWidget {
  const _IntegrationScopeSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(
            Icons.data_object_rounded,
            size: 16,
            color: shMuted,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: shMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      );
}

class _IntegrationDetailRow extends StatelessWidget {
  const _IntegrationDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 84,
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: shMuted),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

class _IntegrationScopeRow extends StatelessWidget {
  const _IntegrationScopeRow({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: shMuted),
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class DataPrivacyView extends StatelessWidget {
  const DataPrivacyView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(
      children: [
        ShTopBar(
          title: 'Data & Privacy',
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
            children: [
              const _DPSectionLabel('YOUR DATA'),
              const SizedBox(height: 8),
              _DPCard(
                icon: Icons.folder_copy_outlined,
                title: 'Data & Files',
                subtitle: 'Manage local images, files, audio and video',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _DataFilesView()),
                ),
              ),
              const SizedBox(height: 10),
              _DPCard(
                icon: Icons.file_download_outlined,
                title: 'Export Data',
                subtitle: 'Get a copy of your SH data',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _ExportDataView()),
                ),
              ),
              const SizedBox(height: 10),
              _DPCard(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Data',
                subtitle: 'Remove selected SH data',
                destructive: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _DeleteDataView()),
                ),
              ),
              const SizedBox(height: 22),
              const _DPSectionLabel('PRIVACY'),
              const SizedBox(height: 8),
              _DPCard(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Information',
                subtitle: 'How your data is handled',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _PrivacyInformationView()),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ExportDataView extends StatefulWidget {
  const _ExportDataView();

  @override
  State<_ExportDataView> createState() => _ExportDataViewState();
}

class _ExportDataViewState extends State<_ExportDataView> {
  bool _loading = true;
  List<RecoverySnapshot> _snapshots = [];
  final Map<String, File> _filesById = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loading) _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final files = await StorageService.listRecoverySnapshotFiles();
    final snapshots = <RecoverySnapshot>[];
    _filesById.clear();
    for (final file in files) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          final snapshot = RecoverySnapshot.fromJson(decoded);
          snapshots.add(snapshot);
          _filesById[snapshot.id] = file;
        }
      } catch (_) {}
    }
    snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) setState(() { _snapshots = snapshots; _loading = false; });
  }

  String _date(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }

  String _summary(RecoverySnapshot snapshot) {
    final parts = <String>[];
    if (snapshot.memoryCount > 0) parts.add('${snapshot.memoryCount} Memory');
    if (snapshot.knowledgeCount > 0) parts.add('${snapshot.knowledgeCount} Knowledge');
    if (snapshot.experienceCount > 0) parts.add('${snapshot.experienceCount} Experience');
    if (snapshot.fileCount > 0) parts.add('${snapshot.fileCount} Files');
    return parts.isEmpty ? 'FULL SH snapshot' : parts.join(' · ');
  }

  Future<void> _shareSnapshot(BuildContext sheetContext, RecoverySnapshot snapshot) async {
    final file = _filesById[snapshot.id];
    if (file == null || !await file.exists()) {
      if (mounted) {
        Navigator.of(sheetContext).pop();
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snapshot file is no longer available.')));
      }
      return;
    }
    Navigator.of(sheetContext).pop();
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'SECOND HEAD Recovery Snapshot',
      text: 'SECOND HEAD Recovery Snapshot: ${snapshot.id}',
    );
  }

  void _openSnapshot(RecoverySnapshot snapshot, int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Snapshot #${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(snapshot.id, style: const TextStyle(fontSize: 11, color: shMuted)),
                const SizedBox(height: 18),
                _DataExportRow(label: 'Type', value: snapshot.type),
                _DataExportRow(label: 'Created', value: _date(snapshot.createdAt)),
                _DataExportRow(label: 'File', value: _filesById[snapshot.id]?.path.split(Platform.pathSeparator).last ?? 'Unavailable'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _shareSnapshot(sheetContext, snapshot),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share Snapshot'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _DPSubPage(
    title: 'Export Data',
    children: [
      const _DPSectionLabel('RECOVERY SNAPSHOTS'),
      const SizedBox(height: 8),
      const _DPInfoCard(
        icon: Icons.share_outlined,
        title: 'Share existing snapshots',
        description: 'Export reads Recovery snapshot files already stored locally. Sharing opens the device share sheet; no second export copy is created.',
      ),
      const SizedBox(height: 14),
      if (_loading)
        const Padding(padding: EdgeInsets.symmetric(vertical: 34), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
      else if (_snapshots.isEmpty)
        const _DPInfoCard(icon: Icons.folder_open_outlined, title: 'No recovery snapshots', description: 'Create a snapshot in Recovery first.')
      else
        for (var i = 0; i < _snapshots.length; i++) ...[
          _RecoveredSnapshotCard(
            snapshot: _snapshots[i],
            index: i + 1,
            summary: _summary(_snapshots[i]),
            date: _date(_snapshots[i].createdAt),
            onTap: () => _openSnapshot(_snapshots[i], i),
          ),
          if (i != _snapshots.length - 1) const SizedBox(height: 10),
        ],
    ],
  );
}

class _RecoveredSnapshotCard extends StatelessWidget {
  const _RecoveredSnapshotCard({
    required this.snapshot,
    required this.index,
    required this.summary,
    required this.date,
    required this.onTap,
  });

  final RecoverySnapshot snapshot;
  final int index;
  final String summary;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
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
                    border: Border.all(color: shCyan.withValues(alpha: .22)),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 21,
                    color: shCyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$index  ${snapshot.type} Snapshot',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: shMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        summary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, color: shMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 9.5, color: shMuted),
                      ),
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

class _DataExportRow extends StatelessWidget {
  const _DataExportRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(label, style: const TextStyle(fontSize: 11, color: shMuted)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _DeleteDataView extends StatefulWidget {
  const _DeleteDataView();

  @override
  State<_DeleteDataView> createState() => _DeleteDataViewState();
}

class _DeleteDataViewState extends State<_DeleteDataView> {
  bool _localFiles = true;
  bool _busy = false;

  Future<void> _delete() async {
    if (!_localFiles || _busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete local files?'),
        content: const Text('This permanently removes files stored locally by SH on this device. Your account is not deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      for (final file in await StorageService.listFiles(includeExports: true)) {
        await file.delete();
      }
      await RecoverySnapshotStore.instance.refreshFromDisk();
      if (!mounted) return;
      setState(() => _localFiles = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Local SH files deleted.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => _DPSubPage(
    title: 'Delete Data',
    children: [
      const _DPSectionLabel('REMOVE DATA'),
      const SizedBox(height: 8),
      const _DPInfoCard(
        icon: Icons.delete_outline_rounded,
        title: 'Delete local SH data',
        description: 'This removes local files from this device only. It does not delete the SH account or server-side data.',
        destructive: true,
      ),
      const SizedBox(height: 14),
      const _DPSectionLabel('DATA'),
      const SizedBox(height: 8),
      _DPSelectableCard(
        icon: Icons.folder_copy_outlined,
        title: 'Local files',
        subtitle: 'Attachment and generated files stored on this device',
        selected: _localFiles,
        onTap: _busy ? null : () => setState(() => _localFiles = !_localFiles),
      ),
      const SizedBox(height: 20),
      _DPActionCard(
        icon: Icons.delete_outline_rounded,
        title: _busy ? 'Deleting…' : 'Delete Selected Data',
        subtitle: _localFiles ? 'Permanently remove local files' : 'Nothing selected',
        destructive: true,
        onTap: _busy || !_localFiles ? () {} : _delete,
      ),
    ],
  );
}

class _DPSelectableCard extends StatelessWidget {
  const _DPSelectableCard({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? shPurple : shBorder, width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 21, color: shMuted),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
          ])),
          Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? shCyan : shMuted, size: 21),
        ]),
      ),
    ),
  );
}

class _PrivacyInformationView extends StatelessWidget {
  const _PrivacyInformationView();

  @override
  Widget build(BuildContext context) => _DPSubPage(
    title: 'Privacy Information',
    children: [
      const _DPSectionLabel('PRIVACY'),
      const SizedBox(height: 8),
      const _DPInfoCard(
        icon: Icons.privacy_tip_outlined,
        title: 'How your data is handled',
        description: 'This page provides a clear overview of how SH data is handled. Detailed policy controls belong to the relevant SH workflows rather than being duplicated here.',
      ),
      const SizedBox(height: 14),
      const _DPSectionLabel('DATA TYPES'),
      const SizedBox(height: 8),
      const _DPOptionCard(
        icon: Icons.storage_outlined,
        title: 'Stored SH data',
        subtitle: 'Data that belongs to your SH account and stored workflows',
      ),
      const SizedBox(height: 10),
      const _DPOptionCard(
        icon: Icons.phone_android_outlined,
        title: 'Local files',
        subtitle: 'Images, files, audio and video kept on this device',
      ),
      const SizedBox(height: 10),
      const _DPOptionCard(
        icon: Icons.tune_rounded,
        title: 'Privacy controls',
        subtitle: 'Policy and permission controls remain in their relevant SH workflows',
      ),
    ],
  );
}

class _DPSubPage extends StatelessWidget {
  const _DPSubPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(
      children: [
        ShTopBar(
          title: title,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
            children: children,
          ),
        ),
      ],
    ),
  );
}

class _DPInfoCard extends StatelessWidget {
  const _DPInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [shSurface2, shSurface]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: shBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: shSurface2,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: shBorder),
          ),
          child: Icon(icon, size: 22, color: destructive ? Colors.redAccent : shCyan),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: destructive ? Colors.redAccent : Colors.white)),
              const SizedBox(height: 5),
              Text(description, style: const TextStyle(fontSize: 11.5, color: shMuted, height: 1.45)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DPOptionCard extends StatelessWidget {
  const _DPOptionCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
    decoration: BoxDecoration(
      color: shSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: shBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: shSurface2,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: shBorder),
          ),
          child: Icon(icon, size: 20, color: shMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: shMuted)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DPActionCard extends StatelessWidget {
  const _DPActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: destructive ? Colors.redAccent.withValues(alpha: .45) : shBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: shSurface2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: shBorder),
              ),
              child: Icon(icon, size: 20, color: destructive ? Colors.redAccent : shCyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: destructive ? Colors.redAccent : Colors.white)),
                  const SizedBox(height: 3),
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

class _DataFilesView extends StatefulWidget {
  const _DataFilesView();
  @override
  State<_DataFilesView> createState() => _DataFilesViewState();
}

class _DataFilesViewState extends State<_DataFilesView> {
  bool _loading = true, _clearing = false;
  int _totalBytes = 0, _images = 0, _videos = 0, _audio = 0, _documents = 0;
  List<File> _files = [];

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    if (mounted) setState(() => _loading = true);
    try {
      final files = await StorageService.listFiles(includeExports: true);
      int total = 0, images = 0, videos = 0, audio = 0, documents = 0;
      for (final file in files) {
        total += await file.length();
        switch (StorageService.categoryFor(file)) {
          case 'images': images++;
          case 'video': videos++;
          case 'audio': audio++;
          default: documents++;
        }
      }
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      if (!mounted) return;
      setState(() {
        _files = files; _totalBytes = total; _images = images; _videos = videos;
        _audio = audio; _documents = documents; _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _size(int b) {
    if (b < 1024) return b.toString() + ' B';
    if (b < 1024 * 1024) return (b / 1024).toStringAsFixed(1) + ' KB';
    if (b < 1024 * 1024 * 1024) return (b / (1024 * 1024)).toStringAsFixed(1) + ' MB';
    return (b / (1024 * 1024 * 1024)).toStringAsFixed(2) + ' GB';
  }

  Future<void> _openCategory(String category) async {
    final files = _files.where((f) => StorageService.categoryFor(f) == category).toList();
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _DataFilesCategoryView(
        title: category == 'images' ? 'Images' : category == 'video' ? 'Videos' : category == 'audio' ? 'Audio' : 'Documents',
        category: category, files: files, size: _size, onChanged: _refresh,
      ),
    ));
    if (mounted) await _refresh();
  }

  Future<void> _clearLocalFiles() async {
    if (_clearing) return;
    setState(() => _clearing = true);
    try {
      for (final file in await StorageService.listFiles()) { await file.delete(); }
      await RecoverySnapshotStore.instance.refreshFromDisk();
    } finally {
      if (mounted) { setState(() => _clearing = false); await _refresh(); }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(
        title: 'Data & Files',
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      Expanded(
        child: _loading
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
                        borderRadius: BorderRadius.circular(24), border: Border.all(color: shBorder),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('LOCAL STORAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: shMuted)),
                        const SizedBox(height: 8),
                        Text(_size(_totalBytes), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                        Text(_files.length.toString() + ' file' + (_files.length == 1 ? '' : 's') + ' in SH storage', style: const TextStyle(fontSize: 12, color: shMuted)),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    const _DPSectionLabel('BY TYPE'),
                    const SizedBox(height: 8),
                    _DPFileStat(icon: Icons.image_outlined, label: 'Images', count: _images, onTap: () => _openCategory('images')),
                    _DPFileStat(icon: Icons.videocam_outlined, label: 'Videos', count: _videos, onTap: () => _openCategory('video')),
                    _DPFileStat(icon: Icons.graphic_eq_rounded, label: 'Audio', count: _audio, onTap: () => _openCategory('audio')),
                    _DPFileStat(icon: Icons.insert_drive_file_outlined, label: 'Documents', count: _documents, onTap: () => _openCategory('documents')),
                    const SizedBox(height: 18),
                    const _DPSectionLabel('FILES'),
                    const SizedBox(height: 8),
                    _DPRecentFiles(files: _files.take(8).toList(), onTap: (file) => _openCategory(StorageService.categoryFor(file))),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _clearing || _files.isEmpty ? null : _clearLocalFiles,
                        child: Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: shBorder)),
                          child: Row(children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(13)),
                              child: _clearing ? const Padding(padding: EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cleaning_services_outlined, size: 20, color: Colors.redAccent),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Clear Local Files', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                              SizedBox(height: 3),
                              Text('Removes files from SH local storage only', style: TextStyle(fontSize: 11, color: shMuted)),
                            ])),
                            const Icon(Icons.chevron_right_rounded, size: 22, color: shMuted),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    ]),
  );
}

class _DPRecentFiles extends StatelessWidget {
  const _DPRecentFiles({required this.files, required this.onTap});
  final List<File> files;
  final ValueChanged<File> onTap;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const _DPInfoCard(icon: Icons.folder_open_outlined, title: 'No local files', description: 'Files created or selected by SH will appear here.');
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, index) {
          final file = files[index], category = StorageService.categoryFor(file);
          final isImage = category == 'images';
          final name = file.path.split(Platform.pathSeparator).last;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18), onTap: () => onTap(file),
              child: Container(
                width: 118,
                decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover)
                    : Stack(children: [
                        Center(child: Icon(category == 'video' ? Icons.videocam_outlined : category == 'audio' ? Icons.graphic_eq_rounded : Icons.insert_drive_file_outlined, size: 34, color: shMuted)),
                        Positioned(left: 10, right: 10, bottom: 8, child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                      ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataFilesCategoryView extends StatefulWidget {
  const _DataFilesCategoryView({required this.title, required this.category, required this.files, required this.size, required this.onChanged});
  final String title, category;
  final List<File> files;
  final String Function(int) size;
  final Future<void> Function() onChanged;
  @override State<_DataFilesCategoryView> createState() => _DataFilesCategoryViewState();
}

class _DataFilesCategoryViewState extends State<_DataFilesCategoryView> {
  late List<File> _files = List<File>.from(widget.files);

  Future<void> _delete(File file) async {
    await file.delete();
    if (!mounted) return;
    setState(() => _files.remove(file));
    await widget.onChanged();
  }

  Future<void> _openExternal(File file) async {
    final opened = await launchUrl(Uri.file(file.path), mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada aplikasi yang dapat membuka file ini.'), behavior: SnackBarBehavior.floating));
    }
  }

  void _openImage(File file) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _DPImageViewer(file: file)));
  }

  @override
  Widget build(BuildContext context) {
    final gallery = widget.category == 'images' || widget.category == 'video';
    return Scaffold(
      backgroundColor: shBackground,
      body: Column(children: [
        ShTopBar(
          title: widget.title,
          leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded)),
        ),
        Expanded(
          child: _files.isEmpty
              ? const Center(child: _DPInfoCard(icon: Icons.folder_open_outlined, title: 'No files', description: 'No local files of this type are currently stored.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                  children: [
                    if (gallery)
                      _DPMediaGrid(files: _files, category: widget.category, onTap: widget.category == 'images' ? _openImage : _openExternal)
                    else
                      _DPAttachmentList(files: _files, category: widget.category, size: widget.size, onTap: _openExternal, onDelete: _delete),
                  ],
                ),
        ),
      ]),
    );
  }
}

class _DPMediaGrid extends StatelessWidget {
  const _DPMediaGrid({required this.files, required this.category, required this.onTap});
  final List<File> files;
  final String category;
  final ValueChanged<File> onTap;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
    itemCount: files.length,
    itemBuilder: (_, index) {
      final file = files[index], isImage = category == 'images';
      return Material(
        color: shSurface, borderRadius: BorderRadius.circular(10), clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTap(file),
          child: isImage
              ? Image.file(file, fit: BoxFit.cover)
              : Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.play_circle_outline_rounded, size: 44),
                  Positioned(left: 6, right: 6, bottom: 6, child: Text(file.path.split(Platform.pathSeparator).last, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                ]),
        ),
      );
    },
  );
}

class _DPImageViewer extends StatelessWidget {
  const _DPImageViewer({required this.file});
  final File file;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: shBackground,
    body: Column(children: [
      ShTopBar(title: 'Image', leading: IconButton(tooltip: 'Back', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded))),
      Expanded(child: Center(child: InteractiveViewer(minScale: .8, maxScale: 4, child: Image.file(file, fit: BoxFit.contain)))),
    ]),
  );
}

class _DPAttachmentList extends StatelessWidget {
  const _DPAttachmentList({required this.files, required this.category, required this.size, required this.onTap, required this.onDelete});
  final List<File> files;
  final String category;
  final String Function(int) size;
  final ValueChanged<File> onTap;
  final ValueChanged<File> onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = category == 'audio' ? Icons.graphic_eq_rounded : Icons.insert_drive_file_outlined;
    return Column(children: [
      for (final file in files)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            decoration: BoxDecoration(color: shSurface, borderRadius: BorderRadius.circular(18), border: Border.all(color: shBorder)),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: shSurface2, borderRadius: BorderRadius.circular(13)), child: Icon(icon, size: 21, color: shMuted)),
              const SizedBox(width: 12),
              Expanded(child: InkWell(
                onTap: () => onTap(file),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(file.path.split(Platform.pathSeparator).last, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(size(file.statSync().size), style: const TextStyle(fontSize: 11, color: shMuted)),
                ]),
              )),
              IconButton(tooltip: 'Delete', onPressed: () => onDelete(file), icon: const Icon(Icons.delete_outline_rounded, size: 19)),
            ]),
          ),
        ),
    ]);
  }
}

class _DPFileStat extends StatelessWidget {
  const _DPFileStat({required this.icon, required this.label, required this.count, required this.onTap});
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: shSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: shBorder),
        ),
        child: Row(children: [
          Icon(icon, size: 19, color: shMuted),
          const SizedBox(width: 11),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text(count.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: shMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20, color: shMuted),
        ]),
      ),
    ),
  );
}

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