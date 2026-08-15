import 'topic.dart';

enum CandidateSource {
  progress,
  repair,
  reinforcement,
  measurement,
}

enum CandidateReason {
  // Repair
  lowMastery,
  chronicWeakness,
  performanceDecline,

  // Reinforcement
  masteryMaintenance,

  // Measurement
  lowConfidence,
  staleEvidence,
  insufficientEvidence,
}

class CandidateSignal {
  const CandidateSignal({
    required this.source,
    required this.reason,
    required this.strength,
  }) : assert(strength >= 0.0 && strength <= 1.0);

  /// Candidate source that produced this signal.
  final CandidateSource source;

  /// Machine-readable reason for the signal.
  final CandidateReason reason;

  /// Normalized strength of this individual signal.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is not the final candidate ranking score.
  final double strength;
}

class StudyCandidate {
  const StudyCandidate({
    required this.topicId,
    required this.primarySource,
    required this.sources,
    required this.requiresBridge,
    required this.bridgeTopicId,
    this.signals = const [],
  });

  /// Topic this candidate is about.
  final TopicId topicId;

  /// The dominant source for this candidate.
  ///
  /// How dominance is selected will later be determined by ranking logic.
  final CandidateSource primarySource;

  /// All sources that contributed to this candidate.
  final Set<CandidateSource> sources;

  /// Machine-readable signals that caused this candidate to exist.
  ///
  /// These signals are preserved through candidate merging and can later
  /// feed ranking and reason/audit generation.
  final List<CandidateSignal> signals;

  /// Whether this candidate requires bridge work before the target topic.
  final bool requiresBridge;

  /// The selected bridge topic when [requiresBridge] is true.
  ///
  /// Null when no bridge is required.
  final TopicId? bridgeTopicId;
}