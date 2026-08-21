import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/prerequisite.dart';
import 'package:rota_app/domain/topic.dart';
import 'package:rota_app/engine/graph/prerequisite_graph.dart';
import 'package:rota_app/engine/graph/validate_graph.dart';

void main() {
  group('validateGraph', () {
    test('returns no errors for a valid graph', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [
          Topic(id: 'functions', title: 'Fonksiyonlar'),
          Topic(id: 'limits', title: 'Limit'),
        ],
        edges: [
          PrerequisiteEdge(
            prerequisiteTopicId: 'functions',
            targetTopicId: 'limits',
            type: PrerequisiteType.hard,
          ),
        ],
      );

      final errors = validateGraph(graph);

      expect(errors, isEmpty);
    });

    test('detects duplicate topic ids', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [
          Topic(id: 'functions', title: 'Fonksiyonlar'),
          Topic(id: 'functions', title: 'Fonksiyonlar Tekrar'),
        ],
        edges: [],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any(
          (error) => error.type == GraphValidationErrorType.duplicateTopicId,
        ),
        isTrue,
      );
    });

    test('detects duplicate edges', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [
          Topic(id: 'functions', title: 'Fonksiyonlar'),
          Topic(id: 'limits', title: 'Limit'),
        ],
        edges: [
          PrerequisiteEdge(
            prerequisiteTopicId: 'functions',
            targetTopicId: 'limits',
            type: PrerequisiteType.hard,
          ),
          PrerequisiteEdge(
            prerequisiteTopicId: 'functions',
            targetTopicId: 'limits',
            type: PrerequisiteType.hard,
          ),
        ],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any(
          (error) => error.type == GraphValidationErrorType.duplicateEdge,
        ),
        isTrue,
      );
    });

    test('detects missing prerequisite topic', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [Topic(id: 'limits', title: 'Limit')],
        edges: [
          PrerequisiteEdge(
            prerequisiteTopicId: 'functions',
            targetTopicId: 'limits',
            type: PrerequisiteType.hard,
          ),
        ],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any(
          (error) =>
              error.type == GraphValidationErrorType.missingPrerequisiteTopic,
        ),
        isTrue,
      );
    });

    test('detects missing target topic', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [Topic(id: 'functions', title: 'Fonksiyonlar')],
        edges: [
          PrerequisiteEdge(
            prerequisiteTopicId: 'functions',
            targetTopicId: 'limits',
            type: PrerequisiteType.hard,
          ),
        ],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any(
          (error) => error.type == GraphValidationErrorType.missingTargetTopic,
        ),
        isTrue,
      );
    });

    test('detects self edges', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [Topic(id: 'functions', title: 'Fonksiyonlar')],
        edges: [
          PrerequisiteEdge(
            prerequisiteTopicId: 'functions',
            targetTopicId: 'functions',
            type: PrerequisiteType.hard,
          ),
        ],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any((error) => error.type == GraphValidationErrorType.selfEdge),
        isTrue,
      );
    });

    test('detects missing graph version', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '   ',
        topics: [Topic(id: 'functions', title: 'Fonksiyonlar')],
        edges: [],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any(
          (error) => error.type == GraphValidationErrorType.missingVersion,
        ),
        isTrue,
      );
    });

    test('detects cycles', () {
      const graph = PrerequisiteGraph(
        subjectId: 'mathematics',
        version: '1.0.0',
        topics: [
          Topic(id: 'a', title: 'A'),
          Topic(id: 'b', title: 'B'),
          Topic(id: 'c', title: 'C'),
        ],
        edges: [
          PrerequisiteEdge(
            prerequisiteTopicId: 'a',
            targetTopicId: 'b',
            type: PrerequisiteType.hard,
          ),
          PrerequisiteEdge(
            prerequisiteTopicId: 'b',
            targetTopicId: 'c',
            type: PrerequisiteType.hard,
          ),
          PrerequisiteEdge(
            prerequisiteTopicId: 'c',
            targetTopicId: 'a',
            type: PrerequisiteType.hard,
          ),
        ],
      );

      final errors = validateGraph(graph);

      expect(
        errors.any(
          (error) => error.type == GraphValidationErrorType.cycleDetected,
        ),
        isTrue,
      );
    });
  });
}
