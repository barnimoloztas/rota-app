import '../../domain/daily_plan_draft.dart';
import '../../domain/plan_lifecycle.dart';
import '../../domain/reinforcement_task.dart';
import '../../domain/subject_reinforcement_lifecycle.dart';
import '../../domain/subject_reinforcement_task.dart';
import '../../domain/tyt_social_reinforcement_lifecycle.dart';
import '../../domain/tyt_social_reinforcement_task.dart';
import '../reinforcement/subject_reinforcement_cadence.dart';
import '../reinforcement/subject_reinforcement_completion_lifecycle.dart';
import '../reinforcement/tyt_social_reinforcement_completion_lifecycle.dart';

class DailyPlanReinforcementCompletionResult<T> {
  const DailyPlanReinforcementCompletionResult._({
    required this.lifecycle,
    required this.didComplete,
    required this.reinforcementCompleted,
  });

  final T lifecycle;

  /// Whether this call completed the planned reinforcement for the first time.
  final bool didComplete;

  /// Completion state of the single reinforcement slot in the active plan.
  final bool reinforcementCompleted;
}

DailyPlanReinforcementCompletionResult<SubjectReinforcementLifecycle>
completeDailyPlanSubjectReinforcement({
  required PlanLifecycle planLifecycle,
  required DailyPlanDraft dailyPlan,
  required bool reinforcementCompleted,
  required SubjectReinforcementLifecycle reinforcementLifecycle,
  required DateTime completedAt,
}) {
  final reinforcementTask = _activeReinforcementTask(
    planLifecycle: planLifecycle,
    dailyPlan: dailyPlan,
  );
  if (reinforcementTask is! SubjectReinforcementTask) {
    throw StateError(
      'The active daily plan reinforcement is not subject-scoped.',
    );
  }
  if (reinforcementTask.subjectId != reinforcementLifecycle.subjectId) {
    throw ArgumentError.value(
      reinforcementLifecycle.subjectId,
      'reinforcementLifecycle',
      'must match the active daily plan reinforcement subject',
    );
  }

  if (reinforcementCompleted) {
    return DailyPlanReinforcementCompletionResult._(
      lifecycle: reinforcementLifecycle,
      didComplete: false,
      reinforcementCompleted: true,
    );
  }

  final cadence = subjectReinforcementCadenceFor(
    reinforcementLifecycle.subjectId,
  );
  final expectedTaskType =
      reinforcementLifecycle.completedInitialReinforcementCount <
          cadence.topicReinforcementCount
      ? SubjectReinforcementTaskType.topicReinforcement
      : SubjectReinforcementTaskType.branchReinforcement;
  if (reinforcementTask.type != expectedTaskType) {
    throw StateError(
      'The active daily plan reinforcement does not match its lifecycle phase.',
    );
  }

  return DailyPlanReinforcementCompletionResult._(
    lifecycle: completeSubjectReinforcement(
      lifecycle: reinforcementLifecycle,
      completedAt: completedAt,
    ),
    didComplete: true,
    reinforcementCompleted: true,
  );
}

DailyPlanReinforcementCompletionResult<TytSocialReinforcementLifecycle>
completeDailyPlanTytSocialReinforcement({
  required PlanLifecycle planLifecycle,
  required DailyPlanDraft dailyPlan,
  required bool reinforcementCompleted,
  required TytSocialReinforcementLifecycle reinforcementLifecycle,
  required DateTime completedAt,
}) {
  final reinforcementTask = _activeReinforcementTask(
    planLifecycle: planLifecycle,
    dailyPlan: dailyPlan,
  );
  if (reinforcementTask is! TytSocialReinforcementTask) {
    throw StateError(
      'The active daily plan reinforcement is not TYT Social-scoped.',
    );
  }

  if (reinforcementCompleted) {
    return DailyPlanReinforcementCompletionResult._(
      lifecycle: reinforcementLifecycle,
      didComplete: false,
      reinforcementCompleted: true,
    );
  }

  return DailyPlanReinforcementCompletionResult._(
    lifecycle: completeTytSocialReinforcement(
      lifecycle: reinforcementLifecycle,
      completedAt: completedAt,
    ),
    didComplete: true,
    reinforcementCompleted: true,
  );
}

ReinforcementTask _activeReinforcementTask({
  required PlanLifecycle planLifecycle,
  required DailyPlanDraft dailyPlan,
}) {
  if (planLifecycle != PlanLifecycle.active) {
    throw StateError('Only an active daily plan can be completed.');
  }

  final reinforcement = dailyPlan.reinforcement;
  if (reinforcement == null) {
    throw StateError('The active daily plan has no reinforcement task.');
  }

  return reinforcement.task;
}
