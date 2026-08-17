import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';

void main() {
  group('SubjectReinforcementLifecycle', () {
    test('stores a newly started subject reinforcement lifecycle', () {
      final startedAt = DateTime.utc(2026, 8, 17);

      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: startedAt,
        completedInitialReinforcementCount: 0,
        lastReinforcementCompletedAt: null,
      );

      expect(lifecycle.subjectId, 'mathematics');
      expect(lifecycle.startedAt, startedAt);
      expect(lifecycle.completedInitialReinforcementCount, 0);
      expect(lifecycle.lastReinforcementCompletedAt, isNull);
    });

    test('stores lifecycle after an initial reinforcement completion', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 2,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 22),
      );

      expect(lifecycle.completedInitialReinforcementCount, 2);
      expect(
        lifecycle.lastReinforcementCompletedAt,
        DateTime.utc(2026, 8, 22),
      );
    });

    test('stores lifecycle after entering branch reinforcement phase', () {
      final lifecycle = SubjectReinforcementLifecycle(
        subjectId: 'mathematics',
        startedAt: DateTime.utc(2026, 8, 1),
        completedInitialReinforcementCount: 3,
        lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
      );

      expect(lifecycle.completedInitialReinforcementCount, 3);
      expect(
        lifecycle.lastReinforcementCompletedAt,
        DateTime.utc(2026, 8, 29),
      );
    });

    test('rejects initial reinforcement count below zero', () {
      expect(
        () => SubjectReinforcementLifecycle(
          subjectId: 'mathematics',
          startedAt: DateTime.utc(2026, 8, 1),
          completedInitialReinforcementCount: -1,
          lastReinforcementCompletedAt: null,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('rejects initial reinforcement count above three', () {
      expect(
        () => SubjectReinforcementLifecycle(
          subjectId: 'mathematics',
          startedAt: DateTime.utc(2026, 8, 1),
          completedInitialReinforcementCount: 4,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}