import '../../domain/candidate_evaluation.dart';
import '../../domain/study_candidate.dart';
import '../../domain/topic_exam_profile.dart';

CandidateEvaluation aggregateCandidate(
  StudyCandidate candidate, {
  required Map<String, TopicExamProfile> examProfilesByTopicId,
}) {
  final examProfile = examProfilesByTopicId[candidate.topicId];

  return CandidateEvaluation(
    topicId: candidate.topicId,
    candidate: candidate,
    signalStrength: _aggregateSignalStrength(candidate.signals),
    sourceCount: candidate.sources.length,
    hasBridge: candidate.requiresBridge,
    examImportance: examProfile?.examImportance ?? 0.0,
  );
}

List<CandidateEvaluation> aggregateCandidates(
  Iterable<StudyCandidate> candidates, {
  required Map<String, TopicExamProfile> examProfilesByTopicId,
}) {
  return List.unmodifiable(
    candidates.map(
      (candidate) => aggregateCandidate(
        candidate,
        examProfilesByTopicId: examProfilesByTopicId,
      ),
    ),
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