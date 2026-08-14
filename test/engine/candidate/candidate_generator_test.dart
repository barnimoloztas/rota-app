import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/measurement_signal.dart';
import 'package:rota_app/domain/reinforcement_signal.dart';
import 'package:rota_app/domain/repair_signal.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/domain/study_candidate.dart';
import 'package:rota_app/engine/candidate/candidate_generator.dart';
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

  group('generateCandidates', () {
    test('combines progress repair reinforcement and measurement candidates', () {
      final result = generateCandidates(
        CandidateGenerationInput(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.85,
            ),
          }),
          progressTargetTopicIds: const [
            'limit_ve_sureklilik',
          ],
          repairSignals: const [
            RepairSignal(
              topicId: 'trigonometri',
              reason: RepairSignalReason.lowMastery,
              strength: 0.90,
            ),
          ],
          reinforcementSignals: const [
            ReinforcementSignal(
              topicId: 'turev',
              reason: ReinforcementSignalReason.masteryMaintenance,
              strength: 0.40,
            ),
          ],
          measurementSignals: const [
            MeasurementSignal(
              topicId: 'integral',
              reason: MeasurementSignalReason.lowConfidence,
              strength: 0.70,
            ),
          ],
          gateConfig: gateConfig,
        ),
      );

      expect(result, hasLength(4));

      expect(
        result.map((candidate) => candidate.topicId),
        containsAll({
          'limit_ve_sureklilik',
          'trigonometri',
          'turev',
          'integral',
        }),
      );
    });

    test('does not include locked progress target', () {
      final result = generateCandidates(
        CandidateGenerationInput(
          graph: tytAytMathGraph,
          snapshot: snapshot({}),
          progressTargetTopicIds: const [
            'limit_ve_sureklilik',
          ],
          repairSignals: const [],
          reinforcementSignals: const [],
          measurementSignals: const [],
          gateConfig: gateConfig,
        ),
      );

      expect(result, isEmpty);
    });

    test('merges same topic across multiple candidate sources', () {
      final result = generateCandidates(
        CandidateGenerationInput(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.consolidated,
              score: 92.0,
              confidence: 0.85,
            ),
          }),
          progressTargetTopicIds: const [
            'limit_ve_sureklilik',
          ],
          repairSignals: const [
            RepairSignal(
              topicId: 'limit_ve_sureklilik',
              reason: RepairSignalReason.lowMastery,
              strength: 0.80,
            ),
          ],
          reinforcementSignals: const [
            ReinforcementSignal(
              topicId: 'limit_ve_sureklilik',
              reason: ReinforcementSignalReason.masteryMaintenance,
              strength: 0.45,
            ),
          ],
          measurementSignals: const [
            MeasurementSignal(
              topicId: 'limit_ve_sureklilik',
              reason: MeasurementSignalReason.lowConfidence,
              strength: 0.65,
            ),
          ],
          gateConfig: gateConfig,
        ),
      );

      expect(result, hasLength(1));

      final candidate = result.first;

      expect(candidate.topicId, 'limit_ve_sureklilik');

      expect(
        candidate.sources,
        containsAll({
          CandidateSource.progress,
          CandidateSource.repair,
          CandidateSource.reinforcement,
          CandidateSource.measurement,
        }),
      );

      expect(candidate.signals, hasLength(3));

      expect(
        candidate.signals.map((signal) => signal.reason),
        containsAll({
          CandidateReason.lowMastery,
          CandidateReason.masteryMaintenance,
          CandidateReason.lowConfidence,
        }),
      );
    });

    test('preserves bridge requirement through orchestration and merge', () {
      final result = generateCandidates(
        CandidateGenerationInput(
          graph: tytAytMathGraph,
          snapshot: snapshot({
            'fonksiyonlar': state(
              topicId: 'fonksiyonlar',
              band: MasteryBand.proficient,
              score: 84.0,
              confidence: 0.85,
            ),
          }),
          progressTargetTopicIds: const [
            'limit_ve_sureklilik',
          ],
          repairSignals: const [
            RepairSignal(
              topicId: 'limit_ve_sureklilik',
              reason: RepairSignalReason.lowMastery,
              strength: 0.70,
            ),
          ],
          reinforcementSignals: const [],
          measurementSignals: const [],
          gateConfig: gateConfig,
        ),
      );

      expect(result, hasLength(1));

      final candidate = result.first;

      expect(candidate.requiresBridge, isTrue);
      expect(candidate.bridgeTopicId, 'fonksiyonlar');

      expect(
        candidate.sources,
        containsAll({
          CandidateSource.progress,
          CandidateSource.repair,
        }),
      );
    });

    test('keeps candidates deterministic for the same ordered input', () {
      final input = CandidateGenerationInput(
        graph: tytAytMathGraph,
        snapshot: snapshot({
          'fonksiyonlar': state(
            topicId: 'fonksiyonlar',
            band: MasteryBand.consolidated,
            score: 92.0,
            confidence: 0.85,
          ),
        }),
        progressTargetTopicIds: const [
          'limit_ve_sureklilik',
        ],
        repairSignals: const [
          RepairSignal(
            topicId: 'trigonometri',
            reason: RepairSignalReason.lowMastery,
            strength: 0.80,
          ),
        ],
        reinforcementSignals: const [],
        measurementSignals: const [],
        gateConfig: gateConfig,
      );

      final first = generateCandidates(input);
      final second = generateCandidates(input);

      expect(first.length, second.length);

      for (var i = 0; i < first.length; i++) {
        expect(first[i].topicId, second[i].topicId);
        expect(first[i].primarySource, second[i].primarySource);
        expect(first[i].sources, second[i].sources);
        expect(first[i].requiresBridge, second[i].requiresBridge);
        expect(first[i].bridgeTopicId, second[i].bridgeTopicId);
      }
    });
  });
}