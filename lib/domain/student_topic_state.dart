import 'mastery.dart';
import 'topic.dart';

class StudentTopicState {
  const StudentTopicState({
    required this.topicId,
    required this.hasEvidence,
    required this.mastery,
    required this.lastMeaningfulEvidenceAt,
    required this.calculatedAt,
  });

  /// Topic this state belongs to.
  final TopicId topicId;

  /// Whether the student has real academic evidence for this topic.
  ///
  /// Onboarding priors do not count as real evidence.
  ///
  /// false = untouched
  /// true  = touched
  final bool hasEvidence;

  /// Current mastery estimate for the topic.
  final Mastery mastery;

  /// Time of the most recent meaningful academic evidence.
  ///
  /// Null when [hasEvidence] is false.
  final DateTime? lastMeaningfulEvidenceAt;

  /// Time at which this derived state was calculated.
  final DateTime calculatedAt;
}