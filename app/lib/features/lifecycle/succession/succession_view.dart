import 'package:flutter/material.dart';
import '../lifecycle_models.dart';
import '../lifecycle_stage.dart';
import '../lifecycle_authority_view.dart';

class SuccessionView extends StatelessWidget {
  const SuccessionView({super.key, this.incomingItems = const []});
  final List<JourneyLifecyclePayload> incomingItems;

  @override
  Widget build(BuildContext context) => LifecycleAuthorityView(
        stage: LifecycleStage.succession,
        incomingItems: incomingItems,
      );
}
