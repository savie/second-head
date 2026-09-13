import 'package:flutter/material.dart';
import '../lifecycle_models.dart';
import '../lifecycle_authority_view.dart';

class InheritanceView extends StatelessWidget {
  const InheritanceView({super.key, this.incomingItems = const []});
  final List<JourneyLifecyclePayload> incomingItems;

  @override
  Widget build(BuildContext context) => const LifecycleAuthorityView(stage: LifecycleStage.inheritance);
}
