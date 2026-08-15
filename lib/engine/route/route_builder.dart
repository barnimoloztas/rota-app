import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';

StudyRoute buildRoute({
  required List<StudyCandidate> candidates,
}) {
  final tasks = <StudyTask>[];

  // Aynı prerequisite bridge birden fazla hedef tarafından istenirse
  // yalnızca bir kez görünür task üretmek için kullanılır.
  final addedBridgeTopicIds = <String>{};

  for (final candidate in candidates) {
    final bridgeTopicId = candidate.bridgeTopicId;

    if (candidate.requiresBridge && bridgeTopicId != null) {
      if (addedBridgeTopicIds.add(bridgeTopicId)) {
        tasks.add(
          StudyTask(
            topicId: bridgeTopicId,
            type: StudyTaskType.bridge,
            sourceTopicId: candidate.topicId,
          ),
        );
      }
    }

    tasks.add(
      StudyTask(
        topicId: candidate.topicId,
        type: _taskTypeForSource(candidate.primarySource),
        sourceTopicId: candidate.topicId,
      ),
    );
  }

  return StudyRoute(
    tasks: List.unmodifiable(tasks),
  );
}

StudyTaskType _taskTypeForSource(
  CandidateSource source,
) {
  switch (source) {
    case CandidateSource.progress:
      return StudyTaskType.progress;

    case CandidateSource.practice:
      return StudyTaskType.practice;

    case CandidateSource.repair:
      return StudyTaskType.repair;

    case CandidateSource.reinforcement:
      return StudyTaskType.reinforcement;

    case CandidateSource.measurement:
      return StudyTaskType.measurement;
  }
}