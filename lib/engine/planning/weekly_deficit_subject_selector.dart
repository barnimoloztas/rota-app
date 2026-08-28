import '../../domain/subject.dart';
import '../../domain/subject_study_route.dart';

SubjectStudyRoute? selectNextSubjectByWeeklyDeficit({
  required Iterable<SubjectStudyRoute> subjectRoutes,
  required Map<SubjectId, double> targetWeightsBySubject,
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

  final totalAllocatedSlots = allocatedSlotsBySubject.values.fold(
    0,
    (total, allocatedSlots) => total + allocatedSlots,
  );
  final nextSlotNumber = totalAllocatedSlots + 1;

  SubjectStudyRoute? selectedRoute;
  double? selectedDeficit;

  for (final route in subjectRoutes) {
    if (route.tasks.isEmpty) {
      continue;
    }

    final targetWeight = targetWeightsBySubject[route.subjectId];

    if (targetWeight == null || !targetWeight.isFinite || targetWeight <= 0) {
      throw ArgumentError.value(
        targetWeight,
        'targetWeightsBySubject[${route.subjectId}]',
        'An eligible subject must have a positive finite target weight.',
      );
    }

    final allocatedSlots = allocatedSlotsBySubject[route.subjectId] ?? 0;
    final deficit = (nextSlotNumber * targetWeight) - allocatedSlots;

    final hasHigherDeficit =
        selectedDeficit == null || deficit > selectedDeficit;
    final winsDeterministicTie =
        selectedDeficit != null &&
        deficit == selectedDeficit &&
        route.subjectId.compareTo(selectedRoute!.subjectId) < 0;

    if (hasHigherDeficit || winsDeterministicTie) {
      selectedRoute = route;
      selectedDeficit = deficit;
    }
  }

  return selectedRoute;
}
