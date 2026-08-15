import '../../domain/practice_signal.dart';
import '../../domain/study_candidate.dart';

StudyCandidate generatePracticeCandidate({
  required PracticeSignal signal,
}) {
  return StudyCandidate(
    topicId: signal.topicId,
    primarySource: CandidateSource.practice,
    sources: const {
      CandidateSource.practice,
    },
    requiresBridge: false,
    bridgeTopicId: null,
    signals: [
      CandidateSignal(
        source: CandidateSource.practice,
        reason: _mapPracticeReason(signal.reason),
        strength: signal.strength,
      ),
    ],
  );
}

CandidateReason _mapPracticeReason(
  PracticeSignalReason reason,
) {
  switch (reason) {
    case PracticeSignalReason.initialPractice:
      return CandidateReason.initialPractice;

    case PracticeSignalReason.practiceDevelopment:
      return CandidateReason.practiceDevelopment;

    case PracticeSignalReason.practiceMaintenance:
      return CandidateReason.practiceMaintenance;
  }
}