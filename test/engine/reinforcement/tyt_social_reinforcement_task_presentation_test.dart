import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_task.dart';
import 'package:rota_app/engine/reinforcement/tyt_social_reinforcement_task_presentation.dart';

void main() {
  test('presents the task as a common TYT social review branch exam', () {
    const task = TytSocialReinforcementTask();

    final presentation = presentationForTytSocialReinforcementTask(task);

    expect(presentation.title, 'Tekrar TYT Sosyal Branş Denemesi');
    expect(
      presentation.description,
      'TYT Sosyal branş denemeni tekrar çalışması olarak çöz. '
      'Gerektiğinde notlarına, kitabına veya konu anlatımına '
      'dönebilirsin. Bu bir performans ölçümü değildir.',
    );
  });
}
