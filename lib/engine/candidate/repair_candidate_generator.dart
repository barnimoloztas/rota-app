import '../../domain/repair_signal.dart';
import '../../domain/study_candidate.dart';

StudyCandidate generateRepairCandidate({
  required RepairSignal signal,
}) {
  return StudyCandidate(
    topicId: signal.topicId,
    primarySource: CandidateSource.repair,
    sources: const {
      CandidateSource.repair,
    },
    requiresBridge: false,
    bridgeTopicId: null,
    signals: [
      CandidateSignal(
        source: CandidateSource.repair,
        reason: _mapRepairReason(signal.reason),
        strength: signal.strength,
      ),
    ],
  );
}

CandidateReason _mapRepairReason(
  RepairSignalReason reason,
) {
  switch (reason) {
    case RepairSignalReason.lowMastery:
      return CandidateReason.lowMastery;

    case RepairSignalReason.chronicWeakness:
      return CandidateReason.chronicWeakness;

    case RepairSignalReason.performanceDecline:
      return CandidateReason.performanceDecline;
  }
}