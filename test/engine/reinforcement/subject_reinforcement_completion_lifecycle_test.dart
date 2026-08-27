import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_completion_lifecycle.dart';

void main() {
  group('completeSubjectReinforcement', () {
    test('completes R1 and increments initial reinforcement count', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      final completedAt = DateTime.utc(2026, 8, 15);

      final result = completeSubjectReinforcement(
        lifecycle: lifecycle,
        completedAt: completedAt,
      );

      expect(result.completedInitialReinforcementCount, 1);
      expect(result.lastReinforcementCompletedAt, completedAt);
    });

    test('completes R2 and increments initial reinforcement count', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 1,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
      );

      final completedAt = DateTime.utc(2026, 8, 22);

      final result = completeSubjectReinforcement(
        lifecycle: lifecycle,
        completedAt: completedAt,
      );

      expect(result.completedInitialReinforcementCount, 2);
      expect(result.lastReinforcementCompletedAt, completedAt);
    });

    test('completes R3 and enters branch reinforcement phase', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 2,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 22),
      );

      final completedAt = DateTime.utc(2026, 8, 29);

      final result = completeSubjectReinforcement(
        lifecycle: lifecycle,
        completedAt: completedAt,
      );

      expect(result.completedInitialReinforcementCount, 3);
      expect(result.lastReinforcementCompletedAt, completedAt);
    });

    test('branch reinforcement completion keeps initial count at three', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 3,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
      );

      final completedAt = DateTime.utc(2026, 9, 5);

      final result = completeSubjectReinforcement(
        lifecycle: lifecycle,
        completedAt: completedAt,
      );

      expect(result.completedInitialReinforcementCount, 3);
      expect(result.lastReinforcementCompletedAt, completedAt);
    });

    test('non-mathematics branch completion keeps initial count at two', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'physics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 2,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
      );

      final completedAt = DateTime.utc(2026, 9, 12);

      final result = completeSubjectReinforcement(
        lifecycle: lifecycle,
        completedAt: completedAt,
      );

      expect(result.completedInitialReinforcementCount, 2);
      expect(result.lastReinforcementCompletedAt, completedAt);
    });

    test('does not reduce an existing legacy count above subject cadence', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'physics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 3,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
      );

      final result = completeSubjectReinforcement(
        lifecycle: lifecycle,
        completedAt: DateTime.utc(2026, 9, 12),
      );

      expect(result.completedInitialReinforcementCount, 3);
    });
  });
}
