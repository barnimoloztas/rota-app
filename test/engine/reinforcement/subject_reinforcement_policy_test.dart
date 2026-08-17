import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_policy.dart';

void main() {
  SubjectReinforcementLifecycle lifecycle({
    required int completedInitialReinforcementCount,
    required DateTime? lastReinforcementCompletedAt,
  }) {
    return SubjectReinforcementLifecycle(
      subjectId: 'mathematics',
      startedAt: DateTime.utc(2026, 8, 1),
      completedInitialReinforcementCount:
          completedInitialReinforcementCount,
      lastReinforcementCompletedAt:
          lastReinforcementCompletedAt,
    );
  }

  group('evaluateSubjectReinforcement', () {
    test('does not generate R1 before 14 days', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: DateTime.utc(2026, 8, 14),
      );

      expect(result.isDue, isFalse);
      expect(result.type, isNull);
    });

    test('generates topic reinforcement R1 at 14 days', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 0,
          lastReinforcementCompletedAt: null,
        ),
        evaluatedAt: DateTime.utc(2026, 8, 15),
      );

      expect(result.isDue, isTrue);
      expect(
        result.type,
        SubjectReinforcementType.topicReinforcement,
      );
    });

    test('generates topic reinforcement R2 seven days after R1', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 1,
          lastReinforcementCompletedAt:
              DateTime.utc(2026, 8, 15),
        ),
        evaluatedAt: DateTime.utc(2026, 8, 22),
      );

      expect(result.isDue, isTrue);
      expect(
        result.type,
        SubjectReinforcementType.topicReinforcement,
      );
    });

    test('generates topic reinforcement R3 seven days after R2', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 2,
          lastReinforcementCompletedAt:
              DateTime.utc(2026, 8, 22),
        ),
        evaluatedAt: DateTime.utc(2026, 8, 29),
      );

      expect(result.isDue, isTrue);
      expect(
        result.type,
        SubjectReinforcementType.topicReinforcement,
      );
    });

    test('generates branch reinforcement seven days after R3', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 3,
          lastReinforcementCompletedAt:
              DateTime.utc(2026, 8, 29),
        ),
        evaluatedAt: DateTime.utc(2026, 9, 5),
      );

      expect(result.isDue, isTrue);
      expect(
        result.type,
        SubjectReinforcementType.branchReinforcement,
      );
    });

    test('continues weekly branch reinforcement after branch completion', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 3,
          lastReinforcementCompletedAt:
              DateTime.utc(2026, 9, 5),
        ),
        evaluatedAt: DateTime.utc(2026, 9, 12),
      );

      expect(result.isDue, isTrue);
      expect(
        result.type,
        SubjectReinforcementType.branchReinforcement,
      );
    });

    test('does not generate next reinforcement before seven days', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 3,
          lastReinforcementCompletedAt:
              DateTime.utc(2026, 9, 5),
        ),
        evaluatedAt: DateTime.utc(2026, 9, 11),
      );

      expect(result.isDue, isFalse);
      expect(result.type, isNull);
    });
  });
}