import '../../domain/daily_plan_draft.dart';
import '../../domain/plan_lifecycle.dart';
import '../../domain/preparation_phase.dart';
import '../../domain/subject.dart';
import 'daily_plan_allocation_accumulator.dart';

class DailyPlanActivationResult {
  DailyPlanActivationResult._({
    required this.lifecycle,
    required this.didActivate,
    required this.allocationPhase,
    required Map<SubjectId, int> allocatedSlotsBySubject,
  }) : allocatedSlotsBySubject = Map<SubjectId, int>.unmodifiable(
         Map<SubjectId, int>.of(allocatedSlotsBySubject),
       );

  final PlanLifecycle lifecycle;

  /// Whether this call performed the draft-to-active transition.
  final bool didActivate;

  final PreparationPhase allocationPhase;

  final Map<SubjectId, int> allocatedSlotsBySubject;
}

DailyPlanActivationResult activateDailyPlan({
  required PlanLifecycle lifecycle,
  required DailyPlanDraft dailyPlan,
  required PreparationPhase planPhase,
  required PreparationPhase allocationPhase,
  required Map<SubjectId, int> allocatedSlotsBySubject,
}) {
  switch (lifecycle) {
    case PlanLifecycle.draftUntouched:
    case PlanLifecycle.draftStudentModified:
      if (planPhase.index < allocationPhase.index) {
        throw ArgumentError.value(
          planPhase,
          'planPhase',
          'Preparation phase cannot move backwards.',
        );
      }

      final startingAllocations = planPhase == allocationPhase
          ? allocatedSlotsBySubject
          : const <SubjectId, int>{};

      return DailyPlanActivationResult._(
        lifecycle: PlanLifecycle.active,
        didActivate: true,
        allocationPhase: planPhase,
        allocatedSlotsBySubject: accumulateDailyPlanAllocations(
          allocatedSlotsBySubject: startingAllocations,
          dailyPlan: dailyPlan,
        ),
      );

    case PlanLifecycle.active:
      return DailyPlanActivationResult._(
        lifecycle: PlanLifecycle.active,
        didActivate: false,
        allocationPhase: allocationPhase,
        allocatedSlotsBySubject: allocatedSlotsBySubject,
      );
  }
}
