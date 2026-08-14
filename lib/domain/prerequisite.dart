import 'topic.dart';

enum PrerequisiteType {
  hard,
  soft,
}

class PrerequisiteEdge {
  const PrerequisiteEdge({
    required this.prerequisiteTopicId,
    required this.targetTopicId,
    required this.type,
    this.isCrossDomain = false,
  });

  final TopicId prerequisiteTopicId;
  final TopicId targetTopicId;
  final PrerequisiteType type;
  final bool isCrossDomain;
}