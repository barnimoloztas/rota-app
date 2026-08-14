import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/prerequisite.dart';
import 'package:rota_app/domain/topic.dart';
import 'package:rota_app/engine/graph/graph_queries.dart';
import 'package:rota_app/engine/graph/prerequisite_graph.dart';

void main() {
  group('graph queries', () {
    const graph = PrerequisiteGraph(
      version: '1.0.0',
      topics: [
        Topic(id: 'functions', title: 'Fonksiyonlar'),
        Topic(id: 'limits', title: 'Limit'),
        Topic(id: 'derivatives', title: 'Türev'),
        Topic(id: 'polynomials', title: 'Polinomlar'),
      ],
      edges: [
        PrerequisiteEdge(
          prerequisiteTopicId: 'functions',
          targetTopicId: 'limits',
          type: PrerequisiteType.hard,
        ),
        PrerequisiteEdge(
          prerequisiteTopicId: 'polynomials',
          targetTopicId: 'limits',
          type: PrerequisiteType.soft,
        ),
        PrerequisiteEdge(
          prerequisiteTopicId: 'limits',
          targetTopicId: 'derivatives',
          type: PrerequisiteType.hard,
        ),
      ],
    );

    test('returns direct prerequisites only', () {
      final prerequisites = getDirectPrerequisites(
        graph,
        'limits',
      );

      expect(prerequisites, hasLength(2));

      expect(
        prerequisites.any(
          (edge) => edge.prerequisiteTopicId == 'functions',
        ),
        isTrue,
      );

      expect(
        prerequisites.any(
          (edge) => edge.prerequisiteTopicId == 'polynomials',
        ),
        isTrue,
      );
    });

    test('does not return transitive prerequisites as direct prerequisites', () {
      final prerequisites = getDirectPrerequisites(
        graph,
        'derivatives',
      );

      expect(prerequisites, hasLength(1));
      expect(prerequisites.first.prerequisiteTopicId, 'limits');

      expect(
        prerequisites.any(
          (edge) => edge.prerequisiteTopicId == 'functions',
        ),
        isFalse,
      );
    });

    test('returns direct dependents', () {
      final dependents = getDirectDependents(
        graph,
        'limits',
      );

      expect(dependents, hasLength(1));
      expect(dependents.first.targetTopicId, 'derivatives');
    });

    test('returns only hard prerequisites', () {
      final prerequisites = getDirectHardPrerequisites(
        graph,
        'limits',
      );

      expect(prerequisites, hasLength(1));
      expect(prerequisites.first.prerequisiteTopicId, 'functions');
      expect(prerequisites.first.type, PrerequisiteType.hard);
    });

    test('returns only soft prerequisites', () {
      final prerequisites = getDirectSoftPrerequisites(
        graph,
        'limits',
      );

      expect(prerequisites, hasLength(1));
      expect(prerequisites.first.prerequisiteTopicId, 'polynomials');
      expect(prerequisites.first.type, PrerequisiteType.soft);
    });

    test('returns topic when topic id exists', () {
      final topic = getTopicById(
        graph,
        'limits',
      );

      expect(topic, isNotNull);
      expect(topic!.id, 'limits');
      expect(topic.title, 'Limit');
    });

    test('returns null when topic id does not exist', () {
      final topic = getTopicById(
        graph,
        'integrals',
      );

      expect(topic, isNull);
    });
  });
}