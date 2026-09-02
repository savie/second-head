enum ShSemanticDomain { memory, knowledge, experience }

class ShSemanticCandidate {
  const ShSemanticCandidate({
    required this.domain,
    required this.sourceId,
    required this.content,
  });

  final ShSemanticDomain domain;
  final String sourceId;
  final String content;
}

abstract interface class ShSemanticHook {
  Future<List<ShSemanticCandidate>> process({
    required String sourceId,
    required String content,
  });
}
