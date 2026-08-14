import 'topic.dart';

class StudentAddedTask {
  const StudentAddedTask({
    required this.topicId,
    required this.addedAt,
  });

  /// Topic the student explicitly chose to add.
  final TopicId topicId;

  /// Time when the student added the task.
  ///
  /// This is user action metadata, not academic Evidence.
  final DateTime addedAt;
}