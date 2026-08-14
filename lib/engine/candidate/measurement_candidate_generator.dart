import '../../domain/measurement_signal.dart';
import '../../domain/study_candidate.dart';

StudyCandidate generateMeasurementCandidate({
  required MeasurementSignal signal,
}) {
  return StudyCandidate(
    topicId: signal.topicId,
    primarySource: CandidateSource.measurement,
    sources: const {
      CandidateSource.measurement,
    },
    requiresBridge: false,
    bridgeTopicId: null,
    signals: [
      CandidateSignal(
        source: CandidateSource.measurement,
        reason: _mapMeasurementReason(signal.reason),
        strength: signal.strength,
      ),
    ],
  );
}

CandidateReason _mapMeasurementReason(
  MeasurementSignalReason reason,
) {
  switch (reason) {
    case MeasurementSignalReason.lowConfidence:
      return CandidateReason.lowConfidence;

    case MeasurementSignalReason.staleEvidence:
      return CandidateReason.staleEvidence;

    case MeasurementSignalReason.insufficientEvidence:
      return CandidateReason.insufficientEvidence;
  }
}