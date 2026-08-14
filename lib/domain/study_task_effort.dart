import 'study_route.dart';
import 'topic.dart';

class StudyTaskEffort {
  const StudyTaskEffort({
    required this.topicId,
    required this.taskType,
    required this.estimatedMinutes,
  }) : assert(estimatedMinutes >= 0);

  /// Topic this effort estimate belongs to.
  final TopicId topicId;

  /// Task type this estimate applies to.
  final StudyTaskType taskType;

  /// Estimated effort for this task.
  ///
  /// This is a planning estimate, not recorded study time.
  final int estimatedMinutes;
}