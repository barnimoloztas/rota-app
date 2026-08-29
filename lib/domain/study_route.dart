import 'topic.dart';

enum StudyTaskType { progress, practice, repair, measurement, bridge }

enum StudyTaskPriority { standard, urgent }

class StudyTask {
  const StudyTask({
    required this.topicId,
    required this.type,
    required this.sourceTopicId,
    this.questionTarget,
    this.priority = StudyTaskPriority.standard,
  });

  final TopicId topicId;

  final StudyTaskType type;

  final TopicId sourceTopicId;

  final int? questionTarget;

  final StudyTaskPriority priority;
}

class StudyRoute {
  const StudyRoute({required this.tasks});

  final List<StudyTask> tasks;
}
