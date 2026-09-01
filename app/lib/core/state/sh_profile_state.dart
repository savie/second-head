import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/sh_theme.dart';

final ValueNotifier<Uint8List?> profilePhoto = ValueNotifier<Uint8List?>(null);

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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [shPurple, shElectric]),
          ),
          child: ClipOval(
            child: photo != null
                ? Image.memory(photo, fit: BoxFit.cover, filterQuality: FilterQuality.high)
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
