import '../../domain/subject_reinforcement_lifecycle.dart';

enum SubjectReinforcementType {
  topicReinforcement,
  branchReinforcement,
}

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
  if (lifecycle.completedInitialReinforcementCount == 0) {
    final firstDueAt = lifecycle.startedAt.add(
      const Duration(days: 14),
    );

    if (evaluatedAt.isBefore(firstDueAt)) {
      return const SubjectReinforcementEvaluation(
        isDue: false,
        type: null,
      );
    }

    return const SubjectReinforcementEvaluation(
      isDue: true,
      type: SubjectReinforcementType.topicReinforcement,
    );
  }

  final nextDueAt = lifecycle.lastReinforcementCompletedAt!.add(
    const Duration(days: 7),
  );

  if (evaluatedAt.isBefore(nextDueAt)) {
    return const SubjectReinforcementEvaluation(
      isDue: false,
      type: null,
    );
  }

  final type = lifecycle.completedInitialReinforcementCount < 3
      ? SubjectReinforcementType.topicReinforcement
      : SubjectReinforcementType.branchReinforcement;

  return SubjectReinforcementEvaluation(
    isDue: true,
    type: type,
  );
}