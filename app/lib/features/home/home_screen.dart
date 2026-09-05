import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../conversation/conversation_service.dart';
import '../conversation/conversation_view.dart';
import '../journey/journey_view.dart';
import '../lifecycle/lifecycle_view.dart';
import '../more/more_views.dart';
import '../profile/profile_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ConversationService.activeConversationId,
      builder: (context, activeConversationId, _) {
        return ShNavigationShell(
          drawerBuilder: (context, onSelectPage) =>
              SideMenu(onSelectPage: onSelectPage),
          pages: [
            ConversationView(key: ValueKey(activeConversationId ?? 'active-conversation')),
            const JourneyView(),
            const LifecycleView(),
            const ProfileView(),
          ],
        );
      },
    );
  }
}
