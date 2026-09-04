import 'package:flutter/material.dart';
import '../lifecycle_models.dart';
import '../lifecycle_widgets.dart';

class InheritanceView extends StatelessWidget {
  const InheritanceView({super.key, this.incomingItems = const []});

  final List<JourneyLifecyclePayload> incomingItems;

  @override
  Widget build(BuildContext context) => LifecycleDetailView(stage: LifecycleStage.inheritance, incomingItems: incomingItems);
}
