import '../../domain/plan_task_state.dart';

enum PlanRefreshDecision {
  keep,
  replace,
}

class PlanRefreshEvaluation {
  const PlanRefreshEvaluation({
    required this.task,
    required this.decision,
    required this.invalidatedByNewData,
  });

  final PlanTaskState task;

  /// Whether refresh should keep or replace this task.
  final PlanRefreshDecision decision;

  /// Whether new data made the original coach decision invalid.
  final bool invalidatedByNewData;
}

PlanRefreshEvaluation evaluatePlanRefresh({
  required PlanTaskState task,
  required bool invalidatedByNewData,
}) {
  if (task.isProtectedFromRefresh) {
    return PlanRefreshEvaluation(
      task: task,
      decision: PlanRefreshDecision.keep,
      invalidatedByNewData: invalidatedByNewData,
    );
  }

  if (invalidatedByNewData) {
    return PlanRefreshEvaluation(
      task: task,
      decision: PlanRefreshDecision.replace,
      invalidatedByNewData: true,
    );
  }

  return PlanRefreshEvaluation(
    task: task,
    decision: PlanRefreshDecision.keep,
    invalidatedByNewData: false,
  );
}