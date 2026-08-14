import '../../domain/measurement_signal.dart';
import '../../domain/reinforcement_signal.dart';
import '../../domain/repair_signal.dart';
import '../../domain/study_candidate.dart';
import '../../domain/student_learning_snapshot.dart';
import '../../domain/topic.dart';
import '../gate/prerequisite_gate.dart';
import '../graph/prerequisite_graph.dart';
import 'candidate_merger.dart';
import 'measurement_candidate_generator.dart';
import 'progress_candidate_generator.dart';
import 'reinforcement_candidate_generator.dart';
import 'repair_candidate_generator.dart';

class CandidateGenerationInput {
  const CandidateGenerationInput({
    required this.graph,
    required this.snapshot,
    required this.progressTargetTopicIds,
    required this.repairSignals,
    required this.reinforcementSignals,
    required this.measurementSignals,
    required this.gateConfig,
  });

  final PrerequisiteGraph graph;
  final StudentLearningSnapshot snapshot;

  final List<TopicId> progressTargetTopicIds;
  final List<RepairSignal> repairSignals;
  final List<ReinforcementSignal> reinforcementSignals;
  final List<MeasurementSignal> measurementSignals;

  final PrerequisiteGateConfig gateConfig;
}

List<StudyCandidate> generateCandidates(
  CandidateGenerationInput input,
) {
  final candidates = <StudyCandidate>[];

  for (final targetTopicId in input.progressTargetTopicIds) {
    final candidate = generateProgressCandidate(
      graph: input.graph,
      snapshot: input.snapshot,
      targetTopicId: targetTopicId,
      gateConfig: input.gateConfig,
    );

    if (candidate != null) {
      candidates.add(candidate);
    }
  }

  for (final signal in input.repairSignals) {
    candidates.add(
      generateRepairCandidate(
        signal: signal,
      ),
    );
  }

  for (final signal in input.reinforcementSignals) {
    candidates.add(
      generateReinforcementCandidate(
        signal: signal,
      ),
    );
  }

  for (final signal in input.measurementSignals) {
    candidates.add(
      generateMeasurementCandidate(
        signal: signal,
      ),
    );
  }

  return mergeCandidates(candidates);
}