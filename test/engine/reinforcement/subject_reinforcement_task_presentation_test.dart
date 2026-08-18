import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_task.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_task_presentation.dart';

void main() {
  group('presentationForSubjectReinforcementTask', () {
    test('presents topic reinforcement as weekly topic review', () {
      const task = SubjectReinforcementTask(
        subjectId: 'mathematics',
        type: SubjectReinforcementTaskType.topicReinforcement,
      );

      final presentation = presentationForSubjectReinforcementTask(task);

      expect(presentation.title, 'Haftalık Konu Tekrarı');
      expect(
        presentation.description,
        'Gördüğün konuların her birinden yaklaşık 15 soru çöz. '
        'Takıldığında notlarına, kitabına, videoya veya konu anlatımına '
        'dönebilirsin. Amaç kendini sınamak değil, konuları tekrar etmek '
        've sağlamlaştırmaktır.',
      );
    });

    test('presents branch reinforcement as review branch exam', () {
      const task = SubjectReinforcementTask(
        subjectId: 'mathematics',
        type: SubjectReinforcementTaskType.branchReinforcement,
      );

      final presentation = presentationForSubjectReinforcementTask(task);

      expect(presentation.title, 'Tekrar Branş Denemesi');
      expect(
        presentation.description,
        'Branş denemeni tekrar çalışması olarak çöz. Gerektiğinde '
        'notlarına, kitabına veya konu anlatımına dönebilirsin. '
        'Bu bir performans ölçümü değildir.',
      );
    });
  });
}