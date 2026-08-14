import '../../domain/student_learning_snapshot.dart';
import '../../domain/topic.dart';
import '../graph/prerequisite_graph.dart';
import 'prerequisite_gate.dart';

class BridgeEvaluationResult {
  const BridgeEvaluationResult({
    required this.targetTopicId,
    required this.gateResult,
    required this.selectedBridgeTopicId,
    required this.blockedByNestedPrerequisite,
  });

  final TopicId targetTopicId;
  final PrerequisiteGateResult gateResult;

  /// The single prerequisite topic selected for bridge work.
  ///
  /// Null when no bridge is required or when no safe bridge can be selected.
  final TopicId? selectedBridgeTopicId;

  /// True when the selected bridge candidate itself is blocked by
  /// an untouched hard prerequisite.
  final bool blockedByNestedPrerequisite;

  bool get canProceedWithTarget {
    return gateResult.outcome == GateOutcome.open ||
        gateResult.outcome == GateOutcome.openWithVerification ||
        (gateResult.outcome == GateOutcome.bridgeRequired &&
            selectedBridgeTopicId != null &&
            !blockedByNestedPrerequisite);
  }
}

BridgeEvaluationResult evaluateBridge({
  required PrerequisiteGraph graph,
  required StudentLearningSnapshot snapshot,
  required TopicId targetTopicId,
  required PrerequisiteGateConfig gateConfig,
}) {
  final gateResult = evaluatePrerequisiteGate(
    graph: graph,
    snapshot: snapshot,
    targetTopicId: targetTopicId,
    config: gateConfig,
  );

  if (gateResult.outcome != GateOutcome.bridgeRequired) {
    return BridgeEvaluationResult(
      targetTopicId: targetTopicId,
      gateResult: gateResult,
      selectedBridgeTopicId: null,
      blockedByNestedPrerequisite: false,
    );
  }

  final bridgeCandidates = gateResult.bridgePrerequisiteTopicIds;

  if (bridgeCandidates.isEmpty) {
    return BridgeEvaluationResult(
      targetTopicId: targetTopicId,
      gateResult: gateResult,
      selectedBridgeTopicId: null,
      blockedByNestedPrerequisite: false,
    );
  }

  // v0.2 rule:
  // A target with multiple bridge-required prerequisites does not receive
  // multiple bridges in the same route intent. For now, selection is
  // deterministic by graph/order position. Ranking will replace this
  // temporary selection rule later.
  final selectedBridgeTopicId = bridgeCandidates.first;

  final bridgeGateResult = evaluatePrerequisiteGate(
    graph: graph,
    snapshot: snapshot,
    targetTopicId: selectedBridgeTopicId,
    config: gateConfig,
  );

  // Max Bridge Depth = 1.
  // If the bridge topic itself is locked, we do not create another bridge.
  if (bridgeGateResult.outcome == GateOutcome.locked) {
    return BridgeEvaluationResult(
      targetTopicId: targetTopicId,
      gateResult: gateResult,
      selectedBridgeTopicId: null,
      blockedByNestedPrerequisite: true,
    );
  }

  return BridgeEvaluationResult(
    targetTopicId: targetTopicId,
    gateResult: gateResult,
    selectedBridgeTopicId: selectedBridgeTopicId,
    blockedByNestedPrerequisite: false,
  );
}