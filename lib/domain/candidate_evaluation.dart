import 'study_candidate.dart';
import 'topic.dart';

class CandidateEvaluation {
  const CandidateEvaluation({
    required this.topicId,
    required this.candidate,
    required this.signalStrength,
    required this.sourceCount,
    required this.hasBridge,
  });

  /// Topic being evaluated.
  final TopicId topicId;

  /// Original merged study candidate.
  final StudyCandidate candidate;

  /// Aggregated strength derived from candidate signals.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is not the final ranking score.
  final double signalStrength;

  /// Number of distinct candidate sources that contributed
  /// to this candidate.
  final int sourceCount;

  /// Whether the candidate requires bridge work.
  final bool hasBridge;
}