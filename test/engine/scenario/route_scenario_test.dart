import 'package:flutter_test/flutter_test.dart';
import 'package:rota_app/domain/mastery.dart';
import 'package:rota_app/domain/mastery_band.dart';
import 'package:rota_app/domain/measurement_signal.dart';
import 'package:rota_app/domain/repair_signal.dart';
import 'package:rota_app/domain/selected_mode.dart';
import 'package:rota_app/domain/student_learning_snapshot.dart';
import 'package:rota_app/domain/student_topic_state.dart';
import 'package:rota_app/engine/candidate/candidate_generator.dart';
import 'package:rota_app/engine/gate/prerequisite_gate.dart';
import 'package:rota_app/engine/graph/tyt_ayt_math_graph.dart';
import 'package:rota_app/engine/route/route_builder.dart';
import 'package:rota_app/engine/route/route_selector.dart';

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

  group('route scenarios', () {
    test(
      'strong prerequisite allows normal progress while repair and measurement share the route',
      () {
        final candidates = generateCandidates(
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

        final route = buildRoute(
          candidates: candidates,
          selectedMode: SelectedMode.balanced,
        );

        final selected = selectRouteTasks(
          route: route,
          config: const RouteSelectionConfig(
            maxTasks: 4,
          ),
        );

        expect(selected.tasks, hasLength(3));

        expect(
          selected.tasks.map((task) => task.topicId),
          containsAll({
            'limit_ve_sureklilik',
            'trigonometri',
            'integral',
          }),
        );
      },
    );

    test('weak prerequisite creates bridge before target', () {
      final candidates = generateCandidates(
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
          repairSignals: const [],
          measurementSignals: const [],
          gateConfig: gateConfig,
        ),
      );

      final route = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(selected.tasks, hasLength(2));

      expect(selected.tasks[0].topicId, 'fonksiyonlar');
      expect(selected.tasks[0].type.name, 'bridge');

      expect(
        selected.tasks[1].topicId,
        'limit_ve_sureklilik',
      );
    });

    test('four-task ceiling keeps bridge and target together', () {
      final candidates = generateCandidates(
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
              topicId: 'trigonometri',
              reason: RepairSignalReason.lowMastery,
              strength: 0.90,
            ),
            RepairSignal(
              topicId: 'turev',
              reason: RepairSignalReason.lowMastery,
              strength: 0.80,
            ),
            RepairSignal(
              topicId: 'integral',
              reason: RepairSignalReason.lowMastery,
              strength: 0.75,
            ),
          ],
          measurementSignals: const [],
          gateConfig: gateConfig,
        ),
      );

      final route = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(selected.tasks, hasLength(4));

      expect(selected.tasks[0].topicId, 'fonksiyonlar');
      expect(selected.tasks[1].topicId, 'limit_ve_sureklilik');

      expect(
        selected.tasks.where((task) => task.type.name == 'bridge').length,
        1,
      );
    });

    test('locked prerequisite removes progress target from final route', () {
      final candidates = generateCandidates(
        CandidateGenerationInput(
          graph: tytAytMathGraph,
          snapshot: snapshot({}),
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
          measurementSignals: const [],
          gateConfig: gateConfig,
        ),
      );

      final route = buildRoute(
        candidates: candidates,
        selectedMode: SelectedMode.balanced,
      );

      final selected = selectRouteTasks(
        route: route,
        config: const RouteSelectionConfig(
          maxTasks: 4,
        ),
      );

      expect(
        selected.tasks.any(
          (task) => task.topicId == 'limit_ve_sureklilik',
        ),
        isFalse,
      );

      expect(
        selected.tasks.any(
          (task) => task.topicId == 'trigonometri',
        ),
        isTrue,
      );
    });
  });
}