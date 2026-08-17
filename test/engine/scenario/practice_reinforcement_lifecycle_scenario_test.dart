import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/practice/practice_completion_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/reinforcement_completion_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/topic_reinforcement_policy.dart';

void main() {
  group('practice and reinforcement lifecycle scenario', () {
    test(
      'P1 starts reinforcement timing while P2-P4 continue independently',
      () {
        var lifecycle = TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: DateTime.utc(2026, 8, 1),
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        );

        lifecycle = completePractice(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 1),
        );

        expect(lifecycle.completedInitialPracticeCount, 1);

        expect(
          evaluateTopicReinforcement(
            lifecycle: lifecycle,
            evaluatedAt: DateTime.utc(2026, 8, 14),
          ).isDue,
          isFalse,
        );

        lifecycle = completePractice(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 3),
        );

        lifecycle = completePractice(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 5),
        );

        lifecycle = completePractice(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 7),
        );

        expect(lifecycle.completedInitialPracticeCount, 4);
        expect(
          lifecycle.firstPracticeCompletedAt,
          DateTime.utc(2026, 8, 1),
        );
        expect(
          lifecycle.lastPracticeCompletedAt,
          DateTime.utc(2026, 8, 7),
        );

        expect(
          evaluateTopicReinforcement(
            lifecycle: lifecycle,
            evaluatedAt: DateTime.utc(2026, 8, 15),
          ).isDue,
          isTrue,
        );

        lifecycle = completeReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 15),
        );

        expect(lifecycle.completedReinforcementCount, 1);

        expect(
          evaluateTopicReinforcement(
            lifecycle: lifecycle,
            evaluatedAt: DateTime.utc(2026, 8, 21),
          ).isDue,
          isFalse,
        );

        expect(
          evaluateTopicReinforcement(
            lifecycle: lifecycle,
            evaluatedAt: DateTime.utc(2026, 8, 22),
          ).isDue,
          isTrue,
        );

        lifecycle = completeReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 22),
        );

        expect(lifecycle.completedReinforcementCount, 2);

        expect(
          evaluateTopicReinforcement(
            lifecycle: lifecycle,
            evaluatedAt: DateTime.utc(2026, 8, 29),
          ).isDue,
          isTrue,
        );

        lifecycle = completeReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 29),
        );

        expect(lifecycle.completedReinforcementCount, 3);

        expect(
          evaluateTopicReinforcement(
            lifecycle: lifecycle,
            evaluatedAt: DateTime.utc(2026, 9, 20),
          ).isDue,
          isFalse,
        );
      },
    );
  });
}