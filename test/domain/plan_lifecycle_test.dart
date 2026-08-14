import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/plan_lifecycle.dart';

void main() {
  group('PlanLifecycleRules', () {
    test('untouched draft can refresh and increase task count', () {
      const lifecycle = PlanLifecycle.draftUntouched;

      expect(lifecycle.canRefresh, isTrue);
      expect(
        lifecycle.canIncreaseTaskCountDuringRefresh,
        isTrue,
      );
    });

    test('student-modified draft can refresh but cannot increase task count', () {
      const lifecycle = PlanLifecycle.draftStudentModified;

      expect(lifecycle.canRefresh, isTrue);
      expect(
        lifecycle.canIncreaseTaskCountDuringRefresh,
        isFalse,
      );
    });

    test('active plan cannot refresh', () {
      const lifecycle = PlanLifecycle.active;

      expect(lifecycle.canRefresh, isFalse);
      expect(
        lifecycle.canIncreaseTaskCountDuringRefresh,
        isFalse,
      );
    });

    test('all lifecycle states have deterministic refresh rules', () {
      for (final lifecycle in PlanLifecycle.values) {
        final firstCanRefresh = lifecycle.canRefresh;
        final secondCanRefresh = lifecycle.canRefresh;

        final firstCanIncrease =
            lifecycle.canIncreaseTaskCountDuringRefresh;
        final secondCanIncrease =
            lifecycle.canIncreaseTaskCountDuringRefresh;

        expect(firstCanRefresh, secondCanRefresh);
        expect(firstCanIncrease, secondCanIncrease);
      }
    });
  });
}