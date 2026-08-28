import '../../domain/daily_plan_draft.dart';
import '../../domain/plan_lifecycle.dart';
import '../../domain/subject.dart';
import 'daily_plan_allocation_accumulator.dart';

class DailyPlanActivationResult {
  DailyPlanActivationResult._({
    required this.lifecycle,
    required this.didActivate,
    required Map<SubjectId, int> allocatedSlotsBySubject,
  }) : allocatedSlotsBySubject = Map<SubjectId, int>.unmodifiable(
         Map<SubjectId, int>.of(allocatedSlotsBySubject),
       );

  final PlanLifecycle lifecycle;

  /// Whether this call performed the draft-to-active transition.
  final bool didActivate;

  final Map<SubjectId, int> allocatedSlotsBySubject;
}

DailyPlanActivationResult activateDailyPlan({
  required PlanLifecycle lifecycle,
  required DailyPlanDraft dailyPlan,
  required Map<SubjectId, int> allocatedSlotsBySubject,
}) {
  switch (lifecycle) {
    case PlanLifecycle.draftUntouched:
    case PlanLifecycle.draftStudentModified:
      return DailyPlanActivationResult._(
        lifecycle: PlanLifecycle.active,
        didActivate: true,
        allocatedSlotsBySubject: accumulateDailyPlanAllocations(
          allocatedSlotsBySubject: allocatedSlotsBySubject,
          dailyPlan: dailyPlan,
        ),
      );

    case PlanLifecycle.active:
      return DailyPlanActivationResult._(
        lifecycle: PlanLifecycle.active,
        didActivate: false,
        allocatedSlotsBySubject: allocatedSlotsBySubject,
      );
  }
}
