import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/practice/practice_completion_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/tyt_social_reinforcement_completion_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/tyt_social_reinforcement_task_generator.dart';

void main() {
  test('first social practice starts one repeating 45-day branch cycle', () {
    var topicLifecycle = TopicLearningLifecycle(
      topicId: 'tarih-ilk-konu',
      progressCompletedAt: DateTime.utc(2026, 8, 1),
      completedInitialPracticeCount: 0,
      firstPracticeCompletedAt: null,
      lastPracticeCompletedAt: null,
    );

    topicLifecycle = completePractice(
      lifecycle: topicLifecycle,
      completedAt: DateTime.utc(2026, 8, 1),
    );

    var socialLifecycle = TytSocialReinforcementLifecycle(
      startedAt: topicLifecycle.firstPracticeCompletedAt!,
      lastReinforcementCompletedAt: null,
    );

    final firstDue = generateTytSocialReinforcementTask(
      lifecycle: socialLifecycle,
      evaluatedAt: DateTime.utc(2026, 9, 15),
    );

    expect(firstDue, isNotNull);

    socialLifecycle = completeTytSocialReinforcement(
      lifecycle: socialLifecycle,
      completedAt: DateTime.utc(2026, 9, 20),
    );

    final beforeNextDue = generateTytSocialReinforcementTask(
      lifecycle: socialLifecycle,
      evaluatedAt: DateTime.utc(2026, 11, 3),
    );
    final nextDue = generateTytSocialReinforcementTask(
      lifecycle: socialLifecycle,
      evaluatedAt: DateTime.utc(2026, 11, 4),
    );

    expect(beforeNextDue, isNull);
    expect(nextDue, isNotNull);
  });
}
