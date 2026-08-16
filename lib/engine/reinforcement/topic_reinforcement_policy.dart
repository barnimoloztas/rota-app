import '../../domain/topic_learning_lifecycle.dart';

enum TopicReinforcementStep {
  r1,
  r2,
  r3,
  completed,
}

class TopicReinforcementEvaluation {
  const TopicReinforcementEvaluation({
    required this.isDue,
    required this.nextStep,
  });

  final bool isDue;
  final TopicReinforcementStep nextStep;
}

TopicReinforcementEvaluation evaluateTopicReinforcement({
  required TopicLearningLifecycle lifecycle,
  required DateTime evaluatedAt,
}) {
  if (lifecycle.completedInitialPracticeCount == 0) {
    return const TopicReinforcementEvaluation(
      isDue: false,
      nextStep: TopicReinforcementStep.r1,
    );
  }

  if (lifecycle.completedReinforcementCount >= 3) {
    return const TopicReinforcementEvaluation(
      isDue: false,
      nextStep: TopicReinforcementStep.completed,
    );
  }

  final nextStep = switch (lifecycle.completedReinforcementCount) {
    0 => TopicReinforcementStep.r1,
    1 => TopicReinforcementStep.r2,
    2 => TopicReinforcementStep.r3,
    _ => TopicReinforcementStep.completed,
  };

  if (lifecycle.completedReinforcementCount == 0) {
    final firstPracticeCompletedAt = lifecycle.firstPracticeCompletedAt!;

    final firstReinforcementDueAt = firstPracticeCompletedAt.add(
      const Duration(days: 7),
    );

    return TopicReinforcementEvaluation(
      isDue: !evaluatedAt.isBefore(firstReinforcementDueAt),
      nextStep: nextStep,
    );
  }

  final lastReinforcementCompletedAt =
      lifecycle.lastReinforcementCompletedAt!;

  final nextReinforcementDueAt = lastReinforcementCompletedAt.add(
    const Duration(days: 7),
  );

  return TopicReinforcementEvaluation(
    isDue: !evaluatedAt.isBefore(nextReinforcementDueAt),
    nextStep: nextStep,
  );
}