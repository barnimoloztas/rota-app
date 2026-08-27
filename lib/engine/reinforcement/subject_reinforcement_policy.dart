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

SubjectReinforcementEvaluation evaluateSubjectReinforcement({
  required SubjectReinforcementLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  final cadence = subjectReinforcementCadenceFor(lifecycle.subjectId);

  if (lifecycle.completedInitialReinforcementCount == 0) {
    final firstDueAt = lifecycle.startedAt.add(
      Duration(days: cadence.firstDueAfterDays),
    );

    if (evaluatedAt.isBefore(firstDueAt)) {
      return const SubjectReinforcementEvaluation(isDue: false, type: null);
    }

    return const SubjectReinforcementEvaluation(
      isDue: true,
      type: SubjectReinforcementType.topicReinforcement,
    );
  }

  final nextDueAt = lifecycle.lastReinforcementCompletedAt!.add(
    Duration(days: cadence.repeatEveryDays),
  );

  if (evaluatedAt.isBefore(nextDueAt)) {
    return const SubjectReinforcementEvaluation(isDue: false, type: null);
  }

  final type =
      lifecycle.completedInitialReinforcementCount <
          cadence.topicReinforcementCount
      ? SubjectReinforcementType.topicReinforcement
      : SubjectReinforcementType.branchReinforcement;

  return SubjectReinforcementEvaluation(isDue: true, type: type);
}
