import '../../domain/preparation_phase.dart';
import '../../domain/subject.dart';

Map<SubjectId, int> allocationsForPreparationPhase({
  required PreparationPhase planPhase,
  required PreparationPhase allocationPhase,
  required Map<SubjectId, int> allocatedSlotsBySubject,
}) {
  for (final entry in allocatedSlotsBySubject.entries) {
    if (entry.value < 0) {
      throw ArgumentError.value(
        entry.value,
        'allocatedSlotsBySubject[${entry.key}]',
        'Allocated slot count cannot be negative.',
      );
    }
  }

  if (planPhase.index < allocationPhase.index) {
    throw ArgumentError.value(
      planPhase,
      'planPhase',
      'Preparation phase cannot move backwards.',
    );
  }

  if (planPhase != allocationPhase) {
    return const <SubjectId, int>{};
  }

  return Map<SubjectId, int>.unmodifiable(
    Map<SubjectId, int>.of(allocatedSlotsBySubject),
  );
}
