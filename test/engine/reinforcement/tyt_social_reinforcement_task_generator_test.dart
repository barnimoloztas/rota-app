import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_lifecycle.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_task.dart';
import 'package:rota_app/engine/reinforcement/tyt_social_reinforcement_task_generator.dart';

void main() {
  group('generateTytSocialReinforcementTask', () {
    test('returns null before the reinforcement is due', () {
      final task = generateTytSocialReinforcementTask(
        lifecycle: TytSocialReinforcementLifecycle(
          startedAt: DateTime.utc(2026, 8, 1),
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: DateTime.utc(2026, 9, 14),
      );

      expect(task, isNull);
    });

    test('generates one common TYT social branch task when due', () {
      final task = generateTytSocialReinforcementTask(
        lifecycle: TytSocialReinforcementLifecycle(
          startedAt: DateTime.utc(2026, 8, 1),
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: DateTime.utc(2026, 9, 15),
      );

      expect(task, isA<TytSocialReinforcementTask>());
    });
  });
}
