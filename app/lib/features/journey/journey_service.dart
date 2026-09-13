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

    final records = [
      for (final raw in rawEvents)
        if (raw is Map) _parse(raw),
    ];

    final experienceIds = <String>{
      for (final record in records)
        if (record.eventType.toUpperCase() == 'EXPERIENCE')
          if (record.payload['experience_id']?.toString().isNotEmpty == true)
            record.payload['experience_id'].toString(),
    };
    if (experienceIds.isEmpty) return records;

    final experiences = await _loadExperiences();
    final byId = <String, Map<String, dynamic>>{
      for (final experience in experiences)
        if (experience['experience_id']?.toString().isNotEmpty == true)
          experience['experience_id'].toString(): experience,
    };

    return [
      for (final record in records)
        if (record.eventType.toUpperCase() == 'EXPERIENCE')
          _withExperienceContent(record, byId[record.payload['experience_id']?.toString()])
        else
          record,
    ];
  }

  Future<List<Map<String, dynamic>>> _loadExperiences() async {
    final result = await backendClient.rpc(
      'list_experiences',
      params: {
        'p_sh_id': await _resolveShId(),
        'p_limit': 100,
      },
    );
    if (result is! List) return const [];
    return [
      for (final raw in result)
        if (raw is Map) Map<String, dynamic>.from(raw),
    ];
  }

  JourneyBackendRecord _withExperienceContent(
    JourneyBackendRecord record,
    Map<String, dynamic>? experience,
  ) {
    final existingContent = record.payload['content']?.toString().trim() ?? '';
    if (existingContent.isNotEmpty || experience == null) return record;

    return JourneyBackendRecord(
      eventId: record.eventId,
      eventType: record.eventType,
      occurredAt: record.occurredAt,
      continuityStatus: record.continuityStatus,
      payload: {
        ...record.payload,
        'content': experience['content']?.toString() ?? '',
        'visibility': experience['visibility'],
      },
    );
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
