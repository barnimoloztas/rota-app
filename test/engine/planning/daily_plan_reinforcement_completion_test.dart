import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/reinforcement_task.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_task.dart';
import 'package:rota_app/engine/planning/daily_plan_reinforcement_completion.dart';

void main() {
  DailyPlanDraft dailyPlan(ReinforcementTask? task) {
    return DailyPlanDraft(
      normalSubjectTasks: const [],
      reinforcement: task == null
          ? null
          : DailyReinforcementCandidate(
              id: 'reinforcement',
              dueAt: DateTime.utc(2026, 8, 15),
              currentImportance: 0.5,
              task: task,
            ),
    );
  }

  SubjectReinforcementLifecycle subjectLifecycle({
    String subjectId = 'mathematics',
    int completedInitialCount = 0,
    DateTime? lastCompletedAt,
  }) {
    return SubjectReinforcementLifecycle(
      subjectId: subjectId,
      startedAt: DateTime.utc(2026, 8, 1),
      completedInitialReinforcementCount: completedInitialCount,
      lastReinforcementCompletedAt: lastCompletedAt,
    );
  }

  group('daily plan reinforcement completion', () {
    test('completes an active subject reinforcement', () {
      final completedAt = DateTime.utc(2026, 8, 15);
      final result = completeDailyPlanSubjectReinforcement(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: dailyPlan(
          const SubjectReinforcementTask(
            subjectId: 'mathematics',
            type: SubjectReinforcementTaskType.topicReinforcement,
          ),
        ),
        reinforcementCompleted: false,
        reinforcementLifecycle: subjectLifecycle(),
        completedAt: completedAt,
      );

      expect(result.didComplete, isTrue);
      expect(result.reinforcementCompleted, isTrue);
      expect(result.lifecycle.completedInitialReinforcementCount, 1);
      expect(result.lifecycle.lastReinforcementCompletedAt, completedAt);
    });

    test('does not complete the same subject reinforcement twice', () {
      final firstCompletedAt = DateTime.utc(2026, 8, 15);
      final plan = dailyPlan(
        const SubjectReinforcementTask(
          subjectId: 'mathematics',
          type: SubjectReinforcementTaskType.topicReinforcement,
        ),
      );
      final firstCompletion = completeDailyPlanSubjectReinforcement(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        reinforcementCompleted: false,
        reinforcementLifecycle: subjectLifecycle(
          completedInitialCount: 2,
          lastCompletedAt: DateTime.utc(2026, 8, 8),
        ),
        completedAt: firstCompletedAt,
      );

      final repeatedCompletion = completeDailyPlanSubjectReinforcement(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        reinforcementCompleted: firstCompletion.reinforcementCompleted,
        reinforcementLifecycle: firstCompletion.lifecycle,
        completedAt: DateTime.utc(2026, 8, 16),
      );

      expect(repeatedCompletion.didComplete, isFalse);
      expect(repeatedCompletion.reinforcementCompleted, isTrue);
      expect(repeatedCompletion.lifecycle, same(firstCompletion.lifecycle));
      expect(
        repeatedCompletion.lifecycle.completedInitialReinforcementCount,
        3,
      );
      expect(
        repeatedCompletion.lifecycle.lastReinforcementCompletedAt,
        firstCompletedAt,
      );
    });

    test('completes shared TYT Social reinforcement only once', () {
      final firstCompletedAt = DateTime.utc(2026, 9, 15);
      final plan = DailyPlanDraft(
        normalSubjectTasks: const [],
        reinforcement: DailyReinforcementCandidate(
          id: 'scope:tyt-social',
          dueAt: firstCompletedAt,
          currentImportance: 0.5,
          task: const TytSocialReinforcementTask(),
        ),
      );
      final firstCompletion = completeDailyPlanTytSocialReinforcement(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        reinforcementCompleted: false,
        reinforcementLifecycle: TytSocialReinforcementLifecycle(
          startedAt: DateTime.utc(2026, 8, 1),
          lastReinforcementCompletedAt: null,
        ),
        completedAt: firstCompletedAt,
      );

      final repeatedCompletion = completeDailyPlanTytSocialReinforcement(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        reinforcementCompleted: firstCompletion.reinforcementCompleted,
        reinforcementLifecycle: firstCompletion.lifecycle,
        completedAt: DateTime.utc(2026, 9, 16),
      );

      expect(firstCompletion.didComplete, isTrue);
      expect(
        firstCompletion.lifecycle.lastReinforcementCompletedAt,
        firstCompletedAt,
      );
      expect(repeatedCompletion.didComplete, isFalse);
      expect(repeatedCompletion.lifecycle, same(firstCompletion.lifecycle));
      expect(
        repeatedCompletion.lifecycle.lastReinforcementCompletedAt,
        firstCompletedAt,
      );
    });

    test('rejects completion before the plan is active', () {
      expect(
        () => completeDailyPlanSubjectReinforcement(
          planLifecycle: PlanLifecycle.draftStudentModified,
          dailyPlan: dailyPlan(
            const SubjectReinforcementTask(
              subjectId: 'mathematics',
              type: SubjectReinforcementTaskType.topicReinforcement,
            ),
          ),
          reinforcementCompleted: false,
          reinforcementLifecycle: subjectLifecycle(),
          completedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsStateError,
      );
    });

    test('rejects a plan without reinforcement', () {
      expect(
        () => completeDailyPlanSubjectReinforcement(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(null),
          reinforcementCompleted: false,
          reinforcementLifecycle: subjectLifecycle(),
          completedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsStateError,
      );
    });

    test('rejects the wrong reinforcement variant', () {
      expect(
        () => completeDailyPlanSubjectReinforcement(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(const TytSocialReinforcementTask()),
          reinforcementCompleted: false,
          reinforcementLifecycle: subjectLifecycle(),
          completedAt: DateTime.utc(2026, 9, 15),
        ),
        throwsStateError,
      );
      expect(
        () => completeDailyPlanTytSocialReinforcement(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(
            const SubjectReinforcementTask(
              subjectId: 'mathematics',
              type: SubjectReinforcementTaskType.topicReinforcement,
            ),
          ),
          reinforcementCompleted: false,
          reinforcementLifecycle: TytSocialReinforcementLifecycle(
            startedAt: DateTime.utc(2026, 8, 1),
            lastReinforcementCompletedAt: null,
          ),
          completedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsStateError,
      );
    });

    test('rejects a subject lifecycle for a different subject', () {
      expect(
        () => completeDailyPlanSubjectReinforcement(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(
            const SubjectReinforcementTask(
              subjectId: 'mathematics',
              type: SubjectReinforcementTaskType.topicReinforcement,
            ),
          ),
          reinforcementCompleted: false,
          reinforcementLifecycle: subjectLifecycle(subjectId: 'physics'),
          completedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a task type outside the subject lifecycle phase', () {
      expect(
        () => completeDailyPlanSubjectReinforcement(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(
            const SubjectReinforcementTask(
              subjectId: 'mathematics',
              type: SubjectReinforcementTaskType.branchReinforcement,
            ),
          ),
          reinforcementCompleted: false,
          reinforcementLifecycle: subjectLifecycle(),
          completedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsStateError,
      );
    });
  });
}
