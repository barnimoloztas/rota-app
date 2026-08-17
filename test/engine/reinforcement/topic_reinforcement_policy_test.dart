import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/topic_reinforcement_policy.dart';

void main() {
  group('TopicReinforcementPolicy', () {
    test('is not due before first practice is completed', () {
      const lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      final result = evaluateTopicReinforcement(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 8, 20),
      );

      expect(result.isDue, isFalse);
    });

    test('is not due before 14 days have passed after first practice', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 1,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      final result = evaluateTopicReinforcement(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 8, 23),
      );

      expect(result.isDue, isFalse);
    });

    test('first reinforcement is due 14 days after first practice', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 1,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      final result = evaluateTopicReinforcement(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 8, 24),
      );

      expect(result.isDue, isTrue);
    });

    test(
      'next reinforcement is not due immediately after previous reinforcement',
      () {
        final lifecycle = TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 4,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 15),
          completedReinforcementCount: 1,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 24),
        );

        final result = evaluateTopicReinforcement(
          lifecycle: lifecycle,
          evaluatedAt: DateTime.utc(2026, 8, 25),
        );

        expect(result.isDue, isFalse);
      },
    );

    test('next reinforcement is due one week after previous reinforcement', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 15),
        completedReinforcementCount: 1,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 24),
      );

      final result = evaluateTopicReinforcement(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 8, 31),
      );

      expect(result.isDue, isTrue);
    });

    test('topic reinforcement is not due after all three are completed', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 15),
        completedReinforcementCount: 3,
        lastReinforcementCompletedAt: DateTime.utc(2026, 9, 14),
      );

      final result = evaluateTopicReinforcement(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 9, 30),
      );

      expect(result.isDue, isFalse);
    });
  });
}