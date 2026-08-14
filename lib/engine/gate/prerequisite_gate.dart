import '../../domain/mastery_band.dart';
import '../../domain/student_learning_snapshot.dart';
import '../../domain/student_topic_state.dart';
import '../../domain/topic.dart';
import '../graph/graph_queries.dart';
import '../graph/prerequisite_graph.dart';

enum GateOutcome {
  locked,
  bridgeRequired,
  openWithVerification,
  open,
}

class PrerequisiteGateConfig {
  const PrerequisiteGateConfig({
    required this.minimumConsolidatedConfidence,
  }) : assert(
          minimumConsolidatedConfidence >= 0.0 &&
              minimumConsolidatedConfidence <= 1.0,
        );

  final double minimumConsolidatedConfidence;
}

class PrerequisiteGateResult {
  const PrerequisiteGateResult({
    required this.targetTopicId,
    required this.outcome,
    required this.lockedPrerequisiteTopicIds,
    required this.bridgePrerequisiteTopicIds,
    required this.verificationPrerequisiteTopicIds,
  });

  final TopicId targetTopicId;
  final GateOutcome outcome;

  /// Hard prerequisites that are untouched or not started.
  final List<TopicId> lockedPrerequisiteTopicIds;

  /// Hard prerequisites that are touched but not yet consolidated.
  final List<TopicId> bridgePrerequisiteTopicIds;

  /// Consolidated hard prerequisites whose confidence is too low
  /// for an unconditional open result.
  final List<TopicId> verificationPrerequisiteTopicIds;
}

PrerequisiteGateResult evaluatePrerequisiteGate({
  required PrerequisiteGraph graph,
  required StudentLearningSnapshot snapshot,
  required TopicId targetTopicId,
  required PrerequisiteGateConfig config,
}) {
  final hardPrerequisites = getDirectHardPrerequisites(
    graph,
    targetTopicId,
  );

  if (hardPrerequisites.isEmpty) {
    return PrerequisiteGateResult(
      targetTopicId: targetTopicId,
      outcome: GateOutcome.open,
      lockedPrerequisiteTopicIds: const [],
      bridgePrerequisiteTopicIds: const [],
      verificationPrerequisiteTopicIds: const [],
    );
  }

  final locked = <TopicId>[];
  final bridgeRequired = <TopicId>[];
  final verificationRequired = <TopicId>[];

  for (final edge in hardPrerequisites) {
    final prerequisiteTopicId = edge.prerequisiteTopicId;
    final state = snapshot.topicStates[prerequisiteTopicId];

    final prerequisiteOutcome = _evaluateHardPrerequisite(
      state: state,
      minimumConsolidatedConfidence:
          config.minimumConsolidatedConfidence,
    );

    switch (prerequisiteOutcome) {
      case GateOutcome.locked:
        locked.add(prerequisiteTopicId);

      case GateOutcome.bridgeRequired:
        bridgeRequired.add(prerequisiteTopicId);

      case GateOutcome.openWithVerification:
        verificationRequired.add(prerequisiteTopicId);

      case GateOutcome.open:
        break;
    }
  }

  final outcome = _combineHardPrerequisiteOutcomes(
    hasLocked: locked.isNotEmpty,
    hasBridgeRequired: bridgeRequired.isNotEmpty,
    hasVerificationRequired: verificationRequired.isNotEmpty,
  );

  return PrerequisiteGateResult(
    targetTopicId: targetTopicId,
    outcome: outcome,
    lockedPrerequisiteTopicIds: List.unmodifiable(locked),
    bridgePrerequisiteTopicIds: List.unmodifiable(bridgeRequired),
    verificationPrerequisiteTopicIds:
        List.unmodifiable(verificationRequired),
  );
}

GateOutcome _evaluateHardPrerequisite({
  required StudentTopicState? state,
  required double minimumConsolidatedConfidence,
}) {
  // Missing state is treated as untouched.
  if (state == null || !state.hasEvidence) {
    return GateOutcome.locked;
  }

  switch (state.masteryBand) {
    case MasteryBand.notStarted:
      return GateOutcome.locked;

    case MasteryBand.learning:
    case MasteryBand.developing:
    case MasteryBand.proficient:
      return GateOutcome.bridgeRequired;

    case MasteryBand.consolidated:
      if (state.mastery.confidence <
          minimumConsolidatedConfidence) {
        return GateOutcome.openWithVerification;
      }

      return GateOutcome.open;
  }
}

GateOutcome _combineHardPrerequisiteOutcomes({
  required bool hasLocked,
  required bool hasBridgeRequired,
  required bool hasVerificationRequired,
}) {
  if (hasLocked) {
    return GateOutcome.locked;
  }

  if (hasBridgeRequired) {
    return GateOutcome.bridgeRequired;
  }

  if (hasVerificationRequired) {
    return GateOutcome.openWithVerification;
  }

  return GateOutcome.open;
}