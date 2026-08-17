import '../../domain/subject_reinforcement_lifecycle.dart';

SubjectReinforcementLifecycle completeSubjectReinforcement({
  required SubjectReinforcementLifecycle lifecycle,
  required DateTime completedAt,
}) {
  final nextInitialCount =
      lifecycle.completedInitialReinforcementCount < 3
          ? lifecycle.completedInitialReinforcementCount + 1
          : 3;

  return SubjectReinforcementLifecycle(
    subjectId: lifecycle.subjectId,
    startedAt: lifecycle.startedAt,
    completedInitialReinforcementCount: nextInitialCount,
    lastReinforcementCompletedAt: completedAt,
  );
}