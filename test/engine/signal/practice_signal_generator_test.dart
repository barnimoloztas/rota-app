import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/practice_signal.dart';
import 'package:rota_app/domain/topic.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/signal/practice_signal_generator.dart';

void main() {
  TopicLearningLifecycle lifecycle({
    required TopicId topicId,
    required DateTime? progressCompletedAt,
    required int completedInitialPracticeCount,
    required DateTime? firstPracticeCompletedAt,
    required DateTime? lastPracticeCompletedAt,
  }) {
return TopicLearningLifecycle(
  topicId: topicId,
  progressCompletedAt: progressCompletedAt,
  completedInitialPracticeCount: completedInitialPracticeCount,
  firstPracticeCompletedAt: firstPracticeCompletedAt,
  lastPracticeCompletedAt: lastPracticeCompletedAt,
);
  }

  group('generatePracticeSignals', () {
    test('does not generate practice before progress completion', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: null,
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 10),
      );

      expect(result, isEmpty);
    });

    test('generates P1 on progress completion day', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 10),
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
      expect(
        result.first.reason,
        PracticeSignalReason.initialPractice,
      );
      expect(result.first.strength, 0.0);
    });

    test('P1 remains available after its target day', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 15),
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        PracticeSignalReason.initialPractice,
      );
    });

    test('does not generate P2 on same day as P1 completion', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 10),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 10),
      );

      expect(result, isEmpty);
    });

    test('generates P2 one day after P1 completion', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 10),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 11),
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        PracticeSignalReason.practiceDevelopment,
      );
      expect(result.first.strength, 0.0);
    });

    test('generates P3 after two completed practices', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 2,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 12),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 13),
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        PracticeSignalReason.practiceDevelopment,
      );
    });

    test('generates P4 after three completed practices', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 3,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 10),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 14),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 15),
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        PracticeSignalReason.practiceDevelopment,
      );
    });

    test('overdue next practice remains available', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 1),
            completedInitialPracticeCount: 2,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 3),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 10),
      );

      expect(result, hasLength(1));
      expect(
        result.first.reason,
        PracticeSignalReason.practiceDevelopment,
      );
    });

    test('does not generate initial practice after P4 is completed', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 1),
            completedInitialPracticeCount: 4,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 7),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 20),
      );

      expect(result, isEmpty);
    });

    test('can generate practice signals for multiple topics', () {
      final result = generatePracticeSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            progressCompletedAt: DateTime.utc(2026, 8, 10),
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
          ),
          lifecycle(
            topicId: 'turev',
            progressCompletedAt: DateTime.utc(2026, 8, 8),
            completedInitialPracticeCount: 2,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 8),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 10),
          ),
          lifecycle(
            topicId: 'integral',
            progressCompletedAt: null,
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 11),
      );

      expect(result, hasLength(2));

      expect(
        result.map((signal) => signal.topicId),
        containsAll({
          'fonksiyonlar',
          'turev',
        }),
      );

      expect(
        result.every((signal) => signal.strength == 0.0),
        isTrue,
      );
    });
  });
}