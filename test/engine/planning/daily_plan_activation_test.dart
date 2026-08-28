import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
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
          allocatedSlotsBySubject: const {'mathematics': 2},
        );

        expect(result.lifecycle, PlanLifecycle.active);
        expect(result.didActivate, isTrue);
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
        allocatedSlotsBySubject: const {'mathematics': 2},
      );

      final repeatedActivation = activateDailyPlan(
        lifecycle: firstActivation.lifecycle,
        dailyPlan: dailyPlan(),
        allocatedSlotsBySubject: firstActivation.allocatedSlotsBySubject,
      );

      expect(repeatedActivation.lifecycle, PlanLifecycle.active);
      expect(repeatedActivation.didActivate, isFalse);
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
        allocatedSlotsBySubject: existingAllocations,
      );

      existingAllocations['mathematics'] = 3;

      expect(result.allocatedSlotsBySubject, {'mathematics': 2});
      expect(
        () => result.allocatedSlotsBySubject['mathematics'] = 4,
        throwsUnsupportedError,
      );
    });
  });
}
