import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';

void main() {
  group('TopicLearningLifecycle', () {
    test('starts before progress with no completed practice or reinforcement', () {
      const lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: null,
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      expect(lifecycle.topicId, 'fonksiyonlar');
      expect(lifecycle.progressCompletedAt, isNull);
      expect(lifecycle.completedInitialPracticeCount, 0);
      expect(lifecycle.firstPracticeCompletedAt, isNull);
      expect(lifecycle.lastPracticeCompletedAt, isNull);
      expect(lifecycle.completedReinforcementCount, 0);
      expect(lifecycle.lastReinforcementCompletedAt, isNull);
    });

    test('can represent completed progress before first practice', () {
      final progressCompletedAt = DateTime.utc(2026, 8, 1);

      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: progressCompletedAt,
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
        completedReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      expect(lifecycle.progressCompletedAt, progressCompletedAt);
      expect(lifecycle.completedInitialPracticeCount, 0);
    });

    test('rejects invalid practice and reinforcement counts', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: DateTime.utc(2026, 8, 1),
          completedInitialPracticeCount: 5,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: null,
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: null,
          lastPracticeCompletedAt: null,
          completedReinforcementCount: 4,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects practice completion before progress completion', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: null,
          completedInitialPracticeCount: 1,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects practice completion count without practice timestamps', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: DateTime.utc(2026, 8, 1),
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
            progressCompletedAt: DateTime.utc(2026, 8, 1),
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 2),
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
          progressCompletedAt: DateTime.utc(2026, 8, 1),
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
          progressCompletedAt: DateTime.utc(2026, 8, 1),
          completedInitialPracticeCount: 0,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 2),
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
          progressCompletedAt: DateTime.utc(2026, 8, 1),
          completedInitialPracticeCount: 1,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          completedReinforcementCount: 0,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}