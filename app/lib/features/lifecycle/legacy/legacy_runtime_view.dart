import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/state/sh_profile_state.dart';
import '../../../core/theme/sh_theme.dart';
import '../../journey/journey_runtime_service.dart';
import '../../journey/journey_service.dart';
import '../lifecycle_runtime_read_service.dart';

class LegacyRuntimeView extends StatefulWidget {
  const LegacyRuntimeView({super.key});

  @override
  State<LegacyRuntimeView> createState() => _LegacyRuntimeViewState();
}

class _LegacyRuntimeViewState extends State<LegacyRuntimeView> {
  final _read = const LifecycleRuntimeReadService();
  final _runtime = const JourneyRuntimeService();
  final _journey = const JourneyService();
  List<Map<String, dynamic>> _records = const [];
  List<JourneyBackendRecord> _journeyRecords = const [];
  final Set<String> _selectedEventIds = <String>{};
  bool _loading = true;
  bool _preserving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        _read.listLegacyRecords(),
        _journey.load(limit: 100),
      ]);
      if (!mounted) return;
      setState(() {
        _records = results[0] as List<Map<String, dynamic>>;
        _journeyRecords = results[1] as List<JourneyBackendRecord>;
        _selectedEventIds.removeWhere(
          (id) => !_journeyRecords.any((record) => record.eventId == id),
        );
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

  Future<void> _preserveSelectedLegacy() async {
    final shId = profileShId.value.trim();
    if (shId.isEmpty) {
      _show('Legacy blocked: active SH identity is unavailable.');
      return;
    }
    if (_selectedEventIds.isEmpty) {
      _show('Select at least one concrete Journey item to preserve.');
      return;
    }

    final memoryIds = <String>{};
    final knowledgeIds = <String>{};
    final experienceIds = <String>{};
    for (final record in _journeyRecords) {
      if (!_selectedEventIds.contains(record.eventId)) continue;
      final payload = record.payload;
      final memoryId = payload['memory_id']?.toString().trim() ?? '';
      final knowledgeId = payload['knowledge_id']?.toString().trim() ?? '';
      final experienceId = payload['experience_id']?.toString().trim() ?? '';
      if (memoryId.isNotEmpty) memoryIds.add(memoryId);
      if (knowledgeId.isNotEmpty) knowledgeIds.add(knowledgeId);
      if (experienceId.isNotEmpty) experienceIds.add(experienceId);
    }

    final scope = <String, dynamic>{
      'memory_ids': memoryIds.toList(),
      'knowledge_ids': knowledgeIds.toList(),
      'experience_ids': experienceIds.toList(),
      'journey_event_ids': _selectedEventIds.toList(),
    };

    setState(() => _preserving = true);
    try {
      await _runtime.preserveSelectedTransferAsLegacy(
        sourceShId: shId,
        scope: scope,
      );
      if (!mounted) return;
      setState(() {
        _selectedEventIds.clear();
        _preserving = false;
      });
      await _load();
      _show('Selected Journey items preserved canonically as legacy.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _preserving = false);
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

  String _journeyLabel(JourneyBackendRecord record) {
    final type = record.eventType.toUpperCase();
    final payload = record.payload;
    final id = payload['memory_id'] ?? payload['knowledge_id'] ?? payload['experience_id'];
    return id == null ? type : '$type · $id';
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
              'Legacy preservation is bound to concrete Journey selections and enforced by runtime transfer-policy authority after end-of-life.',
              style: TextStyle(color: shMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading || _preserving ? null : _preserveSelectedLegacy,
              icon: const Icon(Icons.archive_outlined),
              label: Text(_preserving ? 'Preserving…' : 'Preserve selected items'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Journey items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Text('Legacy/Journey read failed: $_error')
            else if (_journeyRecords.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No Journey items available for selection.'),
              )
            else
              for (final record in _journeyRecords)
                CheckboxListTile(
                  value: _selectedEventIds.contains(record.eventId),
                  onChanged: _preserving
                      ? null
                      : (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedEventIds.add(record.eventId);
                            } else {
                              _selectedEventIds.remove(record.eventId);
                            }
                          });
                        },
                  title: Text(_journeyLabel(record)),
                  subtitle: Text(
                    '${_date(record.occurredAt)} · ${record.continuityStatus}',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            const SizedBox(height: 16),
            const Text(
              'Existing canonical legacy records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (!_loading && _records.isEmpty)
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
