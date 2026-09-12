import '../../core/backend/backend_client.dart';

class JourneyBackendRecord {
  const JourneyBackendRecord({
    required this.eventId,
    required this.eventType,
    required this.occurredAt,
    required this.continuityStatus,
    required this.payload,
  });

  final String eventId;
  final String eventType;
  final DateTime occurredAt;
  final String continuityStatus;
  final Map<String, dynamic> payload;
}

class JourneyService {
  const JourneyService();

  Future<List<JourneyBackendRecord>> load({int limit = 50}) async {
    final result = await backendClient.rpc(
      'runtime_get_journey_context',
      params: {
        'p_sh_id': await _resolveShId(),
        'p_limit': limit,
      },
    );

    if (result is! Map) return const [];
    final rawEvents = result['events'];
    if (rawEvents is! List) return const [];

    return [
      for (final raw in rawEvents)
        if (raw is Map) _parse(raw),
    ];
  }

  Future<String> _resolveShId() async {
    final result = await backendClient.rpc('resolve_identity');
    if (result is! List || result.isEmpty) {
      throw StateError('Journey identity resolution returned no actor.');
    }

    final row = result.first;
    if (row is! Map) {
      throw StateError('Journey identity resolution returned an invalid row.');
    }

    final shId = row['sh_id']?.toString();
    if (shId == null || shId.isEmpty) {
      throw StateError('Journey identity resolution did not return sh_id.');
    }
    return shId;
  }

  JourneyBackendRecord _parse(Map raw) {
    final payload = raw['payload'];
    final occurredAt = DateTime.tryParse(raw['occurred_at']?.toString() ?? '');
    return JourneyBackendRecord(
      eventId: raw['event_id']?.toString() ?? '',
      eventType: raw['event_type']?.toString() ?? '',
      occurredAt: occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      continuityStatus: raw['continuity_status']?.toString() ?? '',
      payload: payload is Map
          ? Map<String, dynamic>.from(payload)
          : const <String, dynamic>{},
    );
  }
}
