import '../../domain/daily_plan_draft.dart';
import '../../domain/subject.dart';
import '../../domain/subject_reinforcement_task.dart';

Map<SubjectId, int> accumulateDailyPlanAllocations({
  required Map<SubjectId, int> allocatedSlotsBySubject,
  required DailyPlanDraft dailyPlan,
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

  final updatedAllocations = Map<SubjectId, int>.of(allocatedSlotsBySubject);

  void allocate(SubjectId subjectId) {
    updatedAllocations.update(
      subjectId,
      (allocatedSlots) => allocatedSlots + 1,
      ifAbsent: () => 1,
    );
  }

  for (final plannedTask in dailyPlan.protectedSubjectTasks) {
    allocate(plannedTask.subjectId);
  }

  for (final plannedTask in dailyPlan.normalSubjectTasks) {
    allocate(plannedTask.subjectId);
  }

  final reinforcementTask = dailyPlan.reinforcement?.task;

  if (reinforcementTask is SubjectReinforcementTask) {
    allocate(reinforcementTask.subjectId);
  }

  return Map<SubjectId, int>.unmodifiable(updatedAllocations);
}
