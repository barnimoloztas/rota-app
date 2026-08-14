import '../../domain/prerequisite.dart';
import '../../domain/topic.dart';
import 'prerequisite_graph.dart';

List<PrerequisiteEdge> getDirectPrerequisites(
  PrerequisiteGraph graph,
  TopicId targetTopicId,
) {
  return graph.edges
      .where((edge) => edge.targetTopicId == targetTopicId)
      .toList(growable: false);
}

List<PrerequisiteEdge> getDirectDependents(
  PrerequisiteGraph graph,
  TopicId prerequisiteTopicId,
) {
  return graph.edges
      .where((edge) => edge.prerequisiteTopicId == prerequisiteTopicId)
      .toList(growable: false);
}

List<PrerequisiteEdge> getDirectHardPrerequisites(
  PrerequisiteGraph graph,
  TopicId targetTopicId,
) {
  return getDirectPrerequisites(graph, targetTopicId)
      .where((edge) => edge.type == PrerequisiteType.hard)
      .toList(growable: false);
}

List<PrerequisiteEdge> getDirectSoftPrerequisites(
  PrerequisiteGraph graph,
  TopicId targetTopicId,
) {
  return getDirectPrerequisites(graph, targetTopicId)
      .where((edge) => edge.type == PrerequisiteType.soft)
      .toList(growable: false);
}

Topic? getTopicById(
  PrerequisiteGraph graph,
  TopicId topicId,
) {
  for (final topic in graph.topics) {
    if (topic.id == topicId) {
      return topic;
    }
  }

  return null;
}