import '../../domain/candidate_evaluation.dart';
import '../../domain/study_candidate.dart';

CandidateEvaluation aggregateCandidate(
  StudyCandidate candidate,
) {
  return CandidateEvaluation(
    topicId: candidate.topicId,
    candidate: candidate,
    signalStrength: _aggregateSignalStrength(candidate.signals),
    sourceCount: candidate.sources.length,
    hasBridge: candidate.requiresBridge,
  );
}

List<CandidateEvaluation> aggregateCandidates(
  Iterable<StudyCandidate> candidates,
) {
  return List.unmodifiable(
    candidates.map(aggregateCandidate),
  );
}

double _aggregateSignalStrength(
  List<CandidateSignal> signals,
) {
  if (signals.isEmpty) {
    return 0.0;
  }

  var strongestSignal = 0.0;

  for (final signal in signals) {
    if (signal.strength > strongestSignal) {
      strongestSignal = signal.strength;
    }
  }

  return strongestSignal;
}