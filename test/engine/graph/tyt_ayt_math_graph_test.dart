import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/prerequisite.dart';
import 'package:rota_app/engine/graph/tyt_ayt_math_graph.dart';
import 'package:rota_app/engine/graph/validate_graph.dart';

void main() {
  group('tytAytMathGraph', () {
    test('has the expected topic count', () {
      expect(tytAytMathGraph.topics, hasLength(38));
    });

    test('has the expected edge count', () {
      expect(tytAytMathGraph.edges, hasLength(51));
    });

    test('has the expected hard prerequisite count', () {
      final hardEdges = tytAytMathGraph.edges
          .where((edge) => edge.type == PrerequisiteType.hard)
          .toList();

      expect(hardEdges, hasLength(37));
    });

    test('has the expected soft prerequisite count', () {
      final softEdges = tytAytMathGraph.edges
          .where((edge) => edge.type == PrerequisiteType.soft)
          .toList();

      expect(softEdges, hasLength(14));
    });

    test('has exactly two cross-domain edges', () {
      final crossDomainEdges = tytAytMathGraph.edges
          .where((edge) => edge.isCrossDomain)
          .toList();

      expect(crossDomainEdges, hasLength(2));
    });

    test('marks triangles to trigonometry as cross-domain', () {
      final edge = tytAytMathGraph.edges.singleWhere(
        (edge) =>
            edge.prerequisiteTopicId == 'ucgenler' &&
            edge.targetTopicId == 'trigonometri',
      );

      expect(edge.isCrossDomain, isTrue);
      expect(edge.type, PrerequisiteType.soft);
    });

    test('marks functions to analytic geometry as cross-domain', () {
      final edge = tytAytMathGraph.edges.singleWhere(
        (edge) =>
            edge.prerequisiteTopicId == 'fonksiyonlar' &&
            edge.targetTopicId == 'analitik_geometri',
      );

      expect(edge.isCrossDomain, isTrue);
      expect(edge.type, PrerequisiteType.hard);
    });

    test('passes graph validation with no errors', () {
      final errors = validateGraph(tytAytMathGraph);

      expect(errors, isEmpty);
    });
  });
}