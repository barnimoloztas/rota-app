import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/route/study_task_effort_policy.dart';

void main() {
  const config = StudyTaskEffortPolicyConfig(
    minutesByTaskType: {
      StudyTaskType.progress: 40,
      StudyTaskType.repair: 30,
      StudyTaskType.reinforcement: 20,
      StudyTaskType.measurement: 15,
      StudyTaskType.bridge: 10,
    },
  );

  group('estimateTaskEffort', () {
    test('returns configured effort for task type', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.repair,
        sourceTopicId: 'fonksiyonlar',
      );

      final result = estimateTaskEffort(
        task: task,
        config: config,
      );

      expect(result, isNotNull);
      expect(result!.topicId, 'fonksiyonlar');
      expect(result.taskType, StudyTaskType.repair);
      expect(result.estimatedMinutes, 30);
    });

    test('returns null when task type is not configured', () {
      const partialConfig = StudyTaskEffortPolicyConfig(
        minutesByTaskType: {
          StudyTaskType.progress: 40,
        },
      );

      const task = StudyTask(
        topicId: 'trigonometri',
        type: StudyTaskType.measurement,
        sourceTopicId: 'trigonometri',
      );

      final result = estimateTaskEffort(
        task: task,
        config: partialConfig,
      );

      expect(result, isNull);
    });

    test('returns null for negative configured value', () {
      const invalidConfig = StudyTaskEffortPolicyConfig(
        minutesByTaskType: {
          StudyTaskType.repair: -5,
        },
      );

      const task = StudyTask(
        topicId: 'integral',
        type: StudyTaskType.repair,
        sourceTopicId: 'integral',
      );

      final result = estimateTaskEffort(
        task: task,
        config: invalidConfig,
      );

      expect(result, isNull);
    });
  });

  group('estimateRouteEfforts', () {
    test('creates effort estimates for configured route tasks', () {
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
            topicId: 'trigonometri',
            type: StudyTaskType.repair,
            sourceTopicId: 'trigonometri',
          ),
        ],
      );

      final result = estimateRouteEfforts(
        route: route,
        config: config,
      );

      expect(result, hasLength(3));

      expect(result[0].estimatedMinutes, 10);
      expect(result[1].estimatedMinutes, 40);
      expect(result[2].estimatedMinutes, 30);
    });

    test('skips route tasks whose type has no configured estimate', () {
      const partialConfig = StudyTaskEffortPolicyConfig(
        minutesByTaskType: {
          StudyTaskType.progress: 40,
        },
      );

      const route = StudyRoute(
        tasks: [
          StudyTask(
            topicId: 'fonksiyonlar',
            type: StudyTaskType.progress,
            sourceTopicId: 'fonksiyonlar',
          ),
          StudyTask(
            topicId: 'trigonometri',
            type: StudyTaskType.repair,
            sourceTopicId: 'trigonometri',
          ),
        ],
      );

      final result = estimateRouteEfforts(
        route: route,
        config: partialConfig,
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
    });

    test('preserves route ordering deterministically', () {
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
        ],
      );

      final first = estimateRouteEfforts(
        route: route,
        config: config,
      );

      final second = estimateRouteEfforts(
        route: route,
        config: config,
      );

      expect(first.length, second.length);

      for (var i = 0; i < first.length; i++) {
        expect(first[i].topicId, second[i].topicId);
        expect(
          first[i].estimatedMinutes,
          second[i].estimatedMinutes,
        );
      }
    });
  });
}