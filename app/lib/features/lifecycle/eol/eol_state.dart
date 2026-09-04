enum EolFlowState {
  overview,
  impactReview,
  confirmation,
  executing,
  terminal,
  cancelled,
  failed,
}

class EolImpact {
  const EolImpact({
    required this.journeyItems,
    required this.relationships,
    required this.recoverySnapshots,
  });

  final int journeyItems;
  final int relationships;
  final int recoverySnapshots;
}

class EolState {
  const EolState({
    this.flow = EolFlowState.overview,
    this.acknowledged = false,
    this.impact = const EolImpact(
      journeyItems: 0,
      relationships: 0,
      recoverySnapshots: 0,
    ),
    this.errorMessage,
  });

  final EolFlowState flow;
  final bool acknowledged;
  final EolImpact impact;
  final String? errorMessage;

  EolState copyWith({
    EolFlowState? flow,
    bool? acknowledged,
    EolImpact? impact,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EolState(
      flow: flow ?? this.flow,
      acknowledged: acknowledged ?? this.acknowledged,
      impact: impact ?? this.impact,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
