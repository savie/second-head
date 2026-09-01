import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';

final ValueNotifier<Uint8List?> _profilePhoto = ValueNotifier<Uint8List?>(null);

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 88, maxWidth: 900);
    if (file == null) return;
    _profilePhoto.value = await file.readAsBytes();
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
                onTap: _profilePhoto.value == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        _profilePhoto.value = null;
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShTopBar(
          title: 'Profile',
          actions: [] ,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            children: [
              ValueListenableBuilder<Uint8List?>(
                valueListenable: _profilePhoto,
                builder: (context, photo, _) => Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 16),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: shBorder),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 29,
                              backgroundColor: shSurface2,
                              backgroundImage: photo != null ? MemoryImage(photo) : null,
                              child: photo == null
                                  ? const Icon(Icons.person_outline, size: 27, color: shMuted)
                                  : null,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 23,
                                height: 23,
                                decoration: BoxDecoration(
                                  color: shPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: shSurface, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_outlined, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(height: 3),
                            Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: shMuted)),
                            SizedBox(height: 5),
                            Text('Tap your photo to change it', style: TextStyle(fontSize: 8, color: shMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _showPhotoOptions,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _SettingsGroup(title: 'Settings', items: [
                _SettingItem(Icons.person_outline, 'Account', 'Manage your personal information'),
                _SettingItem(Icons.palette_outlined, 'Appearance', 'Choose theme and language'),
                _SettingItem(Icons.notifications_none, 'Notifications', 'Manage your notification preferences'),
                _SettingItem(Icons.lock_outline, 'Security', 'Password and security settings'),
                _SettingItem(Icons.hub_outlined, 'Integrations', 'Manage connected services'),
                _SettingItem(Icons.shield_outlined, 'Data & Privacy', 'Manage your data and privacy'),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePhotoAction extends StatelessWidget {
  const _ProfilePhotoAction({required this.icon, required this.label, required this.onTap});
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
                gradient: const LinearGradient(colors: [shPurple, shElectric]),
              ),
              child: Icon(icon),
            ),
          ),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});
  final String title;
  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: shBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1) const Divider(height: 1, color: shBorder),
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
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Icon(icon, size: 19, color: shMuted),
      title: Text(title, style: const TextStyle(fontSize: 11)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 8, color: shMuted)),
      trailing: const Icon(Icons.chevron_right, size: 17, color: shMuted),
    );
  }
}
