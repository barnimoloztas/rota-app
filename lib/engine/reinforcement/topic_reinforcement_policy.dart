import '../../domain/topic_learning_lifecycle.dart';

class TopicReinforcementEvaluation {
  const TopicReinforcementEvaluation({
    required this.isDue,
  });

  final bool isDue;
}

TopicReinforcementEvaluation evaluateTopicReinforcement({
  required TopicLearningLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  if (lifecycle.completedInitialPracticeCount == 0) {
    return const TopicReinforcementEvaluation(
      isDue: false,
    );
  }

  if (lifecycle.completedReinforcementCount >= 3) {
    return const TopicReinforcementEvaluation(
      isDue: false,
    );
  }

  if (lifecycle.completedReinforcementCount == 0) {
    final firstPracticeCompletedAt = lifecycle.firstPracticeCompletedAt!;

    final firstReinforcementDueAt = firstPracticeCompletedAt.add(
      const Duration(days: 14),
    );

    return TopicReinforcementEvaluation(
      isDue: !evaluatedAt.isBefore(firstReinforcementDueAt),
    );
  }

  final lastReinforcementCompletedAt =
      lifecycle.lastReinforcementCompletedAt!;

  final nextReinforcementDueAt = lastReinforcementCompletedAt.add(
    const Duration(days: 7),
  );

  return TopicReinforcementEvaluation(
    isDue: !evaluatedAt.isBefore(nextReinforcementDueAt),
  );
}