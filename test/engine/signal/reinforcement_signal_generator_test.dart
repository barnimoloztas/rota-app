import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/reinforcement_signal.dart';
import 'package:rota_app/domain/topic.dart';
import 'package:rota_app/domain/topic_learning_lifecycle.dart';
import 'package:rota_app/engine/signal/reinforcement_signal_generator.dart';

void main() {
  TopicLearningLifecycle lifecycle({
    required TopicId topicId,
    required int completedInitialPracticeCount,
    required DateTime? firstPracticeCompletedAt,
    required DateTime? lastPracticeCompletedAt,
    required int completedReinforcementCount,
    required DateTime? lastReinforcementCompletedAt,
  }) {
    return TopicLearningLifecycle(
      topicId: topicId,
      completedInitialPracticeCount: completedInitialPracticeCount,
      firstPracticeCompletedAt: firstPracticeCompletedAt,
      lastPracticeCompletedAt: lastPracticeCompletedAt,
      completedReinforcementCount: completedReinforcementCount,
      lastReinforcementCompletedAt: lastReinforcementCompletedAt,
    );
  }

  group('generateReinforcementSignals', () {
    test('does not generate reinforcement before first practice', () {
      final result = generateReinforcementSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
            completedReinforcementCount: 0,
            lastReinforcementCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 14),
      );

      expect(result, isEmpty);
    });

    test('does not generate first reinforcement before 14 days', () {
      final firstPracticeCompletedAt = DateTime.utc(2026, 8, 1);

      final result = generateReinforcementSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: firstPracticeCompletedAt,
            lastPracticeCompletedAt: firstPracticeCompletedAt,
            completedReinforcementCount: 0,
            lastReinforcementCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 14),
      );

      expect(result, isEmpty);
    });

    test('generates first reinforcement at 14 days', () {
      final firstPracticeCompletedAt = DateTime.utc(2026, 8, 1);

      final result = generateReinforcementSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: firstPracticeCompletedAt,
            lastPracticeCompletedAt: firstPracticeCompletedAt,
            completedReinforcementCount: 0,
            lastReinforcementCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 15),
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
      expect(
        result.first.reason,
        ReinforcementSignalReason.masteryMaintenance,
      );
      expect(result.first.strength, 0.0);
    });

    test(
      'does not generate next reinforcement immediately after completion',
      () {
        final result = generateReinforcementSignals(
          lifecycles: [
            lifecycle(
              topicId: 'fonksiyonlar',
              completedInitialPracticeCount: 4,
              firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
              lastPracticeCompletedAt: DateTime.utc(2026, 8, 7),
              completedReinforcementCount: 1,
              lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
            ),
          ],
          evaluatedAt: DateTime.utc(2026, 8, 15),
        );

        expect(result, isEmpty);
      },
    );

    test('generates next reinforcement 7 days after previous completion', () {
      final result = generateReinforcementSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 4,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 7),
            completedReinforcementCount: 1,
            lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 22),
      );

      expect(result, hasLength(1));
      expect(result.first.topicId, 'fonksiyonlar');
      expect(result.first.strength, 0.0);
    });

    test('does not generate reinforcement after three completions', () {
      final result = generateReinforcementSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 4,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 7),
            completedReinforcementCount: 3,
            lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 9, 20),
      );

      expect(result, isEmpty);
    });

    test('can generate due reinforcement signals for multiple topics', () {
      final result = generateReinforcementSignals(
        lifecycles: [
          lifecycle(
            topicId: 'fonksiyonlar',
            completedInitialPracticeCount: 1,
            firstPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            lastPracticeCompletedAt: DateTime.utc(2026, 8, 1),
            completedReinforcementCount: 0,
            lastReinforcementCompletedAt: null,
          ),
          lifecycle(
            topicId: 'turev',
            completedInitialPracticeCount: 4,
            firstPracticeCompletedAt: DateTime.utc(2026, 7, 20),
            lastPracticeCompletedAt: DateTime.utc(2026, 7, 26),
            completedReinforcementCount: 1,
            lastReinforcementCompletedAt: DateTime.utc(2026, 8, 8),
          ),
          lifecycle(
            topicId: 'integral',
            completedInitialPracticeCount: 0,
            firstPracticeCompletedAt: null,
            lastPracticeCompletedAt: null,
            completedReinforcementCount: 0,
            lastReinforcementCompletedAt: null,
          ),
        ],
        evaluatedAt: DateTime.utc(2026, 8, 15),
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