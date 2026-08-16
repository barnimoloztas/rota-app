import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';

void main() {
  group('TopicLearningLifecycle', () {
    test('starts with no completed practice or reinforcement', () {
      const lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      expect(lifecycle.topicId, 'fonksiyonlar');
      expect(lifecycle.completedInitialPracticeCount, 0);
      expect(lifecycle.firstPracticeCompletedAt, isNull);
      expect(lifecycle.lastPracticeCompletedAt, isNull);
      expect(lifecycle.completedReinforcementCount, 0);
      expect(lifecycle.lastReinforcementCompletedAt, isNull);
    });

    test('rejects invalid practice and reinforcement counts', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 5,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 4,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects practice completion count without practice timestamps', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 1,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
      'rejects reinforcement completion count without reinforcement timestamp',
      () {
        expect(
          () => TopicLearningLifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            completedReinforcementCount: 1,
            lastReinforcementCompletedAt: null,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('rejects reinforcement completion before first practice', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 1,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects practice timestamps when no practice is completed', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 1),
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects reinforcement timestamp when no reinforcement is completed', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          completedInitialPracticeCount: 1,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 1),
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}