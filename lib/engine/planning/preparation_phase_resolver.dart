import '../../domain/preparation_phase.dart';

PreparationPhase resolvePreparationPhase({required int daysUntilExam}) {
  if (daysUntilExam < 0) {
    throw ArgumentError.value(
      daysUntilExam,
      'daysUntilExam',
      'Days until exam cannot be negative.',
    );
  }

  if (daysUntilExam <= 90) {
    return PreparationPhase.late;
  }

  if (daysUntilExam <= 180) {
    return PreparationPhase.middle;
  }

  return PreparationPhase.early;
}
