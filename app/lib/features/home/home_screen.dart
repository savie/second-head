import 'package:flutter/material.dart';

import '../../core/navigation/sh_navigation_shell.dart';
import '../conversation/conversation_view.dart';
import '../journey/journey_view.dart';
import '../lifecycle/lifecycle_view.dart';
import '../more/more_views.dart';
import '../profile/profile_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShNavigationShell(
      drawerBuilder: (context, onSelectPage) =>
          SideMenu(onSelectPage: onSelectPage),
      pages: const [
        ConversationView(),
        JourneyView(),
        LifecycleView(),
        ProfileView(),
      ],
    );
  }
}
