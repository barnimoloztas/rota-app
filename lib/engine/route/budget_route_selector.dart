import '../../domain/daily_study_budget.dart';
import '../../domain/study_route.dart';
import '../../domain/study_task_effort.dart';

class BudgetRouteSelectionConfig {
  const BudgetRouteSelectionConfig({
    required this.maxTasks,
  }) : assert(maxTasks >= 0 && maxTasks <= 4);

  /// Absolute daily task ceiling.
  final int maxTasks;
}

StudyRoute selectRouteWithinBudget({
  required StudyRoute route,
  required DailyStudyBudget budget,
  required List<StudyTaskEffort> effortEstimates,
  required BudgetRouteSelectionConfig config,
}) {
  final selectedTasks = <StudyTask>[];
  var usedMinutes = 0;
  var index = 0;

  while (index < route.tasks.length) {
    final task = route.tasks[index];

    if (task.type == StudyTaskType.bridge) {
      final targetIndex = index + 1;

      if (targetIndex >= route.tasks.length) {
        index += 1;
        continue;
      }

      final targetTask = route.tasks[targetIndex];

      if (targetTask.topicId != task.sourceTopicId) {
        index += 1;
        continue;
      }

      final bridgeMinutes = _estimatedMinutesForTask(
        task: task,
        effortEstimates: effortEstimates,
      );

      final targetMinutes = _estimatedMinutesForTask(
        task: targetTask,
        effortEstimates: effortEstimates,
      );

      final pairMinutes = bridgeMinutes + targetMinutes;

      if (selectedTasks.length + 2 > config.maxTasks) {
        index += 2;
        continue;
      }

      if (usedMinutes + pairMinutes > budget.availableMinutes) {
        index += 2;
        continue;
      }

      selectedTasks
        ..add(task)
        ..add(targetTask);

      usedMinutes += pairMinutes;
      index += 2;
      continue;
    }

    final taskMinutes = _estimatedMinutesForTask(
      task: task,
      effortEstimates: effortEstimates,
    );

    if (selectedTasks.length + 1 > config.maxTasks) {
      break;
    }

    if (usedMinutes + taskMinutes > budget.availableMinutes) {
      index += 1;
      continue;
    }

    selectedTasks.add(task);
    usedMinutes += taskMinutes;
    index += 1;
  }

  return StudyRoute(
    tasks: List.unmodifiable(selectedTasks),
  );
}

int _estimatedMinutesForTask({
  required StudyTask task,
  required List<StudyTaskEffort> effortEstimates,
}) {
  for (final effort in effortEstimates) {
    if (effort.topicId == task.topicId &&
        effort.taskType == task.type) {
      return effort.estimatedMinutes;
    }
  }

  return 1 << 30;
}