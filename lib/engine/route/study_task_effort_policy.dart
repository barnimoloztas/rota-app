import '../../domain/study_route.dart';
import '../../domain/study_task_effort.dart';

class StudyTaskEffortPolicyConfig {
  const StudyTaskEffortPolicyConfig({
    required this.minutesByTaskType,
  });

  /// Estimated planning duration for each task type.
  ///
  /// Values are calibration inputs and are intentionally
  /// not hard-coded into the policy.
  final Map<StudyTaskType, int> minutesByTaskType;
}

StudyTaskEffort? estimateTaskEffort({
  required StudyTask task,
  required StudyTaskEffortPolicyConfig config,
}) {
  final estimatedMinutes = config.minutesByTaskType[task.type];

  if (estimatedMinutes == null || estimatedMinutes < 0) {
    return null;
  }

  return StudyTaskEffort(
    topicId: task.topicId,
    taskType: task.type,
    estimatedMinutes: estimatedMinutes,
  );
}

List<StudyTaskEffort> estimateRouteEfforts({
  required StudyRoute route,
  required StudyTaskEffortPolicyConfig config,
}) {
  final efforts = <StudyTaskEffort>[];

  for (final task in route.tasks) {
    final effort = estimateTaskEffort(
      task: task,
      config: config,
    );

    if (effort != null) {
      efforts.add(effort);
    }
  }

  return List.unmodifiable(efforts);
}