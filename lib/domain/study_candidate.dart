import 'topic.dart';

enum CandidateSource {
  progress,
  practice,
  repair,
  measurement,
}

enum CandidateReason {
  // Practice
  initialPractice,
  practiceDevelopment,
  practiceMaintenance,

  // Repair
  lowMastery,
  chronicWeakness,
  performanceDecline,

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

  final CandidateSource source;

  final CandidateReason reason;

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

  final TopicId topicId;

  final CandidateSource primarySource;

  final Set<CandidateSource> sources;

  final List<CandidateSignal> signals;

  final bool requiresBridge;

  final TopicId? bridgeTopicId;
}