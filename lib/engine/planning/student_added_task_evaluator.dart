import '../../domain/student_added_task.dart';
import '../../domain/student_added_task_evaluation.dart';
import '../../domain/student_learning_snapshot.dart';
import '../gate/bridge_evaluator.dart';
import '../gate/prerequisite_gate.dart';
import '../graph/prerequisite_graph.dart';

StudentAddedTaskEvaluation evaluateStudentAddedTask({
  required StudentAddedTask task,
  required PrerequisiteGraph graph,
  required StudentLearningSnapshot snapshot,
  required PrerequisiteGateConfig gateConfig,
}) {
  final bridgeEvaluation = evaluateBridge(
    graph: graph,
    snapshot: snapshot,
    targetTopicId: task.topicId,
    gateConfig: gateConfig,
  );

  switch (bridgeEvaluation.gateResult.outcome) {
    case GateOutcome.open:
      return StudentAddedTaskEvaluation(
        topicId: task.topicId,
        status: StudentAddedTaskStatus.open,
        requiresWarning: false,
        recommendedBridgeTopicId: null,
      );

    case GateOutcome.openWithVerification:
      return StudentAddedTaskEvaluation(
        topicId: task.topicId,
        status: StudentAddedTaskStatus.openWithVerification,
        requiresWarning: true,
        recommendedBridgeTopicId: null,
      );

    case GateOutcome.bridgeRequired:
      final bridgeTopicId =
          bridgeEvaluation.selectedBridgeTopicId;

      if (bridgeTopicId != null &&
          !bridgeEvaluation.blockedByNestedPrerequisite) {
        return StudentAddedTaskEvaluation(
          topicId: task.topicId,
          status: StudentAddedTaskStatus.bridgeRecommended,
          requiresWarning: true,
          recommendedBridgeTopicId: bridgeTopicId,
        );
      }

      return StudentAddedTaskEvaluation(
        topicId: task.topicId,
        status: StudentAddedTaskStatus.lockedButAllowed,
        requiresWarning: true,
        recommendedBridgeTopicId: null,
      );

    case GateOutcome.locked:
      return StudentAddedTaskEvaluation(
        topicId: task.topicId,
        status: StudentAddedTaskStatus.lockedButAllowed,
        requiresWarning: true,
        recommendedBridgeTopicId: null,
      );
  }
}