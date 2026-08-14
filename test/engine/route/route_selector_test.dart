import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/route/route_selector.dart';

void main() {
  group('selectRouteTasks', () {
    test('limits route to four tasks', () {
      const route = StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'a',
            type: StudyTaskType.progress,
            sourceTopicId: 'a',
          ),
          StudyTask(
            topicId: 'b',
            type: StudyTaskType.repair,
            sourceTopicId: 'b',
          ),
          StudyTask(
            topicId: 'c',
            type: StudyTaskType.reinforcement,
            sourceTopicId: 'c',
          ),
          StudyTask(
            topicId: 'd',
            type: StudyTaskType.measurement,
            sourceTopicId: 'd',
          ),
          StudyTask(
            topicId: 'e',
            type: StudyTaskType.progress,
            sourceTopicId: 'e',
          ),
        ],
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(selected.tasks, hasLength(4));
      expect(
        selected.tasks.map((task) => task.topicId),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('supports lower daily capacity', () {
      const route = StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'a',
            type: StudyTaskType.progress,
            sourceTopicId: 'a',
          ),
          StudyTask(
            topicId: 'b',
            type: StudyTaskType.repair,
            sourceTopicId: 'b',
          ),
          StudyTask(
            topicId: 'c',
            type: StudyTaskType.reinforcement,
            sourceTopicId: 'c',
          ),
        ],
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 2,
        ),
      );

      expect(selected.tasks, hasLength(2));
      expect(
        selected.tasks.map((task) => task.topicId),
        ['a', 'b'],
      );
    });

    test('can produce an empty route when capacity is zero', () {
      const route = StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
            sourceTopicId: 'fonksiyonlar',
          ),
        ],
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 0,
        ),
      );

      expect(selected.tasks, isEmpty);
    });

    test('keeps bridge and target together when both fit', () {
      const route = StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.bridge,
            sourceTopicId: 'limit_ve_sureklilik',
          ),
          StudyTask(
            topicId: 'limit_ve_sureklilik',
            type: StudyTaskType.progress,
            sourceTopicId: 'limit_ve_sureklilik',
          ),
          StudyTask(
            topicId: 'turev',
            type: StudyTaskType.repair,
            sourceTopicId: 'turev',
          ),
        ],
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 2,
        ),
      );

      expect(selected.tasks, hasLength(2));
      expect(selected.tasks[0].type, StudyTaskType.bridge);
      expect(selected.tasks[1].topicId, 'limit_ve_sureklilik');
    });

    test(
      'does not select bridge alone when only one slot is available',
      () {
        const route = StudyRoute(
          tasks: [
            StudyTask(
              topicId: 'fonksiyonlar',
              type: StudyTaskType.bridge,
              sourceTopicId: 'limit_ve_sureklilik',
            ),
            StudyTask(
              topicId: 'limit_ve_sureklilik',
              type: StudyTaskType.progress,
              sourceTopicId: 'limit_ve_sureklilik',
            ),
          ],
        );

        final selected = selectRouteTasks(
          route: route,
          config: const RouteSelectionConfig(
            maxTasks: 1,
          ),
        );

        expect(selected.tasks, isEmpty);
      },
    );

    test('preserves route ordering', () {
      const route = StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'a',
            type: StudyTaskType.progress,
            sourceTopicId: 'a',
          ),
          StudyTask(
            topicId: 'b',
            type: StudyTaskType.repair,
            sourceTopicId: 'b',
          ),
          StudyTask(
            topicId: 'c',
            type: StudyTaskType.measurement,
            sourceTopicId: 'c',
          ),
        ],
      );

      final first = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 3,
        ),
      );

      final second = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 3,
        ),
      );

      expect(first.tasks.length, second.tasks.length);

      for (var i = 0; i < first.tasks.length; i++) {
        expect(first.tasks[i].topicId, second.tasks[i].topicId);
        expect(first.tasks[i].type, second.tasks[i].type);
      }
    });
  });
}