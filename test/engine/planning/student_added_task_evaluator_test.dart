import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_added_task.dart';
import 'package:rota_app/domain/student_added_task_evaluation.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/engine/gate/prerequisite_gate.dart';
import 'package:rota_app/engine/graph/tyt_ayt_math_graph.dart';
import 'package:rota_app/engine/planning/student_added_task_evaluator.dart';

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

  StudentAddedTask task(String topicId) {
    return StudentAddedTask(
      topicId: topicId,
      addedAt: DateTime.utc(2026, 8, 14, 10),
    );
  }

  group('evaluateStudentAddedTask', () {
    test('allows open topic without warning', () {
      final result = evaluateStudentAddedTask(
        task: task('limit_ve_sureklilik'),
        graph: tytAytMathGraph,
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            band: MasteryBand.consolidated,
            score: 92.0,
            confidence: 0.85,
          ),
        }),
        gateConfig: gateConfig,
      );

      expect(result.isAllowed, isTrue);
      expect(result.status, StudentAddedTaskStatus.open);
      expect(result.requiresWarning, isFalse);
      expect(result.recommendedBridgeTopicId, isNull);
    });

    test('allows open-with-verification topic with warning', () {
      final result = evaluateStudentAddedTask(
        task: task('limit_ve_sureklilik'),
        graph: tytAytMathGraph,
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            band: MasteryBand.consolidated,
            score: 92.0,
            confidence: 0.30,
          ),
        }),
        gateConfig: gateConfig,
      );

      expect(result.isAllowed, isTrue);
      expect(
        result.status,
        StudentAddedTaskStatus.openWithVerification,
      );
      expect(result.requiresWarning, isTrue);
      expect(result.recommendedBridgeTopicId, isNull);
    });

    test('allows topic and recommends safe bridge', () {
      final result = evaluateStudentAddedTask(
        task: task('limit_ve_sureklilik'),
        graph: tytAytMathGraph,
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            band: MasteryBand.proficient,
            score: 84.0,
            confidence: 0.85,
          ),
        }),
        gateConfig: gateConfig,
      );

      expect(result.isAllowed, isTrue);
      expect(
        result.status,
        StudentAddedTaskStatus.bridgeRecommended,
      );
      expect(result.requiresWarning, isTrue);
      expect(
        result.recommendedBridgeTopicId,
        'fonksiyonlar',
      );
    });

    test('allows locked topic but requires explicit warning', () {
      final result = evaluateStudentAddedTask(
        task: task('limit_ve_sureklilik'),
        graph: tytAytMathGraph,
        snapshot: snapshot({}),
        gateConfig: gateConfig,
      );

      expect(result.isAllowed, isTrue);
      expect(
        result.status,
        StudentAddedTaskStatus.lockedButAllowed,
      );
      expect(result.requiresWarning, isTrue);
      expect(result.recommendedBridgeTopicId, isNull);
    });

    test(
      'allows topic but does not recommend unsafe nested bridge',
      () {
        final result = evaluateStudentAddedTask(
          task: task('ikinci_derece_denklemler_parabol'),
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
            'uslu_sayilar': state(
              topicId: 'uslu_sayilar',
              band: MasteryBand.proficient,
              score: 84.0,
              confidence: 0.85,
            ),
          }),
          gateConfig: gateConfig,
        );

        expect(result.isAllowed, isTrue);

        expect(
          result.status,
          StudentAddedTaskStatus.lockedButAllowed,
        );

        expect(result.requiresWarning, isTrue);
        expect(result.recommendedBridgeTopicId, isNull);
      },
    );
  });
}