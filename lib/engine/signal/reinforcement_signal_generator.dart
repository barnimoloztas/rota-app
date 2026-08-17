import '../../domain/reinforcement_signal.dart';
import '../../domain/topic_learning_lifecycle.dart';
import '../reinforcement/topic_reinforcement_policy.dart';

List<ReinforcementSignal> generateReinforcementSignals({
  required Iterable<TopicLearningLifecycle> lifecycles,
  required DateTime evaluatedAt,
}) {
  final signals = <ReinforcementSignal>[];

  for (final lifecycle in lifecycles) {
    final evaluation = evaluateTopicReinforcement(
      lifecycle: lifecycle,
      evaluatedAt: evaluatedAt,
    );

    if (!evaluation.isDue) {
      continue;
    }

    signals.add(
      ReinforcementSignal(
        topicId: lifecycle.topicId,
        reason: ReinforcementSignalReason.masteryMaintenance,
        strength: 0.0,
      ),
    );
  }

  return List.unmodifiable(signals);
}