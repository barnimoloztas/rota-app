import 'topic.dart';

enum PracticeSignalReason {
  initialPractice,
  practiceDevelopment,
  practiceMaintenance,
}

class PracticeSignal {
  const PracticeSignal({
    required this.topicId,
    required this.reason,
    required this.strength,
  }) : assert(strength >= 0.0 && strength <= 1.0);

  /// Topic this practice signal belongs to.
  final TopicId topicId;

  /// Why this topic may need practice work.
  final PracticeSignalReason reason;

  /// Normalized strength of the practice need.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is not a final candidate ranking score.
  final double strength;
}