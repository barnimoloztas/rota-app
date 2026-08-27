import '../../domain/tyt_social_reinforcement_task.dart';

class TytSocialReinforcementTaskPresentation {
  const TytSocialReinforcementTaskPresentation({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

TytSocialReinforcementTaskPresentation
presentationForTytSocialReinforcementTask(TytSocialReinforcementTask _) {
  return const TytSocialReinforcementTaskPresentation(
    title: 'Tekrar TYT Sosyal Branş Denemesi',
    description:
        'TYT Sosyal branş denemeni tekrar çalışması olarak çöz. '
        'Gerektiğinde notlarına, kitabına veya konu anlatımına '
        'dönebilirsin. Bu bir performans ölçümü değildir.',
  );
}
