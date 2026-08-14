import '../../domain/reinforcement_signal.dart';
import '../../domain/study_candidate.dart';

StudyCandidate generateReinforcementCandidate({
  required ReinforcementSignal signal,
}) {
  return StudyCandidate(
    topicId: signal.topicId,
    primarySource: CandidateSource.reinforcement,
    sources: const {
      CandidateSource.reinforcement,
    },
    requiresBridge: false,
    bridgeTopicId: null,
    signals: [
      CandidateSignal(
        source: CandidateSource.reinforcement,
        reason: _mapReinforcementReason(signal.reason),
        strength: signal.strength,
      ),
    ],
  );
}

CandidateReason _mapReinforcementReason(
  ReinforcementSignalReason reason,
) {
  switch (reason) {
    case ReinforcementSignalReason.needsPractice:
      return CandidateReason.needsPractice;

    case ReinforcementSignalReason.masteryMaintenance:
      return CandidateReason.masteryMaintenance;
  }
}