import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/daily_study_budget.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/study_task_effort.dart';
import 'package:rota_app/engine/route/budget_route_selector.dart';

void main() {
  StudyTask task({
    required String topicId,
    required StudyTaskType type,
    String? sourceTopicId,
  }) {
    return StudyTask(
      topicId: topicId,
      type: type,
      sourceTopicId: sourceTopicId ?? topicId,
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

  group('selectRouteWithinBudget', () {
    test('selects tasks while total estimated time fits budget', () {
      final route = StudyRoute(
        tasks: [
          task(
            topicId: 'a',
            type: StudyTaskType.progress,
          ),
          task(
            topicId: 'b',
            type: StudyTaskType.repair,
          ),
          task(
            topicId: 'c',
            type: StudyTaskType.measurement,
          ),
        ],
      );

      final result = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 60,
        ),
        effortEstimates: [
          effort(
            topicId: 'a',
            type: StudyTaskType.progress,
            minutes: 20,
          ),
          effort(
            topicId: 'b',
            type: StudyTaskType.repair,
            minutes: 25,
          ),
          effort(
            topicId: 'c',
            type: StudyTaskType.measurement,
            minutes: 30,
          ),
        ],
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result.tasks, hasLength(2));

      expect(
        result.tasks.map((task) => task.topicId),
        ['a', 'b'],
      );
    });

    test('respects max four tasks even when time budget is large', () {
      final route = StudyRoute(
        tasks: [
          task(topicId: 'a', type: StudyTaskType.progress),
          task(topicId: 'b', type: StudyTaskType.repair),
          task(topicId: 'c', type: StudyTaskType.reinforcement),
          task(topicId: 'd', type: StudyTaskType.measurement),
          task(topicId: 'e', type: StudyTaskType.progress),
        ],
      );

      final result = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 300,
        ),
        effortEstimates: [
          effort(
            topicId: 'a',
            type: StudyTaskType.progress,
            minutes: 20,
          ),
          effort(
            topicId: 'b',
            type: StudyTaskType.repair,
            minutes: 20,
          ),
          effort(
            topicId: 'c',
            type: StudyTaskType.reinforcement,
            minutes: 20,
          ),
          effort(
            topicId: 'd',
            type: StudyTaskType.measurement,
            minutes: 20,
          ),
          effort(
            topicId: 'e',
            type: StudyTaskType.progress,
            minutes: 20,
          ),
        ],
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result.tasks, hasLength(4));

      expect(
        result.tasks.map((task) => task.topicId),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('zero-minute budget produces empty route', () {
      final route = StudyRoute(
        tasks: [
          task(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
          ),
        ],
      );

      final result = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 0,
        ),
        effortEstimates: [
          effort(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
            minutes: 20,
          ),
        ],
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result.tasks, isEmpty);
    });

    test('keeps bridge and target together when both fit budget', () {
      final route = StudyRoute(
        tasks: [
          task(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.bridge,
            sourceTopicId: 'limit_ve_sureklilik',
          ),
          task(
            topicId: 'limit_ve_sureklilik',
            type: StudyTaskType.progress,
          ),
        ],
      );

      final result = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 50,
        ),
        effortEstimates: [
          effort(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.bridge,
            minutes: 15,
          ),
          effort(
            topicId: 'limit_ve_sureklilik',
            type: StudyTaskType.progress,
            minutes: 30,
          ),
        ],
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result.tasks, hasLength(2));
      expect(result.tasks[0].topicId, 'fonksiyonlar');
      expect(result.tasks[1].topicId, 'limit_ve_sureklilik');
    });

    test(
      'does not select bridge alone when bridge-target pair exceeds budget',
      () {
        final route = StudyRoute(
          tasks: [
            task(
              topicId: 'fonksiyonlar',
              type: StudyTaskType.bridge,
              sourceTopicId: 'limit_ve_sureklilik',
            ),
            task(
              topicId: 'limit_ve_sureklilik',
              type: StudyTaskType.progress,
            ),
          ],
        );

        final result = selectRouteWithinBudget(
          route: route,
          budget: const DailyStudyBudget(
            availableMinutes: 30,
          ),
          effortEstimates: [
            effort(
              topicId: 'fonksiyonlar',
              type: StudyTaskType.bridge,
              minutes: 15,
            ),
            effort(
              topicId: 'limit_ve_sureklilik',
              type: StudyTaskType.progress,
              minutes: 30,
            ),
          ],
          config: const BudgetRouteSelectionConfig(
            maxTasks: 4,
          ),
        );

        expect(result.tasks, isEmpty);
      },
    );

    test('missing effort estimate does not assume zero cost', () {
      final route = StudyRoute(
        tasks: [
          task(
            topicId: 'a',
            type: StudyTaskType.progress,
          ),
        ],
      );

      final result = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 120,
        ),
        effortEstimates: const [],
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(result.tasks, isEmpty);
    });

    test('preserves ranked route order deterministically', () {
      final route = StudyRoute(
        tasks: [
          task(topicId: 'a', type: StudyTaskType.repair),
          task(topicId: 'b', type: StudyTaskType.measurement),
        ],
      );

      final efforts = [
        effort(
          topicId: 'a',
          type: StudyTaskType.repair,
          minutes: 20,
        ),
        effort(
          topicId: 'b',
          type: StudyTaskType.measurement,
          minutes: 20,
        ),
      ];

      final first = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 60,
        ),
        effortEstimates: efforts,
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      final second = selectRouteWithinBudget(
        route: route,
        budget: const DailyStudyBudget(
          availableMinutes: 60,
        ),
        effortEstimates: efforts,
        config: const BudgetRouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(first.tasks.length, second.tasks.length);

      for (var i = 0; i < first.tasks.length; i++) {
        expect(
          first.tasks[i].topicId,
          second.tasks[i].topicId,
        );
      }
    });
  });
}