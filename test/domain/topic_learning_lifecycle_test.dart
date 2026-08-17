import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';

void main() {
  group('TopicLearningLifecycle', () {
    test('starts before progress with no completed practice', () {
      const lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: null,
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
      );

      expect(lifecycle.topicId, 'fonksiyonlar');
      expect(lifecycle.progressCompletedAt, isNull);
      expect(lifecycle.completedInitialPracticeCount, 0);
      expect(lifecycle.firstPracticeCompletedAt, isNull);
      expect(lifecycle.lastPracticeCompletedAt, isNull);
    });

    test('can represent completed progress before first practice', () {
      final progressCompletedAt = DateTime.utc(2026, 8, 1);

      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: progressCompletedAt,
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
      );

      expect(lifecycle.progressCompletedAt, progressCompletedAt);
      expect(lifecycle.completedInitialPracticeCount, 0);
    });

    test('rejects invalid practice count', () {
      expect(
        () => TopicLearningLifecycle(
          topicId: 'fonksiyonlar',
          progressCompletedAt: DateTime.utc(2026, 8, 1),
          completedInitialPracticeCount: 5,
          firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
          lastPracticeCompletedAt: DateTime.utc(2026, 8, 2),
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
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}