import 'topic.dart';

enum MeasurementSignalReason {
  lowConfidence,
  staleEvidence,
  insufficientEvidence,
}

class MeasurementSignal {
  const MeasurementSignal({
    required this.topicId,
    required this.reason,
    required this.strength,
  }) : assert(strength >= 0.0 && strength <= 1.0);

  /// Topic whose current state needs better measurement.
  final TopicId topicId;

  /// Why the engine needs additional measurement.
  final MeasurementSignalReason reason;

  /// Normalized strength of the measurement need.
  ///
  /// Range: 0.0 - 1.0
  ///
  /// This is not mastery and not a final ranking score.
  final double strength;
}