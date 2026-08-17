import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';

void main() {
  group('SubjectReinforcementTask', () {
    test('represents weekly topic reinforcement for a subject', () {
      const task = SubjectReinforcementTask(
        subjectId: 'mathematics',
        type: SubjectReinforcementTaskType.topicReinforcement,
      );

      expect(task.subjectId, 'mathematics');
      expect(
        task.type,
        SubjectReinforcementTaskType.topicReinforcement,
      );
    });

    test('represents branch reinforcement for a subject', () {
      const task = SubjectReinforcementTask(
        subjectId: 'mathematics',
        type: SubjectReinforcementTaskType.branchReinforcement,
      );

      expect(task.subjectId, 'mathematics');
      expect(
        task.type,
        SubjectReinforcementTaskType.branchReinforcement,
      );
    });
  });
}