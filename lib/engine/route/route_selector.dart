import '../../domain/study_route.dart';

class RouteSelectionConfig {
  const RouteSelectionConfig({
    required this.maxTasks,
  }) : assert(maxTasks >= 0 && maxTasks <= 4);

  /// Maximum number of visible tasks allowed for this route.
  ///
  /// ROTA v0.2 has an absolute daily ceiling of 4 tasks.
  final int maxTasks;
}

StudyRoute selectRouteTasks({
  required StudyRoute route,
  required RouteSelectionConfig config,
}) {
  final selectedTasks = <StudyTask>[];

  var index = 0;

  while (index < route.tasks.length) {
    final task = route.tasks[index];

    if (task.type == StudyTaskType.bridge) {
      final targetIndex = index + 1;

      // A bridge must never consume a slot without its target task.
      if (targetIndex >= route.tasks.length) {
        break;
      }

      final targetTask = route.tasks[targetIndex];

      final isMatchingTarget =
          targetTask.topicId == task.sourceTopicId;

      if (!isMatchingTarget) {
        break;
      }

      // Bridge + target must fit together.
      if (selectedTasks.length + 2 > config.maxTasks) {
        break;
      }

      selectedTasks
        ..add(task)
        ..add(targetTask);

      index += 2;
      continue;
    }

    if (selectedTasks.length + 1 > config.maxTasks) {
      break;
    }

    selectedTasks.add(task);
    index += 1;
  }

  return StudyRoute(
    tasks: List.unmodifiable(selectedTasks),
  );
}