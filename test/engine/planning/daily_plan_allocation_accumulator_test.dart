import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/reinforcement_task.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_task.dart';
import 'package:rota_app/engine/planning/daily_plan_allocation_accumulator.dart';

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

  DailyReinforcementCandidate reinforcementCandidate(ReinforcementTask task) {
    return DailyReinforcementCandidate(
      id: 'reinforcement',
      dueAt: DateTime.utc(2026, 8, 28),
      currentImportance: 0.5,
      task: task,
    );
  }

  group('accumulateDailyPlanAllocations', () {
    test('adds protected and normal subject tasks to existing allocations', () {
      final existingAllocations = {'mathematics': 2, 'biology': 1};
      final dailyPlan = DailyPlanDraft(
        protectedSubjectTasks: [
          plannedTask('mathematics', 'protected-math'),
          plannedTask('physics', 'protected-physics'),
        ],
        normalSubjectTasks: [
          plannedTask('mathematics', 'normal-math'),
          plannedTask('chemistry', 'normal-chemistry'),
        ],
        reinforcement: null,
      );

      final updatedAllocations = accumulateDailyPlanAllocations(
        allocatedSlotsBySubject: existingAllocations,
        dailyPlan: dailyPlan,
      );

      expect(updatedAllocations, {
        'mathematics': 4,
        'biology': 1,
        'physics': 1,
        'chemistry': 1,
      });
      expect(existingAllocations, {'mathematics': 2, 'biology': 1});
    });

    test('adds one slot for subject reinforcement', () {
      final dailyPlan = DailyPlanDraft(
        normalSubjectTasks: const [],
        reinforcement: reinforcementCandidate(
          const SubjectReinforcementTask(
            subjectId: 'physics',
            type: SubjectReinforcementTaskType.branchReinforcement,
          ),
        ),
      );

      final updatedAllocations = accumulateDailyPlanAllocations(
        allocatedSlotsBySubject: const {'physics': 2},
        dailyPlan: dailyPlan,
      );

      expect(updatedAllocations, {'physics': 3});
    });

    test('does not assign shared TYT Social reinforcement to a subject', () {
      final dailyPlan = DailyPlanDraft(
        normalSubjectTasks: const [],
        reinforcement: reinforcementCandidate(
          const TytSocialReinforcementTask(),
        ),
      );

      final updatedAllocations = accumulateDailyPlanAllocations(
        allocatedSlotsBySubject: const {'mathematics': 1},
        dailyPlan: dailyPlan,
      );

      expect(updatedAllocations, {'mathematics': 1});
    });

    test('returns an unmodifiable allocation map', () {
      final updatedAllocations = accumulateDailyPlanAllocations(
        allocatedSlotsBySubject: const {},
        dailyPlan: const DailyPlanDraft(
          normalSubjectTasks: [],
          reinforcement: null,
        ),
      );

      expect(
        () => updatedAllocations['mathematics'] = 1,
        throwsUnsupportedError,
      );
    });

    test('rejects a negative existing allocation', () {
      expect(
        () => accumulateDailyPlanAllocations(
          allocatedSlotsBySubject: const {'mathematics': -1},
          dailyPlan: const DailyPlanDraft(
            normalSubjectTasks: [],
            reinforcement: null,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
