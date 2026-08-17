import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/practice/practice_completion_lifecycle.dart';

void main() {
  group('completePractice', () {
    test('completes P1 and sets first and last practice timestamps', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 10),
        completedInitialPracticeCount: 0,
        firstPracticeCompletedAt: null,
        lastPracticeCompletedAt: null,
      );

      final result = completePractice(
        lifecycle: lifecycle,
        completedAt: DateTime.utc(2026, 8, 10),
      );

      expect(result.completedInitialPracticeCount, 1);
      expect(
        result.firstPracticeCompletedAt,
        DateTime.utc(2026, 8, 10),
      );
      expect(
        result.lastPracticeCompletedAt,
        DateTime.utc(2026, 8, 10),
      );
    });

    test('completes later practice without changing first practice timestamp', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 10),
        completedInitialPracticeCount: 2,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 12),
      );

      final result = completePractice(
        lifecycle: lifecycle,
        completedAt: DateTime.utc(2026, 8, 14),
      );

      expect(result.completedInitialPracticeCount, 3);
      expect(
        result.firstPracticeCompletedAt,
        DateTime.utc(2026, 8, 10),
      );
      expect(
        result.lastPracticeCompletedAt,
        DateTime.utc(2026, 8, 14),
      );
    });

    test('rejects completion after P4 is already completed', () {
      final lifecycle = TopicLearningLifecycle(
        topicId: 'fonksiyonlar',
        progressCompletedAt: DateTime.utc(2026, 8, 1),
        completedInitialPracticeCount: 4,
        firstPracticeCompletedAt: DateTime.utc(2026, 8, 2),
        lastPracticeCompletedAt: DateTime.utc(2026, 8, 8),
      );

      expect(
        () => completePractice(
          lifecycle: lifecycle,
          completedAt: DateTime.utc(2026, 8, 10),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}