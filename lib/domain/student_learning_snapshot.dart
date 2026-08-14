import 'student_topic_state.dart';

class StudentLearningSnapshot {
  const StudentLearningSnapshot({
    required this.graphVersion,
    required this.calculatedAt,
    required this.topicStates,
  });

  /// Graph version this snapshot was calculated against.
  final String graphVersion;

  /// Time at which the snapshot was calculated.
  final DateTime calculatedAt;

  /// Current state of each topic, keyed by TopicId.
  final Map<String, StudentTopicState> topicStates;
}