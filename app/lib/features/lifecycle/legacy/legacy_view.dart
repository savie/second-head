import 'package:flutter/material.dart';

import '../lifecycle_models.dart';
import 'legacy_runtime_view.dart';

class LegacyView extends StatelessWidget {
  const LegacyView({super.key, this.incomingItems = const []});

  final List<JourneyLifecyclePayload> incomingItems;

  @override
  Widget build(BuildContext context) => LegacyRuntimeView(incomingItems: incomingItems);
}
