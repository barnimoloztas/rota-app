import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/engine/planning/plan_replacement_selector.dart';

void main() {
  group('selectReplacementTask', () {
    test('selects first ranked eligible replacement', () {
      const taskToReplace = StudyTask(
        topicId: 'integral',
        type: StudyTaskType.repair,
        sourceTopicId: 'integral',
      );

      const rankedTasks = [
        StudyTask(
          topicId: 'trigonometri',
          type: StudyTaskType.repair,
          sourceTopicId: 'trigonometri',
        ),
        StudyTask(
          topicId: 'fonksiyonlar',
          type: StudyTaskType.measurement,
          sourceTopicId: 'fonksiyonlar',
        ),
      ];

      final result = selectReplacementTask(
        taskToReplace: taskToReplace,
        rankedRefreshedTasks: rankedTasks,
        protectedTasks: const [],
      );

      expect(result, isNotNull);
      expect(result!.topicId, 'trigonometri');
      expect(result.type, StudyTaskType.repair);
    });

    test('skips exact same task as replacement', () {
      const taskToReplace = StudyTask(
        topicId: 'integral',
        type: StudyTaskType.repair,
        sourceTopicId: 'integral',
      );

      const rankedTasks = [
        StudyTask(
          topicId: 'integral',
          type: StudyTaskType.repair,
          sourceTopicId: 'integral',
        ),
        StudyTask(
          topicId: 'turev',
          type: StudyTaskType.measurement,
          sourceTopicId: 'turev',
        ),
      ];

      final result = selectReplacementTask(
        taskToReplace: taskToReplace,
        rankedRefreshedTasks: rankedTasks,
        protectedTasks: const [],
      );

      expect(result, isNotNull);
      expect(result!.topicId, 'turev');
    });

    test('skips task whose topic is already protected in plan', () {
      const taskToReplace = StudyTask(
        topicId: 'integral',
        type: StudyTaskType.repair,
        sourceTopicId: 'integral',
      );

      const rankedTasks = [
        StudyTask(
          topicId: 'trigonometri',
          type: StudyTaskType.repair,
          sourceTopicId: 'trigonometri',
        ),
        StudyTask(
          topicId: 'fonksiyonlar',
          type: StudyTaskType.measurement,
          sourceTopicId: 'fonksiyonlar',
        ),
      ];

      const protectedTasks = [
        StudyTask(
          topicId: 'trigonometri',
          type: StudyTaskType.progress,
          sourceTopicId: 'trigonometri',
        ),
      ];

      final result = selectReplacementTask(
        taskToReplace: taskToReplace,
        rankedRefreshedTasks: rankedTasks,
        protectedTasks: protectedTasks,
      );

      expect(result, isNotNull);
      expect(result!.topicId, 'fonksiyonlar');
    });

    test('returns null when no eligible replacement exists', () {
      const taskToReplace = StudyTask(
        topicId: 'integral',
        type: StudyTaskType.repair,
        sourceTopicId: 'integral',
      );

      const rankedTasks = [
        StudyTask(
          topicId: 'integral',
          type: StudyTaskType.repair,
          sourceTopicId: 'integral',
        ),
      ];

      final result = selectReplacementTask(
        taskToReplace: taskToReplace,
        rankedRefreshedTasks: rankedTasks,
        protectedTasks: const [],
      );

      expect(result, isNull);
    });

    test('selection is deterministic for same ordered input', () {
      const taskToReplace = StudyTask(
        topicId: 'integral',
        type: StudyTaskType.repair,
        sourceTopicId: 'integral',
      );

      const rankedTasks = [
        StudyTask(
          topicId: 'a',
          type: StudyTaskType.measurement,
          sourceTopicId: 'a',
        ),
        StudyTask(
          topicId: 'b',
          type: StudyTaskType.reinforcement,
          sourceTopicId: 'b',
        ),
      ];

      final first = selectReplacementTask(
        taskToReplace: taskToReplace,
        rankedRefreshedTasks: rankedTasks,
        protectedTasks: const [],
      );

      final second = selectReplacementTask(
        taskToReplace: taskToReplace,
        rankedRefreshedTasks: rankedTasks,
        protectedTasks: const [],
      );

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.topicId, second!.topicId);
      expect(first.type, second.type);
    });
  });
}