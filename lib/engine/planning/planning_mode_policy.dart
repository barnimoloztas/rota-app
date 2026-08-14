import '../../domain/planning_mode.dart';
import '../../domain/study_candidate.dart';

class PlanningModePolicy {
  const PlanningModePolicy({
    required this.mode,
    required this.emphasizedSources,
    required this.deemphasizedSources,
    required this.deemphasizeBridgeProgress,
    required this.requiresAvoidanceAdaptation,
  });

  final PlanningMode mode;

  /// Candidate sources that this mode should favor during ranking.
  ///
  /// No numeric bonus is defined here.
  /// Ranking calibration belongs to configuration.
  final Set<CandidateSource> emphasizedSources;

  /// Candidate sources that this mode should reduce in priority.
  ///
  /// No candidate is removed solely because it appears here.
  final Set<CandidateSource> deemphasizedSources;

  /// Whether progress candidates that require bridge work should be
  /// relatively discouraged in this mode.
  ///
  /// Pre-exam mode uses this because opening a new difficult topic
  /// should move backward before an exam.
  final bool deemphasizeBridgeProgress;

  /// Whether avoided work needs a later adaptation step.
  ///
  /// The current engine does not yet model activity changes such as
  /// "solve questions" -> "watch explanation", so avoidance adaptation
  /// is represented explicitly instead of being guessed here.
  final bool requiresAvoidanceAdaptation;
}

PlanningModePolicy planningModePolicyFor(
  PlanningMode mode,
) {
  switch (mode) {
    case PlanningMode.normal:
      return const PlanningModePolicy(
        mode: PlanningMode.normal,
        emphasizedSources: {
          CandidateSource.repair,
        },
        deemphasizedSources: {},
        deemphasizeBridgeProgress: false,
        requiresAvoidanceAdaptation: false,
      );

    case PlanningMode.preExam:
      return const PlanningModePolicy(
        mode: PlanningMode.preExam,
        emphasizedSources: {
          CandidateSource.measurement,
          CandidateSource.reinforcement,
        },
        deemphasizedSources: {
          CandidateSource.progress,
        },
        deemphasizeBridgeProgress: true,
        requiresAvoidanceAdaptation: false,
      );

    case PlanningMode.postExam:
      return const PlanningModePolicy(
        mode: PlanningMode.postExam,
        emphasizedSources: {
          CandidateSource.repair,
        },
        deemphasizedSources: {},
        deemphasizeBridgeProgress: false,
        requiresAvoidanceAdaptation: false,
      );

    case PlanningMode.avoidance:
      return const PlanningModePolicy(
        mode: PlanningMode.avoidance,
        emphasizedSources: {},
        deemphasizedSources: {},
        deemphasizeBridgeProgress: false,
        requiresAvoidanceAdaptation: true,
      );
  }
}