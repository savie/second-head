import 'package:flutter/material.dart';

void main() {
  runApp(const SecondHeadApp());
}

class SecondHeadApp extends StatelessWidget {
  const SecondHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SECOND HEAD',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const _FoundationScreen(),
    );
  }
}

class _FoundationScreen extends StatelessWidget {
  const _FoundationScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('SECOND HEAD'),
      ),
    );
  }
}
