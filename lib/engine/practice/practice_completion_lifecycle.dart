import '../../domain/topic_learning_lifecycle.dart';

TopicLearningLifecycle completePractice({
  required TopicLearningLifecycle lifecycle,
  required DateTime completedAt,
}) {
  if (lifecycle.completedInitialPracticeCount >= 4) {
    throw StateError(
      'Initial Practice lifecycle is already complete.',
    );
  }

  final isFirstPractice =
      lifecycle.completedInitialPracticeCount == 0;

  return TopicLearningLifecycle(
    topicId: lifecycle.topicId,
    progressCompletedAt: lifecycle.progressCompletedAt,
    completedInitialPracticeCount:
        lifecycle.completedInitialPracticeCount + 1,
    firstPracticeCompletedAt: isFirstPractice
        ? completedAt
        : lifecycle.firstPracticeCompletedAt,
    lastPracticeCompletedAt: completedAt,
    completedReinforcementCount:
        lifecycle.completedReinforcementCount,
    lastReinforcementCompletedAt:
        lifecycle.lastReinforcementCompletedAt,
  );
}