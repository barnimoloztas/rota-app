import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';

void main() {
  group('StudyTask', () {
    test('stores a normal task', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.progress,
        sourceTopicId: 'fonksiyonlar',
      );

      expect(task.topicId, 'fonksiyonlar');
      expect(task.type, StudyTaskType.progress);
      expect(task.sourceTopicId, 'fonksiyonlar');
      expect(task.questionTarget, isNull);
    });

    test('stores practice question target', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.practice,
        sourceTopicId: 'fonksiyonlar',
        questionTarget: 40,
      );

      expect(task.topicId, 'fonksiyonlar');
      expect(task.type, StudyTaskType.practice);
      expect(task.questionTarget, 40);
    });

    test('stores a bridge task with a different source topic', () {
      const task = StudyTask(
        topicId: 'fonksiyonlar',
        type: StudyTaskType.bridge,
        sourceTopicId: 'limit_ve_sureklilik',
      );

      expect(task.topicId, 'fonksiyonlar');
      expect(task.type, StudyTaskType.bridge);
      expect(task.sourceTopicId, 'limit_ve_sureklilik');
      expect(task.questionTarget, isNull);
    });
  });

  group('StudyRoute', () {
    test('preserves task ordering', () {
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

      expect(route.tasks, hasLength(2));
      expect(route.tasks.first.type, StudyTaskType.bridge);
      expect(route.tasks.last.type, StudyTaskType.progress);
    });

    test('can represent an empty route', () {
      const route = StudyRoute(
        tasks: [],
      );

      expect(route.tasks, isEmpty);
    });
  });
}