import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/tyt_social_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/tyt_social_reinforcement_completion_lifecycle.dart';

void main() {
  test('completion preserves the start and records the completion date', () {
    final startedAt = DateTime.utc(2026, 8, 1);
    final completedAt = DateTime.utc(2026, 9, 15);
    final lifecycle = TytSocialReinforcementLifecycle(
      startedAt: startedAt,
      lastReinforcementCompletedAt: null,
    );

    final result = completeTytSocialReinforcement(
      lifecycle: lifecycle,
      completedAt: completedAt,
    );

    expect(result.startedAt, startedAt);
    expect(result.lastReinforcementCompletedAt, completedAt);
  });
}
