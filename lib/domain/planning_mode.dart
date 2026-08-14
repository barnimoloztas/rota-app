enum PlanningMode {
  normal,
  preExam,
  postExam,
  avoidance,
}

class PlanningModeContext {
  const PlanningModeContext({
    required this.isPreExam,
    required this.isPostExam,
    required this.isAvoidanceActive,
  });

  final bool isPreExam;
  final bool isPostExam;
  final bool isAvoidanceActive;
}

PlanningMode resolvePlanningMode(
  PlanningModeContext context,
) {
  // Exam-related modes override avoidance.
  //
  // If both exam modes are somehow active at the same time,
  // post-exam takes precedence because it represents newer evidence.
  if (context.isPostExam) {
    return PlanningMode.postExam;
  }

  if (context.isPreExam) {
    return PlanningMode.preExam;
  }

  if (context.isAvoidanceActive) {
    return PlanningMode.avoidance;
  }

  return PlanningMode.normal;
}