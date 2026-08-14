import 'prerequisite_graph.dart';

enum GraphValidationErrorType {
  duplicateTopicId,
  duplicateEdge,
  missingPrerequisiteTopic,
  missingTargetTopic,
  selfEdge,
  missingVersion,
  cycleDetected,
}

class GraphValidationError {
  const GraphValidationError({
    required this.type,
    required this.message,
  });

  final GraphValidationErrorType type;
  final String message;
}

List<GraphValidationError> validateGraph(PrerequisiteGraph graph) {
  final errors = <GraphValidationError>[];

  if (graph.version.trim().isEmpty) {
    errors.add(
      const GraphValidationError(
        type: GraphValidationErrorType.missingVersion,
        message: 'Graph version must not be empty.',
      ),
    );
  }

  final topicIds = <String>{};

  for (final topic in graph.topics) {
    if (!topicIds.add(topic.id)) {
      errors.add(
        GraphValidationError(
          type: GraphValidationErrorType.duplicateTopicId,
          message: 'Duplicate topic id: ${topic.id}',
        ),
      );
    }
  }

  final edgeKeys = <String>{};

  for (final edge in graph.edges) {
    if (edge.prerequisiteTopicId == edge.targetTopicId) {
      errors.add(
        GraphValidationError(
          type: GraphValidationErrorType.selfEdge,
          message:
              'Topic cannot be its own prerequisite: ${edge.targetTopicId}',
        ),
      );
    }

    if (!topicIds.contains(edge.prerequisiteTopicId)) {
      errors.add(
        GraphValidationError(
          type: GraphValidationErrorType.missingPrerequisiteTopic,
          message:
              'Prerequisite topic not found: ${edge.prerequisiteTopicId}',
        ),
      );
    }

    if (!topicIds.contains(edge.targetTopicId)) {
      errors.add(
        GraphValidationError(
          type: GraphValidationErrorType.missingTargetTopic,
          message: 'Target topic not found: ${edge.targetTopicId}',
        ),
      );
    }

    final edgeKey =
        '${edge.prerequisiteTopicId}->${edge.targetTopicId}:${edge.type.name}';

    if (!edgeKeys.add(edgeKey)) {
      errors.add(
        GraphValidationError(
          type: GraphValidationErrorType.duplicateEdge,
          message:
              'Duplicate edge: ${edge.prerequisiteTopicId} -> '
              '${edge.targetTopicId} (${edge.type.name})',
        ),
      );
    }
  }

  if (_hasCycle(graph)) {
    errors.add(
      const GraphValidationError(
        type: GraphValidationErrorType.cycleDetected,
        message: 'Prerequisite graph contains a cycle.',
      ),
    );
  }

  return errors;
}

bool _hasCycle(PrerequisiteGraph graph) {
  final adjacency = <String, List<String>>{};

  for (final topic in graph.topics) {
    adjacency[topic.id] = <String>[];
  }

  for (final edge in graph.edges) {
    if (adjacency.containsKey(edge.prerequisiteTopicId) &&
        adjacency.containsKey(edge.targetTopicId)) {
      adjacency[edge.prerequisiteTopicId]!.add(edge.targetTopicId);
    }
  }

  final visiting = <String>{};
  final visited = <String>{};

  bool visit(String topicId) {
    if (visiting.contains(topicId)) {
      return true;
    }

    if (visited.contains(topicId)) {
      return false;
    }

    visiting.add(topicId);

    for (final nextTopicId in adjacency[topicId] ?? const <String>[]) {
      if (visit(nextTopicId)) {
        return true;
      }
    }

    visiting.remove(topicId);
    visited.add(topicId);

    return false;
  }

  for (final topicId in adjacency.keys) {
    if (visit(topicId)) {
      return true;
    }
  }

  return false;
}