import 'package:flutter/material.dart';
import '../lifecycle_models.dart';
import '../lifecycle_widgets.dart';

class SuccessionView extends StatelessWidget {
  const SuccessionView({super.key, this.incomingItems = const []});

  final List<JourneyLifecyclePayload> incomingItems;

  @override
  Widget build(BuildContext context) => LifecycleDetailView(stage: LifecycleStage.succession, incomingItems: incomingItems);
}
