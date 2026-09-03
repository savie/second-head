import 'package:flutter/material.dart';

import '../../core/theme/sh_theme.dart';
import '../../core/navigation/sh_navigation_shell.dart';
import 'integration_authorization_store.dart';

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

class _AuthorizationCard extends StatelessWidget {
  const _AuthorizationCard({required this.item, required this.onTap});

  final IntegrationAuthorization item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(item.type);
    final pending = item.status == IntegrationAuthorizationStatus.pending;
    final count = item.scope.values.fold<int>(
      0,
      (total, values) => total + values.length,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: shSurface.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: shBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TypeBadge(label: item.type, accent: accent),
                  const Spacer(),
                  Text(
                    pending
                        ? (item.incoming
                            ? 'Needs your approval'
                            : 'Waiting for approval')
                        : 'Authorized',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: pending ? shMuted : shCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Endpoint(
                      label: 'Source',
                      value: item.sourceShId,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: shMuted,
                    ),
                  ),
                  Expanded(
                    child: _Endpoint(
                      label: 'Target',
                      value: item.targetAccountId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _ScopeSummary(scope: item.scope),
                  const Spacer(),
                  Text(
                    count.toString() + ' data',
                    style: const TextStyle(fontSize: 10, color: shMuted),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: shMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accent(String type) {
    switch (type) {
      case 'Inheritance':
        return const Color(0xFF22D3EE);
      case 'Succession':
        return const Color(0xFF6366F1);
      case 'Legacy':
        return const Color(0xFFF59E0B);
      case 'Clone':
        return const Color(0xFF9A45FF);
      case 'Recovery':
        return const Color(0xFF3B82F6);
      default:
        return shPurple;
    }
  }
}

class _AuthorizationDetail extends StatelessWidget {
  const _AuthorizationDetail({required this.item});

  final IntegrationAuthorization item;

  @override
  Widget build(BuildContext context) {
    final entries = item.scope.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TypeBadge(label: item.type, accent: _accent(item.type)),
                  const Spacer(),
                  Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.status == IntegrationAuthorizationStatus.approved
                          ? shCyan
                          : shMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Authorization Detail',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _DetailRow(label: 'Source SH', value: item.sourceShId),
              _DetailRow(label: 'Target Account', value: item.targetAccountId),
              _DetailRow(label: 'Created', value: _date(item.createdAt)),
              const SizedBox(height: 14),
              const Text(
                'Scope',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Text(
                  'No scoped data.',
                  style: TextStyle(fontSize: 12, color: shMuted),
                )
              else
                for (final entry in entries) ...[
                  _ScopeGroup(
                    title: _scopeTitle(entry.key),
                    ids: entry.value,
                  ),
                  const SizedBox(height: 8),
                ],
              if (item.status == IntegrationAuthorizationStatus.pending &&
                  item.incoming) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          IntegrationAuthorizationStore.instance.reject(item.id);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          IntegrationAuthorizationStore.instance.approve(item.id);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
              if (item.status == IntegrationAuthorizationStatus.approved) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      IntegrationAuthorizationStore.instance.revoke(item.id);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.link_off_rounded, size: 18),
                    label: const Text('Revoke Authorization'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (item.status) {
      case IntegrationAuthorizationStatus.pending:
        return item.incoming ? 'Needs your approval' : 'Waiting for approval';
      case IntegrationAuthorizationStatus.approved:
        return 'Authorized';
      case IntegrationAuthorizationStatus.rejected:
        return 'Rejected';
      case IntegrationAuthorizationStatus.revoked:
        return 'Revoked';
    }
  }

  String _scopeTitle(String key) {
    switch (key) {
      case 'memory_ids':
        return 'Memory';
      case 'knowledge_ids':
        return 'Knowledge';
      case 'experience_ids':
        return 'Experience';
      case 'journey_event_ids':
        return 'Journey';
      default:
        return key;
    }
  }

  String _date(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return value.year.toString() + '-' + two(value.month) + '-' +
        two(value.day) + ' ' + two(value.hour) + ':' + two(value.minute);
  }

  Color _accent(String type) {
    switch (type) {
      case 'Inheritance':
        return const Color(0xFF22D3EE);
      case 'Succession':
        return const Color(0xFF6366F1);
      case 'Legacy':
        return const Color(0xFFF59E0B);
      case 'Clone':
        return const Color(0xFF9A45FF);
      case 'Recovery':
        return const Color(0xFF3B82F6);
      default:
        return shPurple;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: shSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: shBorder),
          ),
          child: Icon(icon, size: 26),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: shMuted)),
          ],
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: shSurface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: shBorder),
      ),
      child: Text(message, style: const TextStyle(fontSize: 12, color: shMuted)),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: .18)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent),
      ),
    );
  }
}

class _Endpoint extends StatelessWidget {
  const _Endpoint({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: shBackground.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: shBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: shMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ScopeSummary extends StatelessWidget {
  const _ScopeSummary({required this.scope});

  final Map<String, List<String>> scope;

  @override
  Widget build(BuildContext context) {
    final labels = <String>[];
    for (final entry in scope.entries) {
      if (entry.value.isNotEmpty) labels.add(_label(entry.key));
    }

    return Flexible(
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final label in labels.take(3))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: shBackground.withValues(alpha: .48),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: shBorder),
              ),
              child: Text(label, style: const TextStyle(fontSize: 9, color: shMuted)),
            ),
        ],
      ),
    );
  }

  String _label(String key) {
    switch (key) {
      case 'memory_ids':
        return 'Memory';
      case 'knowledge_ids':
        return 'Knowledge';
      case 'experience_ids':
        return 'Experience';
      case 'journey_event_ids':
        return 'Journey';
      default:
        return key;
    }
  }
}

class _ScopeGroup extends StatelessWidget {
  const _ScopeGroup({required this.title, required this.ids});

  final String title;
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: shBackground.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: shBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          for (final id in ids)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: shMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: const TextStyle(fontSize: 11, color: shMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
