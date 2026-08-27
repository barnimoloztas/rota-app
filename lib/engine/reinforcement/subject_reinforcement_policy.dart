import '../../domain/subject_reinforcement_lifecycle.dart';
import 'subject_reinforcement_cadence.dart';

enum SubjectReinforcementType { topicReinforcement, branchReinforcement }

class SubjectReinforcementEvaluation {
  const SubjectReinforcementEvaluation({
    required this.isDue,
    required this.type,
  });

  final bool isDue;
  final SubjectReinforcementType? type;
}

DateTime subjectReinforcementDueAt({
  required SubjectReinforcementLifecycle lifecycle,
}) {
  final cadence = subjectReinforcementCadenceFor(lifecycle.subjectId);

  if (lifecycle.completedInitialReinforcementCount == 0) {
    return lifecycle.startedAt.add(Duration(days: cadence.firstDueAfterDays));
  }

  return lifecycle.lastReinforcementCompletedAt!.add(
    Duration(days: cadence.repeatEveryDays),
  );
}

SubjectReinforcementEvaluation evaluateSubjectReinforcement({
  required SubjectReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  final cadence = subjectReinforcementCadenceFor(lifecycle.subjectId);
  final dueAt = subjectReinforcementDueAt(lifecycle: lifecycle);

  if (lifecycle.completedInitialReinforcementCount == 0) {
    if (evaluatedAt.isBefore(dueAt)) {
      return const SubjectReinforcementEvaluation(isDue: false, type: null);
    }

    return const SubjectReinforcementEvaluation(
      isDue: true,
      type: SubjectReinforcementType.topicReinforcement,
    );
  }

  if (evaluatedAt.isBefore(dueAt)) {
    return const SubjectReinforcementEvaluation(isDue: false, type: null);
  }

  final type =
      lifecycle.completedInitialReinforcementCount <
          cadence.topicReinforcementCount
      ? SubjectReinforcementType.topicReinforcement
      : SubjectReinforcementType.branchReinforcement;

  return SubjectReinforcementEvaluation(isDue: true, type: type);
}
