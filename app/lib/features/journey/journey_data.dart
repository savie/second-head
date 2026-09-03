class JourneyItem {
  JourneyItem(
    this.title,
    this.subtitle,
    this.date,
    this.type,
    this.content,
    this.isPrivate, {
    this.semanticSourceId,
  });

  String title;
  String subtitle;
  String date;
  String type;
  String content;
  bool isPrivate;
  final String? semanticSourceId;
}

final List<JourneyItem> shJourneyItems = [
    JourneyItem(
      'Project SH Roadmap',
      'Documented roadmap and key milestones',
      '2 days ago',
      'Knowledge',
      'The documented roadmap and key milestones for Second Head.',
      true,
    ),
    JourneyItem(
      'Client Meeting Notes',
      'Important notes from the meeting about feature priorities.',
      'Yesterday',
      'Experience',
      'Important notes captured from the client meeting and its feature priorities.',
      false,
    ),
    JourneyItem(
      'Ideas – AI Personalization',
      'Ideas about personalization based on user behavior.',
      'May 29',
      'Memory',
      'Ideas and retained context about personalization based on user behavior.',
      true,
    ),
    JourneyItem(
      'Reference – Runtime Contract',
      'Notes about runtime contract and future calling.',
      'May 25',
      'Knowledge',
      'Reference material describing the runtime contract and future calling.',
      false,
    ),
    JourneyItem(
      'Shared Memory — User Preference Context',
      'Shared memory eligible for I / S / L.',
      'Today',
      'Memory',
      'Example shared memory context that has passed Journey policy and can enter the Lifecycle I / S / L path.',
      false,
      semanticSourceId: 'demo:journey:shared-memory',
    ),
    JourneyItem(
      'Shared Knowledge — SH Runtime Context',
      'Shared knowledge eligible for I / S / L.',
      'Today',
      'Knowledge',
      'Example shared knowledge context that has passed Journey policy and can enter the Lifecycle I / S / L path.',
      false,
      semanticSourceId: 'demo:journey:shared-knowledge',
    ),
    JourneyItem(
      'Shared Experience — Approval Context',
      'Shared experience eligible for I / S / L.',
      'Today',
      'Experience',
      'Example shared experience context that has passed Journey policy and can enter the Lifecycle I / S / L path.',
      false,
      semanticSourceId: 'demo:journey:shared-experience',
    ),
];
