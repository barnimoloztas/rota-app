import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/progress_candidate_generator.dart';
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

  group('generateProgressCandidate', () {
    test('returns null when target is locked', () {
      final candidate = generateProgressCandidate(
        graph: tytAytMathGraph,
        snapshot: snapshot({}),
        targetTopicId: 'limit_ve_sureklilik',
        gateConfig: gateConfig,
      );

      expect(candidate, isNull);
    });

    test('returns bridge candidate when bridge is safe', () {
      final candidate = generateProgressCandidate(
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

      expect(candidate, isNotNull);
      expect(candidate!.topicId, 'limit_ve_sureklilik');
      expect(candidate.primarySource, CandidateSource.progress);
      expect(candidate.sources, {CandidateSource.progress});
      expect(candidate.requiresBridge, isTrue);
      expect(candidate.bridgeTopicId, 'fonksiyonlar');
    });

    test('returns null when required bridge is blocked by nested prerequisite',
        () {
      final candidate = generateProgressCandidate(
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

      expect(candidate, isNull);
    });

    test('returns normal progress candidate when target is open', () {
      final candidate = generateProgressCandidate(
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

      expect(candidate, isNotNull);
      expect(candidate!.topicId, 'limit_ve_sureklilik');
      expect(candidate.primarySource, CandidateSource.progress);
      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);
    });

    test(
      'returns progress candidate without bridge when target is open with verification',
      () {
        final candidate = generateProgressCandidate(
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

        expect(candidate, isNotNull);
        expect(candidate!.topicId, 'limit_ve_sureklilik');
        expect(candidate.primarySource, CandidateSource.progress);
        expect(candidate.requiresBridge, isFalse);
        expect(candidate.bridgeTopicId, isNull);
      },
    );

    test('returns progress candidate for topic with no hard prerequisites', () {
      final candidate = generateProgressCandidate(
        graph: tytAytMathGraph,
        snapshot: snapshot({}),
        targetTopicId: 'temel_kavramlar',
        gateConfig: gateConfig,
      );

      expect(candidate, isNotNull);
      expect(candidate!.topicId, 'temel_kavramlar');
      expect(candidate.primarySource, CandidateSource.progress);
      expect(candidate.requiresBridge, isFalse);
      expect(candidate.bridgeTopicId, isNull);
    });
  });
}