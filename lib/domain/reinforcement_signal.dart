import 'topic.dart';

enum ReinforcementSignalReason {
  masteryMaintenance,
}

class ReinforcementSignal {
  const ReinforcementSignal({
    required this.topicId,
    required this.reason,
    required this.strength,
  }) : assert(strength >= 0.0 && strength <= 1.0);

  /// Topic this reinforcement signal belongs to.
  final TopicId topicId;

  /// Why this topic may need reinforcement work.
  final ReinforcementSignalReason reason;

  /// Normalized strength of the reinforcement need.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is not a final candidate ranking score.
  final double strength;
}