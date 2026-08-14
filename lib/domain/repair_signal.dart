import 'topic.dart';

enum RepairSignalReason {
  lowMastery,
  chronicWeakness,
  performanceDecline,
}

class RepairSignal {
  const RepairSignal({
    required this.topicId,
    required this.reason,
    required this.strength,
  }) : assert(strength >= 0.0 && strength <= 1.0);

  /// Topic this repair signal belongs to.
  final TopicId topicId;

  /// Why this topic may need repair work.
  final RepairSignalReason reason;

  /// Normalized strength of the signal.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is not a mastery score and not a final ranking score.
  final double strength;
}