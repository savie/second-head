import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/state/sh_profile_state.dart';
import '../../../core/theme/sh_theme.dart';
import '../../journey/journey_runtime_service.dart';
import '../lifecycle_runtime_read_service.dart';

class LegacyRuntimeView extends StatefulWidget {
  const LegacyRuntimeView({super.key});

  @override
  State<LegacyRuntimeView> createState() => _LegacyRuntimeViewState();
}

class _LegacyRuntimeViewState extends State<LegacyRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  List<Map<String, dynamic>> _records = const [];
  bool _loading = true;
  String? _error;
  String _type = 'JOURNEY';
  final _retentionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _retentionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final rows = await _read.listLegacyRecords();
      if (!mounted) return;
      setState(() {
        _records = rows;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _preserveLegacy() async {
    final shId = profileShId.value.trim();
    if (shId.isEmpty) {
      _show('Legacy blocked: active SH identity is unavailable.');
      return;
    }

    DateTime? retention;
    final rawRetention = _retentionController.text.trim();
    if (rawRetention.isNotEmpty) {
      retention = DateTime.tryParse(rawRetention);
      if (retention == null) {
        _show('Retention date must be a valid ISO date/time.');
        return;
      }
    }

    try {
      await _runtime.recordLegacy(
        sourceShId: shId,
        legacyType: _type,
        payload: const {
          'capture_mode': 'LIFECYCLE_UI',
        },
        provenance: const {
          'source': 'lifecycle-legacy-ui',
        },
        retentionUntil: retention,
      );
      await _load();
      _show('Legacy record preserved canonically.');
    } catch (error) {
      _show('Legacy preservation failed: $error');
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed == null ? '—' : parsed.toLocal().toString();
  }

  String _payload(dynamic value) {
    if (value == null) return '{}';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legacy')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Canonical Legacy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Legacy records are preserved by the runtime authority after the source SH reaches its required lifecycle state.',
              style: TextStyle(color: shMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Legacy type'),
              items: const [
                'MEMORY',
                'KNOWLEDGE',
                'EXPERIENCE',
                'JOURNEY',
                'HISTORY',
                'VALUE',
                'REFERENCE',
              ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _retentionController,
              decoration: const InputDecoration(
                labelText: 'Retention until (optional)',
                hintText: '2027-01-01T00:00:00Z',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _preserveLegacy,
              icon: const Icon(Icons.archive_outlined),
              label: const Text('Preserve legacy record'),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Text('Legacy read failed: $_error')
            else if (_records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No canonical legacy records found.'),
              )
            else
              for (final row in _records)
                Card(
                  child: ExpansionTile(
                    title: Text(row['legacy_type']?.toString() ?? 'UNKNOWN'),
                    subtitle: Text(
                      '${row['status']?.toString() ?? 'UNKNOWN'} · ${_date(row['created_at'])}',
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      SelectableText(_payload(row['payload'])),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
