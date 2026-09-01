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

  Future<void> _search(BuildContext context) async {
    const settings = [
      _SettingItem(Icons.person_outline, 'Account', 'Manage your personal information'),
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
              const _SettingsGroup(
                items: [
                  _SettingItem(
                    Icons.person_outline,
                    'Account',
                    'Manage your personal information',
                  ),
                  _SettingItem(
                    Icons.palette_outlined,
                    'Appearance',
                    'Choose theme and language',
                  ),
                  _SettingItem(
                    Icons.notifications_none,
                    'Notifications',
                    'Manage your notification preferences',
                  ),
                  _SettingItem(
                    Icons.lock_outline,
                    'Security',
                    'Password and security settings',
                  ),
                  _SettingItem(
                    Icons.hub_outlined,
                    'Integrations',
                    'Manage connected services',
                  ),
                  _SettingItem(
                    Icons.shield_outlined,
                    'Data & Privacy',
                    'Manage your data and privacy',
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
  const _SettingItem(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: InkWell(
        onTap: () {},
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
