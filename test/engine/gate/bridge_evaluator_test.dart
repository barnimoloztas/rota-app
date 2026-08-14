import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/engine/gate/bridge_evaluator.dart';
import 'package:rota_app/engine/gate/prerequisite_gate.dart';
import 'package:rota_app/engine/graph/tyt_ayt_math_graph.dart';

void main() {
  const gateConfig = PrerequisiteGateConfig(
    minimumConsolidatedConfidence: 0.60,
  );

  StudentTopicState state({
    required String topicId,
    required MasteryBand band,
    required double score,
    required double confidence,
  }) {
    final calculatedAt = DateTime.utc(2026, 8, 14);

    return StudentTopicState(
      topicId: topicId,
      hasEvidence: true,
      mastery: Mastery(
        score: score,
        confidence: confidence,
      ),
      masteryBand: band,
      lastMeaningfulEvidenceAt: DateTime.utc(2026, 8, 13),
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

  group('BridgeEvaluator', () {
    test(
      'selects a bridge for a touched but not consolidated prerequisite',
      () {
        final result = evaluateBridge(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.proficient,
              score: 85.0,
              confidence: 0.90,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          gateConfig: gateConfig,
        );

        expect(
          result.gateResult.outcome,
          GateOutcome.bridgeRequired,
        );
        expect(result.selectedBridgeTopicId, 'fonksiyonlar');
        expect(result.blockedByNestedPrerequisite, isFalse);
        expect(result.canProceedWithTarget, isTrue);
      },
    );

    test(
      'does not create a bridge when target is already open',
      () {
        final result = evaluateBridge(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.85,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          gateConfig: gateConfig,
        );

        expect(result.gateResult.outcome, GateOutcome.open);
        expect(result.selectedBridgeTopicId, isNull);
        expect(result.blockedByNestedPrerequisite, isFalse);
        expect(result.canProceedWithTarget, isTrue);
      },
    );

    test(
      'does not create a bridge for open-with-verification target',
      () {
        final result = evaluateBridge(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.30,
            ),
          }),
          targetTopicId: 'limit_ve_sureklilik',
          gateConfig: gateConfig,
        );

        expect(
          result.gateResult.outcome,
          GateOutcome.openWithVerification,
        );
        expect(result.selectedBridgeTopicId, isNull);
        expect(result.blockedByNestedPrerequisite, isFalse);
        expect(result.canProceedWithTarget, isTrue);
      },
    );

    test(
      'Scenario P - does not create a bridge for a bridge whose own hard prerequisite is locked',
      () {
        final result = evaluateBridge(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'carpanlara_ayirma': state(
              topicId: 'carpanlara_ayirma',
              band: MasteryBand.proficient,
              score: 82.0,
              confidence: 0.85,
            ),
            'denklem_cozme': state(
              topicId: 'denklem_cozme',
              band: MasteryBand.consolidated,
              score: 90.0,
              confidence: 0.90,
            ),
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.consolidated,
              score: 91.0,
              confidence: 0.90,
            ),
          }),
          targetTopicId: 'ikinci_derece_denklemler_parabol',
          gateConfig: gateConfig,
        );

        expect(
          result.gateResult.outcome,
          GateOutcome.bridgeRequired,
        );

        // Çarpanlara Ayırma'nın hard prerequisite'i olan
        // Üslü Sayılar snapshot'ta yoktur; dolayısıyla bridge'in
        // kendisi locked durumundadır.
        expect(result.selectedBridgeTopicId, isNull);
        expect(result.blockedByNestedPrerequisite, isTrue);
        expect(result.canProceedWithTarget, isFalse);
      },
    );

    test(
      'uses only one bridge candidate when multiple prerequisites need bridges',
      () {
        final result = evaluateBridge(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'carpanlara_ayirma': state(
              topicId: 'carpanlara_ayirma',
              band: MasteryBand.proficient,
              score: 82.0,
              confidence: 0.85,
            ),
            'denklem_cozme': state(
              topicId: 'denklem_cozme',
              band: MasteryBand.developing,
              score: 60.0,
              confidence: 0.75,
            ),
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.consolidated,
              score: 91.0,
              confidence: 0.90,
            ),
            'uslu_sayilar': state(
              topicId: 'uslu_sayilar',
              band: MasteryBand.consolidated,
              score: 93.0,
              confidence: 0.90,
            ),
          }),
          targetTopicId: 'ikinci_derece_denklemler_parabol',
          gateConfig: gateConfig,
        );

        expect(
          result.gateResult.bridgePrerequisiteTopicIds,
          hasLength(2),
        );

        // Şimdilik seçim deterministik olarak ilk bridge adayıdır.
        // Daha sonra Candidate Ranking bu seçimin yerini alacak.
        expect(
          result.selectedBridgeTopicId,
          'carpanlara_ayirma',
        );

        expect(result.blockedByNestedPrerequisite, isFalse);
        expect(result.canProceedWithTarget, isTrue);
      },
    );

    test(
      'cannot proceed when target itself is locked',
      () {
        final result = evaluateBridge(
          graph: tytAytMathGraph,
          snapshot: snapshot({}),
          targetTopicId: 'limit_ve_sureklilik',
          gateConfig: gateConfig,
        );

        expect(result.gateResult.outcome, GateOutcome.locked);
        expect(result.selectedBridgeTopicId, isNull);
        expect(result.canProceedWithTarget, isFalse);
      },
    );
  });
}