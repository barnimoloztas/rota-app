import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_plan_draft.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/subject_plan_task.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/planning/daily_plan_progress_completion.dart';

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

  DailyPlanDraft dailyPlan() {
    return DailyPlanDraft(
      protectedSubjectTasks: [
        plannedTask(
          topicId: 'protected-practice',
          type: StudyTaskType.practice,
        ),
      ],
      normalSubjectTasks: [
        plannedTask(topicId: 'functions', type: StudyTaskType.progress),
      ],
      reinforcement: null,
    );
  }

  TopicLearningLifecycle lifecycle(String topicId) {
    return TopicLearningLifecycle(
      topicId: topicId,
      progressCompletedAt: null,
      completedInitialPracticeCount: 0,
      firstPracticeCompletedAt: null,
      lastPracticeCompletedAt: null,
    );
  }

  group('completeDailyPlanProgress', () {
    test('completes active Progress in the frozen academic task order', () {
      final completedAt = DateTime.utc(2026, 8, 29);
      final existingCompletedIndexes = <int>{};

      final result = completeDailyPlanProgress(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: dailyPlan(),
        academicTaskIndex: 1,
        completedAcademicTaskIndexes: existingCompletedIndexes,
        topicLifecycle: lifecycle('functions'),
        completedAt: completedAt,
      );

      existingCompletedIndexes.add(0);

      expect(result.didComplete, isTrue);
      expect(result.topicLifecycle.progressCompletedAt, completedAt);
      expect(result.completedAcademicTaskIndexes, {1});
      expect(
        () => result.completedAcademicTaskIndexes.add(2),
        throwsUnsupportedError,
      );
    });

    test('does not complete the same planned Progress twice', () {
      final firstCompletedAt = DateTime.utc(2026, 8, 29);
      final plan = dailyPlan();
      final firstCompletion = completeDailyPlanProgress(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        academicTaskIndex: 1,
        completedAcademicTaskIndexes: const {},
        topicLifecycle: lifecycle('functions'),
        completedAt: firstCompletedAt,
      );

      final repeatedCompletion = completeDailyPlanProgress(
        planLifecycle: PlanLifecycle.active,
        dailyPlan: plan,
        academicTaskIndex: 1,
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
        repeatedCompletion.topicLifecycle.progressCompletedAt,
        firstCompletedAt,
      );
      expect(repeatedCompletion.completedAcademicTaskIndexes, {1});
    });

    test('rejects completion before the plan is active', () {
      expect(
        () => completeDailyPlanProgress(
          planLifecycle: PlanLifecycle.draftUntouched,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 1,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('functions'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsStateError,
      );
    });

    test('rejects a non-Progress task', () {
      expect(
        () => completeDailyPlanProgress(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 0,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('protected-practice'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsStateError,
      );
    });

    test('rejects a lifecycle for a different topic', () {
      expect(
        () => completeDailyPlanProgress(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 1,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('vectors'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a position outside the academic task list', () {
      expect(
        () => completeDailyPlanProgress(
          planLifecycle: PlanLifecycle.active,
          dailyPlan: dailyPlan(),
          academicTaskIndex: 2,
          completedAcademicTaskIndexes: const {},
          topicLifecycle: lifecycle('functions'),
          completedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsRangeError,
      );
    });
  });
}
