import '../../domain/plan_lifecycle.dart';
import '../../domain/plan_task_state.dart';

class PlanRefreshSelectionConfig {
  const PlanRefreshSelectionConfig({
    required this.maxTasks,
  }) : assert(maxTasks >= 0 && maxTasks <= 4);

  /// Absolute daily task ceiling.
  final int maxTasks;
}

List<PlanTaskState> selectRefreshedPlanTasks({
  required List<PlanTaskState> previousTasks,
  required List<PlanTaskState> refreshedCandidates,
  required PlanLifecycle lifecycle,
  required PlanRefreshSelectionConfig config,
}) {
  switch (lifecycle) {
    case PlanLifecycle.active:
      // Active plans are outside the refresh lifecycle.
      // Refresh must leave the existing plan unchanged.
      return List.unmodifiable(previousTasks);

    case PlanLifecycle.draftStudentModified:
      // The student has consciously shaped tomorrow's workload.
      // Refresh may replace tasks, but it must not increase that workload.
      final allowedCount = _minimum(
        previousTasks.length,
        config.maxTasks,
      );

      return List.unmodifiable(
        refreshedCandidates.take(allowedCount),
      );

    case PlanLifecycle.draftUntouched:
      // The draft has not been accepted or modified by the student yet.
      // The engine may still re-optimize it, subject to the normal
      // absolute daily capacity ceiling.
      return List.unmodifiable(
        refreshedCandidates.take(config.maxTasks),
      );
  }
}

int _minimum(
  int a,
  int b,
) {
  return a < b ? a : b;
}