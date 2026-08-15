import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';

class PlanTaskInvalidationResult {
  const PlanTaskInvalidationResult({
    required this.isInvalidated,
    required this.reason,
  });

  final bool isInvalidated;
  final PlanTaskInvalidationReason reason;
}

enum PlanTaskInvalidationReason {
  stillSupported,
  candidateNoLongerExists,
  sourceNoLongerSupportsTask,
  bridgeNoLongerRequired,
  bridgeChanged,
}

PlanTaskInvalidationResult evaluateTaskInvalidation({
  required StudyTask task,
  required Iterable<StudyCandidate> refreshedCandidates,
}) {
  final candidate = _findCandidateForTask(
    task: task,
    candidates: refreshedCandidates,
  );

  if (candidate == null) {
    return const PlanTaskInvalidationResult(
      isInvalidated: true,
      reason: PlanTaskInvalidationReason.candidateNoLongerExists,
    );
  }

  if (task.type == StudyTaskType.bridge) {
    if (!candidate.requiresBridge) {
      return const PlanTaskInvalidationResult(
        isInvalidated: true,
        reason: PlanTaskInvalidationReason.bridgeNoLongerRequired,
      );
    }

    if (candidate.bridgeTopicId != task.topicId) {
      return const PlanTaskInvalidationResult(
        isInvalidated: true,
        reason: PlanTaskInvalidationReason.bridgeChanged,
      );
    }

    return const PlanTaskInvalidationResult(
      isInvalidated: false,
      reason: PlanTaskInvalidationReason.stillSupported,
    );
  }

  final requiredSource = _candidateSourceForTaskType(task.type);

  if (requiredSource == null ||
      !candidate.sources.contains(requiredSource)) {
    return const PlanTaskInvalidationResult(
      isInvalidated: true,
      reason: PlanTaskInvalidationReason.sourceNoLongerSupportsTask,
    );
  }

  return const PlanTaskInvalidationResult(
    isInvalidated: false,
    reason: PlanTaskInvalidationReason.stillSupported,
  );
}

StudyCandidate? _findCandidateForTask({
  required StudyTask task,
  required Iterable<StudyCandidate> candidates,
}) {
  final candidateTopicId = task.type == StudyTaskType.bridge
      ? task.sourceTopicId
      : task.topicId;

  for (final candidate in candidates) {
    if (candidate.topicId == candidateTopicId) {
      return candidate;
    }
  }

  return null;
}

CandidateSource? _candidateSourceForTaskType(
  StudyTaskType type,
) {
  switch (type) {
    case StudyTaskType.progress:
      return CandidateSource.progress;

    case StudyTaskType.practice:
      return CandidateSource.practice;

    case StudyTaskType.repair:
      return CandidateSource.repair;

    case StudyTaskType.reinforcement:
      return CandidateSource.reinforcement;

    case StudyTaskType.measurement:
      return CandidateSource.measurement;

    case StudyTaskType.bridge:
      return null;
  }
}