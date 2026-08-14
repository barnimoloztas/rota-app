import '../../domain/daily_study_budget.dart';
import '../../domain/plan_task_state.dart';
import '../../domain/study_route.dart';
import '../../domain/study_task_effort.dart';

class PlanRefreshBudgetResult {
  const PlanRefreshBudgetResult({
    required this.tasks,
    required this.totalEstimatedMinutes,
    required this.exceedsBudget,
  });

  final List<StudyTask> tasks;
  final int totalEstimatedMinutes;

  /// True when protected tasks alone already exceed the student's budget.
  ///
  /// In that case the engine must preserve the protected tasks and surface
  /// the overload instead of silently removing student choices.
  final bool exceedsBudget;
}

PlanRefreshBudgetResult applyRefreshBudgetPolicy({
  required List<StudyTask> refreshedTasks,
  required List<PlanTaskState> taskStates,
  required DailyStudyBudget budget,
  required List<StudyTaskEffort> effortEstimates,
}) {
  final selectedTasks = <StudyTask>[];
  var usedMinutes = 0;
  var protectedOverload = false;

  for (final task in refreshedTasks) {
    final state = _findTaskState(
      topicId: task.topicId,
      states: taskStates,
    );

    final minutes = _estimatedMinutesForTask(
      task: task,
      effortEstimates: effortEstimates,
    );

    final isProtected = state?.isProtectedFromRefresh ?? true;

    if (isProtected) {
      selectedTasks.add(task);
      usedMinutes += minutes;

      if (usedMinutes > budget.availableMinutes) {
        protectedOverload = true;
      }

      continue;
    }

    if (usedMinutes + minutes <= budget.availableMinutes) {
      selectedTasks.add(task);
      usedMinutes += minutes;
    }
  }

  return PlanRefreshBudgetResult(
    tasks: List.unmodifiable(selectedTasks),
    totalEstimatedMinutes: usedMinutes,
    exceedsBudget: protectedOverload,
  );
}

PlanTaskState? _findTaskState({
  required String topicId,
  required Iterable<PlanTaskState> states,
}) {
  for (final state in states) {
    if (state.topicId == topicId) {
      return state;
    }
  }

  return null;
}

int _estimatedMinutesForTask({
  required StudyTask task,
  required Iterable<StudyTaskEffort> effortEstimates,
}) {
  for (final effort in effortEstimates) {
    if (effort.topicId == task.topicId &&
        effort.taskType == task.type) {
      return effort.estimatedMinutes;
    }
  }

  // Missing effort data must not be interpreted as free.
  return 1 << 30;
}