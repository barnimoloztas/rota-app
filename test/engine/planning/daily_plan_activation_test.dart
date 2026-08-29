import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/engine/planning/daily_plan_activation.dart';

void main() {
  SubjectPlanTask plannedTask(String subjectId, String topicId) {
    return SubjectPlanTask(
      subjectId: subjectId,
      task: StudyTask(
        topicId: topicId,
        type: StudyTaskType.practice,
        sourceTopicId: topicId,
      ),
    );
  }

  DailyPlanDraft dailyPlan() {
    return DailyPlanDraft(
      protectedSubjectTasks: [plannedTask('mathematics', 'protected-math')],
      normalSubjectTasks: [plannedTask('physics', 'normal-physics')],
      reinforcement: null,
    );
  }

  group('activateDailyPlan', () {
    for (final draftLifecycle in [
      PlanLifecycle.draftUntouched,
      PlanLifecycle.draftStudentModified,
    ]) {
      test('activates $draftLifecycle and applies allocations', () {
        final result = activateDailyPlan(
          lifecycle: draftLifecycle,
          dailyPlan: dailyPlan(),
          planPhase: PreparationPhase.early,
          allocationPhase: PreparationPhase.early,
          allocatedSlotsBySubject: const {'mathematics': 2},
        );

        expect(result.lifecycle, PlanLifecycle.active);
        expect(result.didActivate, isTrue);
        expect(result.allocationPhase, PreparationPhase.early);
        expect(result.allocatedSlotsBySubject, {
          'mathematics': 3,
          'physics': 1,
        });
      });
    }

    test('does not apply allocations again after activation', () {
      final firstActivation = activateDailyPlan(
        lifecycle: PlanLifecycle.draftStudentModified,
        dailyPlan: dailyPlan(),
        planPhase: PreparationPhase.early,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {'mathematics': 2},
      );

      final repeatedActivation = activateDailyPlan(
        lifecycle: firstActivation.lifecycle,
        dailyPlan: dailyPlan(),
        planPhase: PreparationPhase.middle,
        allocationPhase: firstActivation.allocationPhase,
        allocatedSlotsBySubject: firstActivation.allocatedSlotsBySubject,
      );

      expect(repeatedActivation.lifecycle, PlanLifecycle.active);
      expect(repeatedActivation.didActivate, isFalse);
      expect(repeatedActivation.allocationPhase, PreparationPhase.early);
      expect(repeatedActivation.allocatedSlotsBySubject, {
        'mathematics': 3,
        'physics': 1,
      });
    });

    test('returns an immutable snapshot when already active', () {
      final existingAllocations = {'mathematics': 2};

      final result = activateDailyPlan(
        lifecycle: PlanLifecycle.active,
        dailyPlan: dailyPlan(),
        planPhase: PreparationPhase.middle,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: existingAllocations,
      );

      existingAllocations['mathematics'] = 3;

      expect(result.allocatedSlotsBySubject, {'mathematics': 2});
      expect(
        () => result.allocatedSlotsBySubject['mathematics'] = 4,
        throwsUnsupportedError,
      );
    });

    test('starts a new allocation balance when the phase advances', () {
      final result = activateDailyPlan(
        lifecycle: PlanLifecycle.draftUntouched,
        dailyPlan: dailyPlan(),
        planPhase: PreparationPhase.middle,
        allocationPhase: PreparationPhase.early,
        allocatedSlotsBySubject: const {'mathematics': 12},
      );

      expect(result.allocationPhase, PreparationPhase.middle);
      expect(result.allocatedSlotsBySubject, {'mathematics': 1, 'physics': 1});
    });

    test('rejects a backwards phase transition for a draft', () {
      expect(
        () => activateDailyPlan(
          lifecycle: PlanLifecycle.draftStudentModified,
          dailyPlan: dailyPlan(),
          planPhase: PreparationPhase.early,
          allocationPhase: PreparationPhase.middle,
          allocatedSlotsBySubject: const {'mathematics': 2},
        ),
        throwsArgumentError,
      );
    });
  });
}
