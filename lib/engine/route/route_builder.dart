import '../../domain/selected_mode.dart';
import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';
import '../practice/practice_question_target_policy.dart';

StudyRoute buildRoute({
  required List<StudyCandidate> candidates,
  required SelectedMode selectedMode,
}) {
  final tasks = <StudyTask>[];

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

    final taskType = _taskTypeForSource(candidate.primarySource);

    tasks.add(
      StudyTask(
        topicId: candidate.topicId,
        type: taskType,
        sourceTopicId: candidate.topicId,
        questionTarget: _questionTargetForTask(
          taskType: taskType,
          selectedMode: selectedMode,
        ),
      ),
    );
  }

  return StudyRoute(
    tasks: List.unmodifiable(tasks),
  );
}

int? _questionTargetForTask({
  required StudyTaskType taskType,
  required SelectedMode selectedMode,
}) {
  switch (taskType) {
    case StudyTaskType.practice:
      return practiceQuestionTargetForMode(selectedMode);

    case StudyTaskType.progress:
    case StudyTaskType.repair:
    case StudyTaskType.measurement:
    case StudyTaskType.bridge:
      return null;
  }
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

    case CandidateSource.measurement:
      return StudyTaskType.measurement;
  }
}