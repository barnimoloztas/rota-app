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

    test('is not due during the first week after first practice', () {
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
        evaluatedAt: DateTime.utc(2026, 8, 16),
      );

      expect(result.isDue, isFalse);
    });

    test(
      'first reinforcement is due in the second week after first practice',
      () {
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
          evaluatedAt: DateTime.utc(2026, 8, 17),
        );

        expect(result.isDue, isTrue);
      },
    );

    test(
      'second reinforcement is not due immediately after first reinforcement',
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

    test('second reinforcement is due one week after first reinforcement', () {
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

    test('reports r1 as next step when no reinforcement is completed', () {
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
        evaluatedAt: DateTime.utc(2026, 8, 17),
      );

      expect(result.nextStep, TopicReinforcementStep.r1);
    });

    test('reports r2 as next step after first reinforcement is completed', () {
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

      expect(result.nextStep, TopicReinforcementStep.r2);
    });

    test('reports r3 as next step after second reinforcement is completed', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 15),
        completedReinforcementCount: 2,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 31),
      );

      final result = evaluateTopicReinforcement(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 9, 7),
      );

      expect(result.nextStep, TopicReinforcementStep.r3);
    });

    test('reports completed after all three reinforcements are completed', () {
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

      expect(result.nextStep, TopicReinforcementStep.completed);
    });
  });
}