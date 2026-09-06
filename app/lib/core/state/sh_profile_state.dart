import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../identity/sh_identity.dart';
import '../storage/storage_service.dart';
import '../theme/sh_theme.dart';

final ValueNotifier<Uint8List?> profilePhoto = ValueNotifier<Uint8List?>(null);

final Future<void> profilePhotoLoad = _loadProfilePhoto();

Future<void> _loadProfilePhoto() async {
  try {
    profilePhoto.value = await StorageService.readProfilePhoto();
  } catch (_) {
    profilePhoto.value = null;
  }
}

final ValueNotifier<String> profileName = ValueNotifier<String>('Savie');
final Future<void> profileNameLoad = _loadProfileName();

Future<void> _loadProfileName() async {
  try {
    final saved = await StorageService.readProfileName();
    if (saved != null && saved.trim().isNotEmpty) {
      profileName.value = saved.trim();
    }
  } catch (_) {}
}

Future<void> saveProfileName(String name) async {
  final normalized = name.trim();
  if (normalized.isEmpty) return;
  profileName.value = normalized;
  await StorageService.saveProfileName(normalized);
}

final ValueNotifier<String> profileEmail = ValueNotifier<String>('');
final ValueNotifier<String> profileAccountId = ValueNotifier<String>('');
final ValueNotifier<String> profileShId = ValueNotifier<String>('');
final ValueNotifier<DateTime?> profileAccountCreatedAt =
    ValueNotifier<DateTime?>(null);

void refreshProfileEmail() {
  profileEmail.value =
      Supabase.instance.client.auth.currentUser?.email?.trim() ?? '';
}

void refreshProfileIdentity(ShIdentity identity) {
  profileAccountId.value = identity.accountId;
  profileShId.value = identity.shId;
  final createdAt = Supabase.instance.client.auth.currentUser?.createdAt;
  profileAccountCreatedAt.value =
      createdAt == null ? null : DateTime.tryParse(createdAt)?.toLocal();
}

void clearProfileIdentity() {
  profileEmail.value = '';
  profileAccountId.value = '';
  profileShId.value = '';
  profileAccountCreatedAt.value = null;
}

class ShProfileMark extends StatelessWidget {
  const ShProfileMark({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: profilePhoto,
      builder: (context, photo, _) {
        return Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [shPurple, shElectric]),
          ),
          child: ClipOval(
            child: photo != null
                ? Image.memory(
                    photo,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/brand/unity.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  )
                : Image.asset(
                    'assets/brand/unity.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
          ),
        );
      },
    );
  }
}
