import 'package:flutter/material.dart';
import 'package:second_head/features/auth/auth_screens.dart';

// ... existing file content retained; logout implementation below is the
// only integration change in this file.

void _logout() {
  AuthSession.service.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
