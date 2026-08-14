import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_study_budget.dart';
import 'package:rota_app/domain/plan_task_state.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/study_task_effort.dart';
import 'package:rota_app/engine/planning/plan_refresh_budget_policy.dart';

void main() {
  StudyTask task({
    required String topicId,
    required StudyTaskType type,
  }) {
    return StudyTask(
      topicId: topicId,
      type: type,
      sourceTopicId: topicId,
    );
  }

  PlanTaskState state({
    required String topicId,
    required PlanTaskOwner owner,
    required bool touched,
  }) {
    return PlanTaskState(
      topicId: topicId,
      owner: owner,
      wasTouchedByStudent: touched,
    );
  }

  StudyTaskEffort effort({
    required String topicId,
    required StudyTaskType type,
    required int minutes,
  }) {
    return StudyTaskEffort(
      topicId: topicId,
      taskType: type,
      estimatedMinutes: minutes,
    );
  }

  group('applyRefreshBudgetPolicy', () {
    test('keeps protected student-owned task even when it exceeds budget', () {
      final result = applyRefreshBudgetPolicy(
        refreshedTasks: [
          task(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
          ),
        ],
        taskStates: [
          state(
            topicId: 'fonksiyonlar',
            owner: PlanTaskOwner.student,
            touched: false,
          ),
        ],
        budget: const DailyStudyBudget(
          availableMinutes: 30,
        ),
        effortEstimates: [
          effort(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
            minutes: 45,
          ),
        ],
      );

      expect(result.tasks, hasLength(1));
      expect(result.tasks.first.topicId, 'fonksiyonlar');
      expect(result.totalEstimatedMinutes, 45);
      expect(result.exceedsBudget, isTrue);
    });

    test('keeps coach-owned task after student touched it', () {
      final result = applyRefreshBudgetPolicy(
        refreshedTasks: [
          task(
            topicId: 'turev',
            type: StudyTaskType.repair,
          ),
        ],
        taskStates: [
          state(
            topicId: 'turev',
            owner: PlanTaskOwner.coach,
            touched: true,
          ),
        ],
        budget: const DailyStudyBudget(
          availableMinutes: 20,
        ),
        effortEstimates: [
          effort(
            topicId: 'turev',
            type: StudyTaskType.repair,
            minutes: 30,
          ),
        ],
      );

      expect(result.tasks, hasLength(1));
      expect(result.exceedsBudget, isTrue);
    });

    test('drops unprotected coach task when it does not fit remaining budget', () {
      final result = applyRefreshBudgetPolicy(
        refreshedTasks: [
          task(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
          ),
          task(
            topicId: 'integral',
            type: StudyTaskType.repair,
          ),
        ],
        taskStates: [
          state(
            topicId: 'fonksiyonlar',
            owner: PlanTaskOwner.student,
            touched: false,
          ),
          state(
            topicId: 'integral',
            owner: PlanTaskOwner.coach,
            touched: false,
          ),
        ],
        budget: const DailyStudyBudget(
          availableMinutes: 60,
        ),
        effortEstimates: [
          effort(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
            minutes: 40,
          ),
          effort(
            topicId: 'integral',
            type: StudyTaskType.repair,
            minutes: 30,
          ),
        ],
      );

      expect(result.tasks, hasLength(1));
      expect(result.tasks.first.topicId, 'fonksiyonlar');
      expect(result.totalEstimatedMinutes, 40);
      expect(result.exceedsBudget, isFalse);
    });

    test('keeps unprotected coach tasks while they fit budget', () {
      final result = applyRefreshBudgetPolicy(
        refreshedTasks: [
          task(
            topicId: 'a',
            type: StudyTaskType.repair,
          ),
          task(
            topicId: 'b',
            type: StudyTaskType.measurement,
          ),
        ],
        taskStates: [
          state(
            topicId: 'a',
            owner: PlanTaskOwner.coach,
            touched: false,
          ),
          state(
            topicId: 'b',
            owner: PlanTaskOwner.coach,
            touched: false,
          ),
        ],
        budget: const DailyStudyBudget(
          availableMinutes: 60,
        ),
        effortEstimates: [
          effort(
            topicId: 'a',
            type: StudyTaskType.repair,
            minutes: 30,
          ),
          effort(
            topicId: 'b',
            type: StudyTaskType.measurement,
            minutes: 20,
          ),
        ],
      );

      expect(result.tasks, hasLength(2));
      expect(result.totalEstimatedMinutes, 50);
      expect(result.exceedsBudget, isFalse);
    });

    test('missing task state is treated as protected', () {
      final result = applyRefreshBudgetPolicy(
        refreshedTasks: [
          task(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
          ),
        ],
        taskStates: const [],
        budget: const DailyStudyBudget(
          availableMinutes: 10,
        ),
        effortEstimates: [
          effort(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
            minutes: 40,
          ),
        ],
      );

      expect(result.tasks, hasLength(1));
      expect(result.exceedsBudget, isTrue);
    });

    test('missing effort estimate is never treated as zero-cost', () {
      final result = applyRefreshBudgetPolicy(
        refreshedTasks: [
          task(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
          ),
        ],
        taskStates: [
          state(
            topicId: 'fonksiyonlar',
            owner: PlanTaskOwner.coach,
            touched: false,
          ),
        ],
        budget: const DailyStudyBudget(
          availableMinutes: 120,
        ),
        effortEstimates: const [],
      );

      expect(result.tasks, isEmpty);
      expect(result.exceedsBudget, isFalse);
    });
  });
}