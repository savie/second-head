import 'package:flutter/material.dart';

import '../../../core/theme/sh_theme.dart';
import '../../../core/navigation/sh_navigation_shell.dart';
import 'integration_authorization_store.dart';

part 'integration_widgets.dart';

class IntegrationsView extends StatefulWidget {
  const IntegrationsView({super.key});

  @override
  State<IntegrationsView> createState() => _IntegrationsViewState();
}

class _IntegrationsViewState extends State<IntegrationsView> {
  final store = IntegrationAuthorizationStore.instance;

  @override
  void initState() {
    super.initState();
    store.addListener(_refresh);
    store.refreshFromDisk();
  }

  @override
  void dispose() {
    store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _detail(IntegrationAuthorization item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _AuthorizationDetail(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = store.pending;
    final authorized = store.authorized;

    return Scaffold(
      backgroundColor: shBackground,
      body: Column(
        children: [
          ShTopBar(
            title: 'Integrations',
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                _SectionHeader(
                  icon: Icons.pending_actions_outlined,
                  title: 'Pending',
                  subtitle: pending.length.toString() + ' authorization requests',
                ),
                const SizedBox(height: 10),
                if (pending.isEmpty)
                  const _EmptyCard(message: 'No pending authorization requests.')
                else
                  for (final item in pending) ...[
                    _AuthorizationCard(item: item, onTap: () => _detail(item)),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 12),
                _SectionHeader(
                  icon: Icons.verified_user_outlined,
                  title: 'Authorized',
                  subtitle: authorized.length.toString() + ' active',
                ),
                const SizedBox(height: 10),
                if (authorized.isEmpty)
                  const _EmptyCard(message: 'No active authorizations.')
                else
                  for (final item in authorized) ...[
                    _AuthorizationCard(item: item, onTap: () => _detail(item)),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
