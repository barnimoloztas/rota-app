import 'topic.dart';

enum StudyTaskType {
  progress,
  practice,
  repair,
  reinforcement,
  measurement,
  bridge,
}

class StudyTask {
  const StudyTask({
    required this.topicId,
    required this.type,
    required this.sourceTopicId,
  });

  /// Topic the student will actually work on.
  final TopicId topicId;

  /// Pedagogical role of this task in the route.
  final StudyTaskType type;

  /// Candidate topic that caused this task to exist.
  ///
  /// For a normal task this is usually the same as [topicId].
  /// For a bridge task this is the locked target topic whose
  /// prerequisite created the bridge.
  final TopicId sourceTopicId;
}

class StudyRoute {
  const StudyRoute({
    required this.tasks,
  });

  /// Ordered tasks selected for the study route.
  ///
  /// Ordering is meaningful and must remain deterministic.
  final List<StudyTask> tasks;
}