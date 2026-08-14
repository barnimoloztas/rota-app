import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/engine/gate/prerequisite_gate.dart';
import 'package:rota_app/engine/graph/tyt_ayt_math_graph.dart';

void main() {
  const config = PrerequisiteGateConfig(
    minimumConsolidatedConfidence: 0.60,
  );

  StudentTopicState state({
    required String topicId,
    required bool hasEvidence,
    required MasteryBand band,
    required double score,
    required double confidence,
  }) {
    final calculatedAt = DateTime.utc(2026, 8, 14);

    return StudentTopicState(
      topicId: topicId,
      hasEvidence: hasEvidence,
      mastery: Mastery(
        score: score,
        confidence: confidence,
      ),
      masteryBand: band,
      lastMeaningfulEvidenceAt:
          hasEvidence ? DateTime.utc(2026, 8, 13) : null,
      calculatedAt: calculatedAt,
    );
  }

  StudentLearningSnapshot snapshot(
    Map<String, StudentTopicState> states,
  ) {
    return StudentLearningSnapshot(
      graphVersion: tytAytMathGraph.version,
      calculatedAt: DateTime.utc(2026, 8, 14),
      topicStates: states,
    );
  }

  group('PrerequisiteGate', () {
    test('Scenario A - untouched hard prerequisite locks target', () {
      final result = evaluatePrerequisiteGate(
        graph: tytAytMathGraph,
        snapshot: snapshot({}),
        targetTopicId: 'limit_ve_sureklilik',
        config: config,
      );

      expect(result.outcome, GateOutcome.locked);
      expect(
        result.lockedPrerequisiteTopicIds,
        contains('fonksiyonlar'),
      );
    });

    test(
      'Scenario B - learning hard prerequisite requires bridge',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.learning,
              score: 25.0,
              confidence: 0.50,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          config: config,
        );

        expect(result.outcome, GateOutcome.bridgeRequired);
        expect(
          result.bridgePrerequisiteTopicIds,
          contains('fonksiyonlar'),
        );
      },
    );

    test(
      'Scenario C - proficient hard prerequisite still requires bridge',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.proficient,
              score: 85.0,
              confidence: 0.90,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          config: config,
        );

        expect(result.outcome, GateOutcome.bridgeRequired);
      },
    );

    test(
      'Scenario D - consolidated prerequisite with enough confidence opens target',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.80,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          config: config,
        );

        expect(result.outcome, GateOutcome.open);
      },
    );

    test(
      'Scenario E - consolidated prerequisite with low confidence opens with verification',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.30,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          config: config,
        );

        expect(
          result.outcome,
          GateOutcome.openWithVerification,
        );

        expect(
          result.verificationPrerequisiteTopicIds,
          contains('fonksiyonlar'),
        );
      },
    );

    test(
      'Scenario F - weak soft prerequisite does not lock target',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.consolidated,
              score: 90.0,
              confidence: 0.90,
            ),
            'oran_oranti': state(
              topicId: 'oran_oranti',
              hasEvidence: false,
              band: MasteryBand.notStarted,
              score: 0.0,
              confidence: 0.0,
            ),
            'carpanlara_ayirma': state(
              topicId: 'carpanlara_ayirma',
              hasEvidence: false,
              band: MasteryBand.notStarted,
              score: 0.0,
              confidence: 0.0,
            ),
            'ucgenler': state(
              topicId: 'ucgenler',
              hasEvidence: false,
              band: MasteryBand.notStarted,
              score: 0.0,
              confidence: 0.0,
            ),
          }),
          targetTopicId: 'trigonometri',
          config: config,
        );

        expect(result.outcome, GateOutcome.open);
      },
    );

    test(
      'Scenario G - locked hard prerequisite dominates other outcomes',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'carpanlara_ayirma': state(
              topicId: 'carpanlara_ayirma',
              hasEvidence: true,
              band: MasteryBand.consolidated,
              score: 90.0,
              confidence: 0.90,
            ),
            'denklem_cozme': state(
              topicId: 'denklem_cozme',
              hasEvidence: true,
              band: MasteryBand.developing,
              score: 60.0,
              confidence: 0.70,
            ),
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: false,
              band: MasteryBand.notStarted,
              score: 0.0,
              confidence: 0.0,
            ),
          }),
          targetTopicId: 'ikinci_derece_denklemler_parabol',
          config: config,
        );

        expect(result.outcome, GateOutcome.locked);

        expect(
          result.lockedPrerequisiteTopicIds,
          contains('fonksiyonlar'),
        );

        expect(
          result.bridgePrerequisiteTopicIds,
          contains('denklem_cozme'),
        );
      },
    );

    test(
      'Scenario V - touched low score low confidence is not treated as untouched',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.learning,
              score: 15.0,
              confidence: 0.10,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          config: config,
        );

        expect(
          result.outcome,
          GateOutcome.bridgeRequired,
        );

        expect(
          result.lockedPrerequisiteTopicIds,
          isEmpty,
        );

        expect(
          result.bridgePrerequisiteTopicIds,
          contains('fonksiyonlar'),
        );
      },
    );

    test('topic with no hard prerequisites is open', () {
      final result = evaluatePrerequisiteGate(
        graph: tytAytMathGraph,
        snapshot: snapshot({}),
        targetTopicId: 'temel_kavramlar',
        config: config,
      );

      expect(result.outcome, GateOutcome.open);
    });

    test(
      'bridge requirement dominates verification requirement',
      () {
        final result = evaluatePrerequisiteGate(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'carpanlara_ayirma': state(
              topicId: 'carpanlara_ayirma',
              hasEvidence: true,
              band: MasteryBand.developing,
              score: 55.0,
              confidence: 0.80,
            ),
            'denklem_cozme': state(
              topicId: 'denklem_cozme',
              hasEvidence: true,
              band: MasteryBand.consolidated,
              score: 90.0,
              confidence: 0.30,
            ),
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              hasEvidence: true,
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.85,
            ),
          }),
          targetTopicId: 'ikinci_derece_denklemler_parabol',
          config: config,
        );

        expect(
          result.outcome,
          GateOutcome.bridgeRequired,
        );

        expect(
          result.bridgePrerequisiteTopicIds,
          contains('carpanlara_ayirma'),
        );

        expect(
          result.verificationPrerequisiteTopicIds,
          contains('denklem_cozme'),
        );
      },
    );
  });
}