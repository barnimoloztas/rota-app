import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/progress/progress_completion_lifecycle.dart';

void main() {
  TopicLearningLifecycle incompleteLifecycle() {
    return const TopicLearningLifecycle(
      topicId: 'functions',
      progressCompletedAt: null,
      completedInitialPracticeCount: 0,
      firstPracticeCompletedAt: null,
      lastPracticeCompletedAt: null,
    );
  }

  group('completeProgress', () {
    test('records the first Progress completion', () {
      final completedAt = DateTime.utc(2026, 8, 29);

      final result = completeProgress(
        lifecycle: incompleteLifecycle(),
        completedAt: completedAt,
      );

      expect(result.topicId, 'functions');
      expect(result.progressCompletedAt, completedAt);
      expect(result.completedInitialPracticeCount, 0);
      expect(result.firstPracticeCompletedAt, isNull);
      expect(result.lastPracticeCompletedAt, isNull);
    });

    test('rejects an already completed Progress lifecycle', () {
      final completedAt = DateTime.utc(2026, 8, 29);
      final completedLifecycle = completeProgress(
        lifecycle: incompleteLifecycle(),
        completedAt: completedAt,
      );

      expect(
        () => completeProgress(
          lifecycle: completedLifecycle,
          completedAt: DateTime.utc(2026, 8, 30),
        ),
        throwsStateError,
      );
    });
  });
}
