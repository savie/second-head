class JourneyLifecyclePayload {
  const JourneyLifecyclePayload({
    required this.title,
    required this.type,
    required this.content,
    required this.isPrivate,
    required this.date,
    this.semanticSourceId,
  });

  final String title;
  final String type;
  final String content;
  final bool isPrivate;
  final String date;
  final String? semanticSourceId;
}
