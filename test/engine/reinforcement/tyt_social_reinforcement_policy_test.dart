import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/tyt_social_reinforcement_policy.dart';

void main() {
  group('isTytSocialReinforcementDue', () {
    test('is not due before 45 days from the first social practice', () {
      final lifecycle = TytSocialReinforcementLifecycle(
        startedAt: DateTime.utc(2026, 8, 1),
        lastReinforcementCompletedAt: null,
      );

      final isDue = isTytSocialReinforcementDue(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 9, 14),
      );

      expect(isDue, isFalse);
    });

    test('is due 45 days after the first social practice', () {
      final lifecycle = TytSocialReinforcementLifecycle(
        startedAt: DateTime.utc(2026, 8, 1),
        lastReinforcementCompletedAt: null,
      );

      final isDue = isTytSocialReinforcementDue(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 9, 15),
      );

      expect(isDue, isTrue);
    });

    test('uses the last completion date for the next 45-day cycle', () {
      final lifecycle = TytSocialReinforcementLifecycle(
        startedAt: DateTime.utc(2026, 8, 1),
        lastReinforcementCompletedAt: DateTime.utc(2026, 9, 20),
      );

      final beforeDue = isTytSocialReinforcementDue(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 11, 3),
      );
      final due = isTytSocialReinforcementDue(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 11, 4),
      );

      expect(beforeDue, isFalse);
      expect(due, isTrue);
    });

    test('keeps an uncompleted overdue reinforcement due', () {
      final lifecycle = TytSocialReinforcementLifecycle(
        startedAt: DateTime.utc(2026, 8, 1),
        lastReinforcementCompletedAt: null,
      );

      final isDue = isTytSocialReinforcementDue(
        lifecycle: lifecycle,
        evaluatedAt: DateTime.utc(2026, 10, 20),
      );

      expect(isDue, isTrue);
    });
  });
}
