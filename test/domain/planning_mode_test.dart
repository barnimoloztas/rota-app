import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/planning_mode.dart';

void main() {
  group('resolvePlanningMode', () {
    test('returns normal when no planning signal is active', () {
      const context = PlanningModeContext(
        isPreExam: false,
        isPostExam: false,
        isAvoidanceActive: false,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.normal,
      );
    });

    test('returns preExam when pre-exam signal is active', () {
      const context = PlanningModeContext(
        isPreExam: true,
        isPostExam: false,
        isAvoidanceActive: false,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.preExam,
      );
    });

    test('returns postExam when post-exam signal is active', () {
      const context = PlanningModeContext(
        isPreExam: false,
        isPostExam: true,
        isAvoidanceActive: false,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.postExam,
      );
    });

    test('returns avoidance when only avoidance is active', () {
      const context = PlanningModeContext(
        isPreExam: false,
        isPostExam: false,
        isAvoidanceActive: true,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.avoidance,
      );
    });

    test('preExam overrides avoidance', () {
      const context = PlanningModeContext(
        isPreExam: true,
        isPostExam: false,
        isAvoidanceActive: true,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.preExam,
      );
    });

    test('postExam overrides avoidance', () {
      const context = PlanningModeContext(
        isPreExam: false,
        isPostExam: true,
        isAvoidanceActive: true,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.postExam,
      );
    });

    test('postExam overrides preExam when both are active', () {
      const context = PlanningModeContext(
        isPreExam: true,
        isPostExam: true,
        isAvoidanceActive: false,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.postExam,
      );
    });

    test('postExam remains dominant when all signals are active', () {
      const context = PlanningModeContext(
        isPreExam: true,
        isPostExam: true,
        isAvoidanceActive: true,
      );

      expect(
        resolvePlanningMode(context),
        PlanningMode.postExam,
      );
    });
  });
}