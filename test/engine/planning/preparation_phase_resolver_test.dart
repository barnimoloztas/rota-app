import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/preparation_phase.dart';
import 'package:rota_app/engine/planning/preparation_phase_resolver.dart';

void main() {
  group('resolvePreparationPhase', () {
    test('uses the early phase above 180 days', () {
      expect(
        resolvePreparationPhase(daysUntilExam: 181),
        PreparationPhase.early,
      );
    });

    test('uses the middle phase from 91 through 180 days', () {
      expect(
        resolvePreparationPhase(daysUntilExam: 180),
        PreparationPhase.middle,
      );
      expect(
        resolvePreparationPhase(daysUntilExam: 91),
        PreparationPhase.middle,
      );
    });

    test('uses the late phase from exam day through 90 days', () {
      expect(resolvePreparationPhase(daysUntilExam: 90), PreparationPhase.late);
      expect(resolvePreparationPhase(daysUntilExam: 0), PreparationPhase.late);
    });

    test('rejects a negative day count', () {
      expect(
        () => resolvePreparationPhase(daysUntilExam: -1),
        throwsArgumentError,
      );
    });
  });
}
