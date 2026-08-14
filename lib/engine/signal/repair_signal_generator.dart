import '../../domain/repair_signal.dart';
import '../../domain/student_learning_snapshot.dart';
import '../../domain/student_topic_state.dart';
import '../../domain/mastery_band.dart';

class RepairSignalConfig {
  const RepairSignalConfig({
    required this.lowMasteryStrengthByBand,
  });

  /// Strength assigned to each mastery band when generating
  /// a low-mastery repair signal.
  ///
  /// Only bands present in this map are eligible for automatic
  /// low-mastery repair generation.
  final Map<MasteryBand, double> lowMasteryStrengthByBand;
}

List<RepairSignal> generateRepairSignals({
  required StudentLearningSnapshot snapshot,
  required RepairSignalConfig config,
}) {
  final signals = <RepairSignal>[];

  for (final state in snapshot.topicStates.values) {
    final signal = _lowMasterySignalForTopic(
      state: state,
      config: config,
    );

    if (signal != null) {
      signals.add(signal);
    }
  }

  return List.unmodifiable(signals);
}

RepairSignal? _lowMasterySignalForTopic({
  required StudentTopicState state,
  required RepairSignalConfig config,
}) {
  if (!state.hasEvidence) {
    return null;
  }

  final strength = config.lowMasteryStrengthByBand[state.masteryBand];

  if (strength == null) {
    return null;
  }

  assert(strength >= 0.0 && strength <= 1.0);

  return RepairSignal(
    topicId: state.topicId,
    reason: RepairSignalReason.lowMastery,
    strength: strength,
  );
}