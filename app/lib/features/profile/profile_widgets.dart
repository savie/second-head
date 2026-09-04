import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/sh_theme.dart';
import '../../core/state/sh_profile_state.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({
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
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
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

class ProfilePhotoAction extends StatelessWidget {
  const ProfilePhotoAction({
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

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.items});

  final List<SettingItem> items;

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

class SettingItem extends StatelessWidget {
  const SettingItem(this.icon, this.title, this.subtitle, {this.onTap});

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
