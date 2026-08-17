import 'topic.dart';

class TopicLearningLifecycle {
  const TopicLearningLifecycle({
    required this.topicId,
    required this.progressCompletedAt,
    required this.completedInitialPracticeCount,
    required this.firstPracticeCompletedAt,
    required this.lastPracticeCompletedAt,
    required this.completedReinforcementCount,
    required this.lastReinforcementCompletedAt,
  })  : assert(
          completedInitialPracticeCount >= 0 &&
              completedInitialPracticeCount <= 4,
        ),
        assert(
          completedReinforcementCount >= 0 &&
              completedReinforcementCount <= 3,
        ),
        assert(
          completedInitialPracticeCount == 0
              ? firstPracticeCompletedAt == null &&
                  lastPracticeCompletedAt == null
              : firstPracticeCompletedAt != null &&
                  lastPracticeCompletedAt != null,
        ),
        assert(
          completedReinforcementCount == 0
              ? lastReinforcementCompletedAt == null
              : lastReinforcementCompletedAt != null,
        ),
        assert(
          completedReinforcementCount == 0 ||
              completedInitialPracticeCount >= 1,
        ),
        assert(
          completedInitialPracticeCount == 0 ||
              progressCompletedAt != null,
        );

  final TopicId topicId;

  /// When the topic's Progress work was completed.
  ///
  /// Null means Progress has not been completed yet.
  final DateTime? progressCompletedAt;

  final int completedInitialPracticeCount;

  final DateTime? firstPracticeCompletedAt;

  final DateTime? lastPracticeCompletedAt;

  final int completedReinforcementCount;

  final DateTime? lastReinforcementCompletedAt;
}