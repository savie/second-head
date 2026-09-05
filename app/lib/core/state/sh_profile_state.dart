import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/sh_theme.dart';
import '../storage/storage_service.dart';

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
final ValueNotifier<String> profileEmail = ValueNotifier<String>('savie@secondhead.app');

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
