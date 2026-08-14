import '../../domain/plan_lifecycle.dart';
import '../../domain/plan_task_state.dart';
import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';
import 'plan_refresh_evaluator.dart';
import 'plan_refresh_selector.dart';
import 'plan_replacement_selector.dart';

class PlanRefreshInput {
  const PlanRefreshInput({
    required this.previousTasks,
    required this.previousTaskStates,
    required this.refreshedCandidates,
    required this.rankedRefreshedTasks,
    required this.lifecycle,
    required this.selectionConfig,
  });

  /// Tasks visible in the previous draft/plan.
  final List<StudyTask> previousTasks;

  /// Refresh ownership/touch metadata for the same previous tasks.
  ///
  /// Entries are matched to [previousTasks] by topicId.
  final List<PlanTaskState> previousTaskStates;

  /// Candidate state regenerated from the newest evidence.
  final List<StudyCandidate> refreshedCandidates;

  /// Refreshed tasks already ordered by the normal ranking pipeline.
  final List<StudyTask> rankedRefreshedTasks;

  final PlanLifecycle lifecycle;

  final PlanRefreshSelectionConfig selectionConfig;
}

List<StudyTask> refreshPlan(
  PlanRefreshInput input,
) {
  if (input.lifecycle == PlanLifecycle.active) {
    return List.unmodifiable(input.previousTasks);
  }

  final refreshedTasks = <StudyTask>[];
  final protectedTasks = <StudyTask>[];

  for (final previousTask in input.previousTasks) {
    final taskState = _findTaskState(
      topicId: previousTask.topicId,
      states: input.previousTaskStates,
    );

    if (taskState == null) {
      // Missing lifecycle metadata is not silently guessed.
      // Preserve the previous task rather than mutating student work
      // without enough information.
      refreshedTasks.add(previousTask);
      protectedTasks.add(previousTask);
      continue;
    }

    final evaluation = evaluatePlanRefresh(
      task: taskState,
      studyTask: previousTask,
      refreshedCandidates: input.refreshedCandidates,
    );

    if (evaluation.decision == PlanRefreshDecision.keep) {
      refreshedTasks.add(previousTask);

      if (taskState.isProtectedFromRefresh) {
        protectedTasks.add(previousTask);
      }

      continue;
    }

    final replacement = selectReplacementTask(
      taskToReplace: previousTask,
      rankedRefreshedTasks: input.rankedRefreshedTasks,
      protectedTasks: {
        ...protectedTasks,
        ...refreshedTasks,
      },
    );

    if (replacement != null) {
      refreshedTasks.add(replacement);
    }
  }

  final selectedStates = selectRefreshedPlanTasks(
    previousTasks: input.previousTaskStates,
    refreshedCandidates: refreshedTasks
        .map(
          (task) => _stateForRefreshedTask(
            task: task,
            previousStates: input.previousTaskStates,
          ),
        )
        .toList(growable: false),
    lifecycle: input.lifecycle,
    config: input.selectionConfig,
  );

  final allowedTopicIds = selectedStates
      .map((state) => state.topicId)
      .toList(growable: false);

  final selectedTasks = <StudyTask>[];

  for (final topicId in allowedTopicIds) {
    final task = _findTask(
      topicId: topicId,
      tasks: refreshedTasks,
    );

    if (task != null) {
      selectedTasks.add(task);
    }
  }

  return List.unmodifiable(selectedTasks);
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

StudyTask? _findTask({
  required String topicId,
  required Iterable<StudyTask> tasks,
}) {
  for (final task in tasks) {
    if (task.topicId == topicId) {
      return task;
    }
  }

  return null;
}

PlanTaskState _stateForRefreshedTask({
  required StudyTask task,
  required Iterable<PlanTaskState> previousStates,
}) {
  final existing = _findTaskState(
    topicId: task.topicId,
    states: previousStates,
  );

  if (existing != null) {
    return existing;
  }

  // A replacement introduced by refresh is a coach-created,
  // untouched task until the student interacts with it.
  return PlanTaskState(
    topicId: task.topicId,
    owner: PlanTaskOwner.coach,
    wasTouchedByStudent: false,
  );
}