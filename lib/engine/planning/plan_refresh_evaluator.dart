import '../../domain/plan_task_state.dart';
import '../../domain/study_candidate.dart';
import '../../domain/study_route.dart';
import 'plan_task_invalidator.dart';

enum PlanRefreshDecision {
  keep,
  replace,
}

class PlanRefreshEvaluation {
  const PlanRefreshEvaluation({
    required this.task,
    required this.decision,
    required this.invalidation,
  });

  final PlanTaskState task;

  /// Whether refresh should keep or replace this task.
  final PlanRefreshDecision decision;

  /// Why the original study task is or is not still supported
  /// by the refreshed candidate state.
  final PlanTaskInvalidationResult invalidation;
}

PlanRefreshEvaluation evaluatePlanRefresh({
  required PlanTaskState task,
  required StudyTask studyTask,
  required Iterable<StudyCandidate> refreshedCandidates,
}) {
  final invalidation = evaluateTaskInvalidation(
    task: studyTask,
    refreshedCandidates: refreshedCandidates,
  );

  if (task.isProtectedFromRefresh) {
    return PlanRefreshEvaluation(
      task: task,
      decision: PlanRefreshDecision.keep,
      invalidation: invalidation,
    );
  }

  if (invalidation.isInvalidated) {
    return PlanRefreshEvaluation(
      task: task,
      decision: PlanRefreshDecision.replace,
      invalidation: invalidation,
    );
  }

  return PlanRefreshEvaluation(
    task: task,
    decision: PlanRefreshDecision.keep,
    invalidation: invalidation,
  );
}