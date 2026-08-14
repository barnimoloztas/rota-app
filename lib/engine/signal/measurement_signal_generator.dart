import '../../domain/measurement_signal.dart';
import '../../domain/student_learning_snapshot.dart';
import '../../domain/student_topic_state.dart';

class MeasurementSignalConfig {
  const MeasurementSignalConfig({
    required this.lowConfidenceThreshold,
    required this.staleEvidenceAfter,
    required this.insufficientEvidenceConfidenceThreshold,
  })  : assert(
          lowConfidenceThreshold >= 0.0 &&
              lowConfidenceThreshold <= 1.0,
        ),
        assert(
          insufficientEvidenceConfidenceThreshold >= 0.0 &&
              insufficientEvidenceConfidenceThreshold <= 1.0,
        );

  final double lowConfidenceThreshold;

  final Duration staleEvidenceAfter;

  final double insufficientEvidenceConfidenceThreshold;
}

List<MeasurementSignal> generateMeasurementSignals({
  required StudentLearningSnapshot snapshot,
  required DateTime now,
  required MeasurementSignalConfig config,
}) {
  final signals = <MeasurementSignal>[];

  for (final state in snapshot.topicStates.values) {
    signals.addAll(
      _signalsForTopic(
        state: state,
        now: now,
        config: config,
      ),
    );
  }

  return List.unmodifiable(signals);
}

List<MeasurementSignal> _signalsForTopic({
  required StudentTopicState state,
  required DateTime now,
  required MeasurementSignalConfig config,
}) {
  final signals = <MeasurementSignal>[];

  if (!state.hasEvidence) {
    return signals;
  }

  if (state.mastery.confidence <
      config.insufficientEvidenceConfidenceThreshold) {
    signals.add(
      MeasurementSignal(
        topicId: state.topicId,
        reason: MeasurementSignalReason.insufficientEvidence,
        strength: _inverseConfidence(state.mastery.confidence),
      ),
    );

    return signals;
  }

  if (state.mastery.confidence < config.lowConfidenceThreshold) {
    signals.add(
      MeasurementSignal(
        topicId: state.topicId,
        reason: MeasurementSignalReason.lowConfidence,
        strength: _inverseConfidence(state.mastery.confidence),
      ),
    );
  }

  final lastEvidenceAt = state.lastMeaningfulEvidenceAt;

  if (lastEvidenceAt != null) {
    final evidenceAge = now.difference(lastEvidenceAt);

    if (evidenceAge > config.staleEvidenceAfter) {
      signals.add(
        MeasurementSignal(
          topicId: state.topicId,
          reason: MeasurementSignalReason.staleEvidence,
          strength: _stalenessStrength(
            evidenceAge: evidenceAge,
            staleEvidenceAfter: config.staleEvidenceAfter,
          ),
        ),
      );
    }
  }

  return signals;
}

double _inverseConfidence(double confidence) {
  return (1.0 - confidence).clamp(0.0, 1.0);
}

double _stalenessStrength({
  required Duration evidenceAge,
  required Duration staleEvidenceAfter,
}) {
  final overdue =
      evidenceAge.inSeconds - staleEvidenceAfter.inSeconds;

  if (overdue <= 0) {
    return 0.0;
  }

  final denominator = staleEvidenceAfter.inSeconds;

  if (denominator <= 0) {
    return 1.0;
  }

  return (overdue / denominator).clamp(0.0, 1.0);
}