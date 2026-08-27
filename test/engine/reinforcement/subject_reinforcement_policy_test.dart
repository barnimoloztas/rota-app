import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/subject_reinforcement_lifecycle.dart';
import 'package:rota_app/engine/reinforcement/subject_reinforcement_policy.dart';

void main() {
  SubjectReinforcementLifecycle lifecycle({
    String subjectId = 'mathematics',
    required int completedInitialReinforcementCount,
    required DateTime? lastReinforcementCompletedAt,
  }) {
    return SubjectReinforcementLifecycle(
      subjectId: subjectId,
      startedAt: DateTime.utc(2026, 8, 1),
      completedInitialReinforcementCount: completedInitialReinforcementCount,
      lastReinforcementCompletedAt: lastReinforcementCompletedAt,
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
      expect(result.type, SubjectReinforcementType.topicReinforcement);
    });

    test('generates topic reinforcement R2 seven days after R1', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 1,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 15),
        ),
        evaluatedAt: DateTime.utc(2026, 8, 22),
      );

      expect(result.isDue, isTrue);
      expect(result.type, SubjectReinforcementType.topicReinforcement);
    });

    test('generates topic reinforcement R3 seven days after R2', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 2,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 22),
        ),
        evaluatedAt: DateTime.utc(2026, 8, 29),
      );

      expect(result.isDue, isTrue);
      expect(result.type, SubjectReinforcementType.topicReinforcement);
    });

    test('generates branch reinforcement seven days after R3', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 3,
          lastReinforcementCompletedAt: DateTime.utc(2026, 8, 29),
        ),
        evaluatedAt: DateTime.utc(2026, 9, 5),
      );

      expect(result.isDue, isTrue);
      expect(result.type, SubjectReinforcementType.branchReinforcement);
    });

    test('continues weekly branch reinforcement after branch completion', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 3,
          lastReinforcementCompletedAt: DateTime.utc(2026, 9, 5),
        ),
        evaluatedAt: DateTime.utc(2026, 9, 12),
      );

      expect(result.isDue, isTrue);
      expect(result.type, SubjectReinforcementType.branchReinforcement);
    });

    test('does not generate next reinforcement before seven days', () {
      final result = evaluateSubjectReinforcement(
        lifecycle: lifecycle(
          completedInitialReinforcementCount: 3,
          lastReinforcementCompletedAt: DateTime.utc(2026, 9, 5),
        ),
        evaluatedAt: DateTime.utc(2026, 9, 11),
      );

      expect(result.isDue, isFalse);
      expect(result.type, isNull);
    });

    final nonMathematicsCadences =
        <({String subjectId, int firstDueAfterDays, int repeatEveryDays})>[
          (subjectId: 'physics', firstDueAfterDays: 14, repeatEveryDays: 14),
          (subjectId: 'chemistry', firstDueAfterDays: 21, repeatEveryDays: 21),
          (subjectId: 'biology', firstDueAfterDays: 30, repeatEveryDays: 30),
          (subjectId: 'turkish', firstDueAfterDays: 21, repeatEveryDays: 21),
        ];

    for (final cadence in nonMathematicsCadences) {
      test(
        '${cadence.subjectId} uses its cadence and enters branch after R2',
        () {
          final startedAt = DateTime.utc(2026, 1, 1);
          final beforeFirstDue = evaluateSubjectReinforcement(
            lifecycle: SubjectReinforcementLifecycle(
              subjectId: cadence.subjectId,
              startedAt: startedAt,
              completedInitialReinforcementCount: 0,
              lastReinforcementCompletedAt: null,
            ),
            evaluatedAt: startedAt.add(
              Duration(days: cadence.firstDueAfterDays - 1),
            ),
          );

          expect(beforeFirstDue.isDue, isFalse);
          expect(beforeFirstDue.type, isNull);

          final firstDue = evaluateSubjectReinforcement(
            lifecycle: SubjectReinforcementLifecycle(
              subjectId: cadence.subjectId,
              startedAt: startedAt,
              completedInitialReinforcementCount: 0,
              lastReinforcementCompletedAt: null,
            ),
            evaluatedAt: startedAt.add(
              Duration(days: cadence.firstDueAfterDays),
            ),
          );

          expect(firstDue.isDue, isTrue);
          expect(firstDue.type, SubjectReinforcementType.topicReinforcement);

          final r1CompletedAt = DateTime.utc(2026, 3, 1);
          final beforeR2 = evaluateSubjectReinforcement(
            lifecycle: SubjectReinforcementLifecycle(
              subjectId: cadence.subjectId,
              startedAt: startedAt,
              completedInitialReinforcementCount: 1,
              lastReinforcementCompletedAt: r1CompletedAt,
            ),
            evaluatedAt: r1CompletedAt.add(
              Duration(days: cadence.repeatEveryDays - 1),
            ),
          );

          expect(beforeR2.isDue, isFalse);
          expect(beforeR2.type, isNull);

          final r2 = evaluateSubjectReinforcement(
            lifecycle: SubjectReinforcementLifecycle(
              subjectId: cadence.subjectId,
              startedAt: startedAt,
              completedInitialReinforcementCount: 1,
              lastReinforcementCompletedAt: r1CompletedAt,
            ),
            evaluatedAt: r1CompletedAt.add(
              Duration(days: cadence.repeatEveryDays),
            ),
          );

          expect(r2.isDue, isTrue);
          expect(r2.type, SubjectReinforcementType.topicReinforcement);

          final r2CompletedAt = DateTime.utc(2026, 4, 1);
          final branch = evaluateSubjectReinforcement(
            lifecycle: SubjectReinforcementLifecycle(
              subjectId: cadence.subjectId,
              startedAt: startedAt,
              completedInitialReinforcementCount: 2,
              lastReinforcementCompletedAt: r2CompletedAt,
            ),
            evaluatedAt: r2CompletedAt.add(
              Duration(days: cadence.repeatEveryDays),
            ),
          );

          expect(branch.isDue, isTrue);
          expect(branch.type, SubjectReinforcementType.branchReinforcement);
        },
      );
    }
  });
}
