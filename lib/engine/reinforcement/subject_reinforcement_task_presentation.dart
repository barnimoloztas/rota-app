import '../../domain/subject_reinforcement_task.dart';

class SubjectReinforcementTaskPresentation {
  const SubjectReinforcementTaskPresentation({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

SubjectReinforcementTaskPresentation
    presentationForSubjectReinforcementTask(
  SubjectReinforcementTask task,
) {
  switch (task.type) {
    case SubjectReinforcementTaskType.topicReinforcement:
      return const SubjectReinforcementTaskPresentation(
        title: 'Haftalık Konu Tekrarı',
        description:
            'Gördüğün konuların her birinden yaklaşık 15 soru çöz. '
            'Takıldığında notlarına, kitabına, videoya veya konu anlatımına '
            'dönebilirsin. Amaç kendini sınamak değil, konuları tekrar etmek '
            've sağlamlaştırmaktır.',
      );

    case SubjectReinforcementTaskType.branchReinforcement:
      return const SubjectReinforcementTaskPresentation(
        title: 'Tekrar Branş Denemesi',
        description:
            'Branş denemeni tekrar çalışması olarak çöz. Gerektiğinde '
            'notlarına, kitabına veya konu anlatımına dönebilirsin. '
            'Bu bir performans ölçümü değildir.',
      );
  }
}