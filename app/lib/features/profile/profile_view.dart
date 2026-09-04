import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/state/sh_profile_state.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import 'account/account_view.dart';
import 'appearance/appearance_view.dart';
import 'notifications/notifications_view.dart';
import 'security/security_view.dart';
import 'integrations/integrations_view.dart';
import 'data_privacy/data_privacy_view.dart';
import '../../core/storage/storage_service.dart';


Widget _profileDestination(String title) {
  switch (title) {
    case 'Account': return const AccountView();
    case 'Appearance': return const AppearanceView();
    case 'Notifications': return const NotificationsView();
    case 'Security': return const SecurityView();
    case 'Integrations': return const IntegrationsView();
    case 'Data & Privacy': return const DataPrivacyView();
    default: return const SizedBox.shrink();
  }
}

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
              ProfilePhotoAction(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ProfilePhotoAction(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ProfilePhotoAction(
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
        builder: (_) => title == 'Account' ? const AccountView() : _profileDestination(title),
      ),
    );
  }

  Future<void> _search(BuildContext context) async {
    const settings = [
      SettingItem(Icons.person_outline, 'Account', 'Manage your personal information', onTap: null),
      SettingItem(Icons.palette_outlined, 'Appearance', 'Choose theme and language'),
      SettingItem(Icons.notifications_none, 'Notifications', 'Manage your notification preferences'),
      SettingItem(Icons.lock_outline, 'Security', 'Password and security settings'),
      SettingItem(Icons.hub_outlined, 'Integrations', 'Manage connected services'),
      SettingItem(Icons.shield_outlined, 'Data & Privacy', 'Manage your data and privacy'),
    ];
    final result = await showShInternalSearch<SettingItem>(
      context: context,
      hintText: 'Search Profile',
      search: (query) => [
        for (final item in settings)
          if (query.isEmpty ||
              '${item.title} ${item.subtitle}'.toLowerCase().contains(query))
            ShSearchResult<SettingItem>(
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
                builder: (context, photo, _) => ProfileHero(
                  photo: photo,
                  onEdit: _showPhotoOptions,
                ),
              ),
              const SizedBox(height: 18),
              SettingsGroup(
                items: [
                  SettingItem(
                    Icons.person_outline,
                    'Account',
                    'Manage your personal information',
                    onTap: () => _openSection(context, 'Account', 'Manage your personal information'),
                  ),
                  SettingItem(
                    Icons.palette_outlined,
                    'Appearance',
                    'Choose theme and language',
                    onTap: () => _openSection(context, 'Appearance', 'Choose theme and language'),
                  ),
                  SettingItem(
                    Icons.notifications_none,
                    'Notifications',
                    'Manage your notification preferences',
                    onTap: () => _openSection(context, 'Notifications', 'Manage your notification preferences'),
                  ),
                  SettingItem(
                    Icons.lock_outline,
                    'Security',
                    'Password and security settings',
                    onTap: () => _openSection(context, 'Security', 'Password and security settings'),
                  ),
                  SettingItem(
                    Icons.hub_outlined,
                    'Integrations',
                    'Manage connected services',
                    onTap: () => _openSection(context, 'Integrations', 'Manage connected services'),
                  ),
                  SettingItem(
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
