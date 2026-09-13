import 'package:flutter/material.dart';

import 'recovery_runtime_view.dart';

class RecoveryView extends StatelessWidget {
  const RecoveryView({super.key, this.incomingItems = const []});

  final List<dynamic> incomingItems;

  @override
  Widget build(BuildContext context) => const RecoveryRuntimeView();
}
