import 'package:flutter/material.dart';

import '../lifecycle_models.dart';
import 'recovery_runtime_view.dart';

class RecoveryView extends StatelessWidget {
  const RecoveryView({super.key, this.incomingItems = const []});

  final List<JourneyLifecyclePayload> incomingItems;

  @override
  Widget build(BuildContext context) => const RecoveryRuntimeView();
}
