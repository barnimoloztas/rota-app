import '../../domain/mastery_band.dart';
import '../../domain/reinforcement_signal.dart';
import '../../domain/student_learning_snapshot.dart';
import '../../domain/student_topic_state.dart';

class ReinforcementSignalConfig {
  const ReinforcementSignalConfig({
    required this.strengthByBand,
  });

  /// Strength assigned to mastery bands that are eligible
  /// for reinforcement.
  ///
  /// Bands not present in this map do not automatically
  /// produce reinforcement signals.
  final Map<MasteryBand, double> strengthByBand;
}

List<ReinforcementSignal> generateReinforcementSignals({
  required StudentLearningSnapshot snapshot,
  required ReinforcementSignalConfig config,
}) {
  final signals = <ReinforcementSignal>[];

  for (final state in snapshot.topicStates.values) {
    final signal = _masteryMaintenanceSignalForTopic(
      state: state,
      config: config,
    );

    if (signal != null) {
      signals.add(signal);
    }
  }

  return List.unmodifiable(signals);
}

ReinforcementSignal? _masteryMaintenanceSignalForTopic({
  required StudentTopicState state,
  required ReinforcementSignalConfig config,
}) {
  if (!state.hasEvidence) {
    return null;
  }

  final strength = config.strengthByBand[state.masteryBand];

  if (strength == null) {
    return null;
  }

  assert(strength >= 0.0 && strength <= 1.0);

  return ReinforcementSignal(
    topicId: state.topicId,
    reason: ReinforcementSignalReason.masteryMaintenance,
    strength: strength,
  );
}