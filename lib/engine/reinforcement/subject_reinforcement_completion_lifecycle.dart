import '../../domain/subject_reinforcement_lifecycle.dart';
import 'subject_reinforcement_cadence.dart';

SubjectReinforcementLifecycle completeSubjectReinforcement({
  required SubjectReinforcementLifecycle lifecycle,
  required DateTime completedAt,
}) {
  final cadence = subjectReinforcementCadenceFor(lifecycle.subjectId);
  final nextInitialCount =
      lifecycle.completedInitialReinforcementCount <
          cadence.topicReinforcementCount
      ? lifecycle.completedInitialReinforcementCount + 1
      : lifecycle.completedInitialReinforcementCount;

  return SubjectReinforcementLifecycle(
    subjectId: lifecycle.subjectId,
    startedAt: lifecycle.startedAt,
    completedInitialReinforcementCount: nextInitialCount,
    lastReinforcementCompletedAt: completedAt,
  );
}
