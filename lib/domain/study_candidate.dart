import 'topic.dart';

enum CandidateSource {
  progress,
  repair,
  reinforcement,
  measurement,
}

class StudyCandidate {
  const StudyCandidate({
    required this.topicId,
    required this.primarySource,
    required this.sources,
    required this.requiresBridge,
    required this.bridgeTopicId,
  });

  /// Topic this candidate is about.
  final TopicId topicId;

  /// The dominant source for this candidate.
  ///
  /// How dominance is selected will be determined later by ranking logic.
  final CandidateSource primarySource;

  /// All sources that contributed to this candidate.
  ///
  /// A single topic may be triggered by more than one source,
  /// for example both Repair and Reinforcement.
  final Set<CandidateSource> sources;

  /// Whether this candidate requires bridge work before the target topic.
  final bool requiresBridge;

  /// The selected bridge topic when [requiresBridge] is true.
  ///
  /// Null when no bridge is required.
  final TopicId? bridgeTopicId;
}