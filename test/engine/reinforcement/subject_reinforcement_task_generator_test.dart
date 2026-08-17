import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_task_generator.dart';

void main() {
  group('generateSubjectReinforcementTask', () {
    test('returns null when reinforcement is not due', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      final task = generateSubjectReinforcementTask(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 8, 14),
      );

      expect(task, isNull);
    });

    test('generates topic reinforcement during R1-R3 phase', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 1,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
      );

      final task = generateSubjectReinforcementTask(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 8, 22),
      );

      expect(task, isNotNull);
      expect(task!.subjectId, 'mathematics');
      expect(
        task.type,
        SubjectReinforcementTaskType.topicReinforcement,
      );
    });

    test('generates branch reinforcement after R3', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 3,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
      );

      final task = generateSubjectReinforcementTask(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 9, 5),
      );

      expect(task, isNotNull);
      expect(task!.subjectId, 'mathematics');
      expect(
        task.type,
        SubjectReinforcementTaskType.branchReinforcement,
      );
    });
  });
}