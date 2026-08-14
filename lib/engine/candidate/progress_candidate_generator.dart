import '../../domain/study_candidate.dart';
import '../../domain/student_learning_snapshot.dart';
import '../../domain/topic.dart';
import '../gate/bridge_evaluator.dart';
import '../gate/prerequisite_gate.dart';
import '../graph/prerequisite_graph.dart';

StudyCandidate? generateProgressCandidate({
  required PrerequisiteGraph graph,
  required StudentLearningSnapshot snapshot,
  required TopicId targetTopicId,
  required PrerequisiteGateConfig gateConfig,
}) {
  final bridgeEvaluation = evaluateBridge(
    graph: graph,
    snapshot: snapshot,
    targetTopicId: targetTopicId,
    gateConfig: gateConfig,
  );

  switch (bridgeEvaluation.gateResult.outcome) {
    case GateOutcome.locked:
      return null;

    case GateOutcome.bridgeRequired:
      final bridgeTopicId = bridgeEvaluation.selectedBridgeTopicId;

      if (bridgeTopicId == null ||
          bridgeEvaluation.blockedByNestedPrerequisite) {
        return null;
      }

      return StudyCandidate(
        topicId: targetTopicId,
        primarySource: CandidateSource.progress,
        sources: const {
          CandidateSource.progress,
        },
        requiresBridge: true,
        bridgeTopicId: bridgeTopicId,
      );

    case GateOutcome.openWithVerification:
    case GateOutcome.open:
      return StudyCandidate(
        topicId: targetTopicId,
        primarySource: CandidateSource.progress,
        sources: const {
          CandidateSource.progress,
        },
        requiresBridge: false,
        bridgeTopicId: null,
      );
  }
}