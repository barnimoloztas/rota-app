import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/reinforcement_completion_lifecycle.dart';

void main() {
  group('completeReinforcement', () {
    test('completes first reinforcement and sets completion timestamp', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 1),
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 8),
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      final result = completeReinforcement(
        lifecycle: lifecycle,
        completedAt: DateTime.utc(2026, 8, 16),
      );

      expect(result.completedReinforcementCount, 1);
      expect(
        result.lastReinforcementCompletedAt,
        DateTime.utc(2026, 8, 16),
      );
    });

    test('completes later reinforcement and updates completion timestamp', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 1),
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 8),
        completedReinforcementCount: 1,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 16),
      );

      final result = completeReinforcement(
        lifecycle: lifecycle,
        completedAt: DateTime.utc(2026, 8, 23),
      );

      expect(result.completedReinforcementCount, 2);
      expect(
        result.lastReinforcementCompletedAt,
        DateTime.utc(2026, 8, 23),
      );
    });

    test('preserves practice lifecycle fields', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 1),
        completedInitialPracticeCount: 3,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 6),
        completedReinforcementCount: 1,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 16),
      );

      final result = completeReinforcement(
        lifecycle: lifecycle,
        completedAt: DateTime.utc(2026, 8, 23),
      );

      expect(
        result.progressCompletedAt,
        DateTime.utc(2026, 8, 1),
      );
      expect(result.completedInitialPracticeCount, 3);
      expect(
        result.firstPracticeCompletedAt,
        DateTime.utc(2026, 8, 2),
      );
      expect(
        result.lastPracticeCompletedAt,
        DateTime.utc(2026, 8, 6),
      );
    });

    test('rejects completion after all three reinforcements are completed', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 1),
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 8),
        completedReinforcementCount: 3,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 30),
      );

      expect(
        () => completeReinforcement(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 9, 6),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}