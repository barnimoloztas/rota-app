import 'topic.dart';

enum StudentAddedTaskStatus {
  open,
  openWithVerification,
  bridgeRecommended,
  lockedButAllowed,
}

class StudentAddedTaskEvaluation {
  const StudentAddedTaskEvaluation({
    required this.topicId,
    required this.status,
    required this.requiresWarning,
    required this.recommendedBridgeTopicId,
  });

  /// Topic explicitly chosen by the student.
  final TopicId topicId;

  /// Motor interpretation of the student's request.
  ///
  /// Even [lockedButAllowed] does not reject the student's choice.
  final StudentAddedTaskStatus status;

  /// Whether the UI must explicitly communicate prerequisite risk
  /// or uncertainty to the student.
  final bool requiresWarning;

  /// Recommended prerequisite bridge topic when one can safely be offered.
  ///
  /// Null when no bridge is needed or when a safe single-depth bridge
  /// cannot be produced.
  final TopicId? recommendedBridgeTopicId;

  /// Student-added tasks are never rejected solely by prerequisite gating.
  bool get isAllowed => true;
}