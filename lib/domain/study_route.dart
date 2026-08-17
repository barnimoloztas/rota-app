import 'topic.dart';

enum StudyTaskType {
  progress,
  practice,
  repair,
  measurement,
  bridge,
}

class StudyTask {
  const StudyTask({
    required this.topicId,
    required this.type,
    required this.sourceTopicId,
    this.questionTarget,
  });

  final TopicId topicId;

  final StudyTaskType type;

  final TopicId sourceTopicId;

  final int? questionTarget;
}

class StudyRoute {
  const StudyRoute({
    required this.tasks,
  });

  final List<StudyTask> tasks;
}