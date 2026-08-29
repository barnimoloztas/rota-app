import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/planning/daily_plan_practice_completion.dart';

void main() {
  SubjectPlanTask plannedTask({
    required String topicId,
    required StudyTaskType type,
  }) {
    return SubjectPlanTask(
      subjectId: 'mathematics',
      task: StudyTask(topicId: topicId, type: type, sourceTopicId: topicId),
    );
  }

  DailyPlanDraft dailyPlan({
    List<SubjectPlanTask> protectedTasks = const [],
    List<SubjectPlanTask>? normalTasks,
  }) {
    return DailyPlanDraft(
      protectedSubjectTasks: protectedTasks,
      normalSubjectTasks:
          normalTasks ??
          [plannedTask(topicId: 'functions', type: StudyTaskType.practice)],
      reinforcement: null,
    );
  }

  TopicLearningLifecycle lifecycle(String topicId) {
    return TopicLearningLifecycle(
      topicId: topicId,
      progressCompletedAt: DateTime.utc(2026, 8, 28),
      completedInitialPracticeCount: 0,
      firstPracticeCompletedAt: null,
      lastPracticeCompletedAt: null,
    );
  }

  group('completeDailyPlanPractice', () {
    test('completes an active Practice and records its plan position', () {
      final completedAt = DateTime.utc(2026, 8, 29);
      final existingCompletedIndexes = <int>{};

      final result = completeDailyPlanPractice(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: dailyPlan(),
        academicTaskIndex: 0,
        completedAcademicTaskIndexes: existingCompletedIndexes,
        topicLifecycle: lifecycle('functions'),
        completedAt: completedAt,
      );

      existingCompletedIndexes.add(1);

      expect(result.didComplete, isTrue);
      expect(result.topicLifecycle.completedInitialPracticeCount, 1);
      expect(result.topicLifecycle.firstPracticeCompletedAt, completedAt);
      expect(result.completedAcademicTaskIndexes, {0});
      expect(
        () => result.completedAcademicTaskIndexes.add(2),
        throwsUnsupportedError,
      );
    });

    test('does not complete the same planned task twice', () {
      final firstCompletedAt = DateTime.utc(2026, 8, 29);
      final plan = dailyPlan();
      final firstCompletion = completeDailyPlanPractice(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        academicTaskIndex: 0,
        completedAcademicTaskIndexes: const {},
        topicLifecycle: lifecycle('functions'),
        completedAt: firstCompletedAt,
      );

      final repeatedCompletion = completeDailyPlanPractice(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        academicTaskIndex: 0,
        completedAcademicTaskIndexes:
            firstCompletion.completedAcademicTaskIndexes,
        topicLifecycle: firstCompletion.topicLifecycle,
        completedAt: DateTime.utc(2026, 8, 30),
      );

      expect(repeatedCompletion.didComplete, isFalse);
      expect(
        repeatedCompletion.topicLifecycle,
        same(firstCompletion.topicLifecycle),
      );
      expect(
        repeatedCompletion.topicLifecycle.completedInitialPracticeCount,
        1,
      );
      expect(
        repeatedCompletion.topicLifecycle.lastPracticeCompletedAt,
        firstCompletedAt,
      );
      expect(repeatedCompletion.completedAcademicTaskIndexes, {0});
    });

    test('uses one stable order across protected and normal tasks', () {
      final plan = dailyPlan(
        protectedTasks: [
          plannedTask(
            topicId: 'protected-functions',
            type: StudyTaskType.practice,
          ),
        ],
        normalTasks: [
          plannedTask(
            topicId: 'normal-functions',
            type: StudyTaskType.practice,
          ),
        ],
      );

      final result = completeDailyPlanPractice(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        academicTaskIndex: 1,
        completedAcademicTaskIndexes: const {},
        topicLifecycle: lifecycle('normal-functions'),
        completedAt: DateTime.utc(2026, 8, 29),
      );

      expect(result.didComplete, isTrue);
      expect(result.topicLifecycle.topicId, 'normal-functions');
      expect(result.completedAcademicTaskIndexes, {1});
    });

    test('rejects completion before the plan is active', () {
      expect(
        () => completeDailyPlanPractice(
          planLifecycle: PlanLifecycle.draftStudentModified,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 0,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('functions'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsStateError,
      );
    });

    test('rejects a non-Practice task', () {
      expect(
        () => completeDailyPlanPractice(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(
            normalTasks: [
              plannedTask(topicId: 'functions', type: StudyTaskType.progress),
            ],
          ),
          academicTaskIndex: 0,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('functions'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsStateError,
      );
    });

    test('rejects a lifecycle for a different topic', () {
      expect(
        () => completeDailyPlanPractice(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 0,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('vectors'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a position outside the academic task list', () {
      expect(
        () => completeDailyPlanPractice(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 1,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('functions'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsRangeError,
      );
    });
  });
}
