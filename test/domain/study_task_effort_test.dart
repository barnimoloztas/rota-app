import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/study_route.dart';
import 'package:rota_app/domain/study_task_effort.dart';

void main() {
  group('StudyTaskEffort', () {
    test('stores topic, task type, and estimated minutes', () {
      const effort = StudyTaskEffort(
        topicId: 'fonksiyonlar',
        taskType: StudyTaskType.repair,
        estimatedMinutes: 30,
      );

      expect(effort.topicId, 'fonksiyonlar');
      expect(effort.taskType, StudyTaskType.repair);
      expect(effort.estimatedMinutes, 30);
    });

    test('allows zero-minute estimate', () {
      const effort = StudyTaskEffort(
        topicId: 'olcum',
        taskType: StudyTaskType.measurement,
        estimatedMinutes: 0,
      );

      expect(effort.estimatedMinutes, 0);
    });
  });
}