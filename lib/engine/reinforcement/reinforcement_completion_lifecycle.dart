import '../../domain/topic_learning_lifecycle.dart';

TopicLearningLifecycle completeReinforcement({
  required TopicLearningLifecycle lifecycle,
  required DateTime completedAt,
}) {
  if (lifecycle.completedReinforcementCount >= 3) {
    throw StateError(
      'Topic Reinforcement lifecycle is already complete.',
    );
  }

  return TopicLearningLifecycle(
    topicId: lifecycle.topicId,
    progressCompletedAt: lifecycle.progressCompletedAt,
    completedInitialPracticeCount:
        lifecycle.completedInitialPracticeCount,
    firstPracticeCompletedAt:
        lifecycle.firstPracticeCompletedAt,
    lastPracticeCompletedAt:
        lifecycle.lastPracticeCompletedAt,
    completedReinforcementCount:
        lifecycle.completedReinforcementCount + 1,
    lastReinforcementCompletedAt: completedAt,
  );
}