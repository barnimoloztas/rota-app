import '../../domain/topic_learning_lifecycle.dart';

TopicLearningLifecycle completeProgress({
  required TopicLearningLifecycle lifecycle,
  required DateTime completedAt,
}) {
  if (lifecycle.progressCompletedAt != null) {
    throw StateError('Progress lifecycle is already complete.');
  }

  return TopicLearningLifecycle(
    topicId: lifecycle.topicId,
    progressCompletedAt: completedAt,
    completedInitialPracticeCount: lifecycle.completedInitialPracticeCount,
    firstPracticeCompletedAt: lifecycle.firstPracticeCompletedAt,
    lastPracticeCompletedAt: lifecycle.lastPracticeCompletedAt,
  );
}
