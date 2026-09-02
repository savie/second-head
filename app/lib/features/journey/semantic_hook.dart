import 'package:flutter/foundation.dart';

enum ShSemanticDomain { memory, knowledge, experience }

class ShSemanticCandidate {
  const ShSemanticCandidate({required this.domain, required this.sourceId, required this.content});
  final ShSemanticDomain domain;
  final String sourceId;
  final String content;
}

abstract interface class ShSemanticHook {
  Future<List<ShSemanticCandidate>> process({required String sourceId, required String content});
}

/// Frontend-only deterministic simulator. It recognizes explicit save commands
/// and deliberately does not attempt general semantic classification.
class ShFrontendSemanticSimulator implements ShSemanticHook {
  @override
  Future<List<ShSemanticCandidate>> process({required String sourceId, required String content}) async {
    final normalized = content.trim();
    final lower = normalized.toLowerCase();
    final matchers = <(ShSemanticDomain, List<String>)>[
      (ShSemanticDomain.memory, ['buatin memori tentang ', 'buat memori tentang ', 'simpan sebagai memori ']),
      (ShSemanticDomain.knowledge, ['buatin knowledge tentang ', 'buat knowledge tentang ', 'simpan sebagai knowledge ']),
      (ShSemanticDomain.experience, ['buatin experience tentang ', 'buat experience tentang ', 'simpan sebagai experience ']),
    ];
    for (final matcher in matchers) {
      for (final prefix in matcher.$2) {
        if (lower.startsWith(prefix)) {
          final value = normalized.substring(prefix.length).trim();
          if (value.isEmpty) return const [];
          return [ShSemanticCandidate(domain: matcher.$1, sourceId: sourceId, content: value)];
        }
      }
    }
    return const [];
  }
}

class ShSemanticRecord {
  const ShSemanticRecord({required this.domain, required this.sourceId, required this.content, required this.createdAt});
  final ShSemanticDomain domain;
  final String sourceId;
  final String content;
  final DateTime createdAt;
}

final ValueNotifier<List<ShSemanticRecord>> shSemanticRecords =
    ValueNotifier<List<ShSemanticRecord>>(<ShSemanticRecord>[]);

final ShFrontendSemanticSimulator shFrontendSemanticSimulator = ShFrontendSemanticSimulator();

void shAddSemanticRecord(ShSemanticCandidate candidate) {
  shSemanticRecords.value = [
    ...shSemanticRecords.value,
    ShSemanticRecord(domain: candidate.domain, sourceId: candidate.sourceId, content: candidate.content, createdAt: DateTime.now()),
  ];
}
